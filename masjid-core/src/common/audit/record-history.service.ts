import { HttpStatus, Injectable } from '@nestjs/common';
import { hasPermission, PERMISSIONS } from '../../access/permissions';
import { AuthenticatedUser } from '../../modules/platform-core/auth/types/jwt-payload.type';
import { PrismaService } from '../../prisma/prisma.service';
import { ERROR_CODES } from '../constants/error-codes.constant';
import { ApiException } from '../exceptions/api.exception';
import { requireMasjidId } from '../tenant';
import { AUDIT_ACTION, AUDIT_ENTITY, AuditEntity } from './audit.service';

/** Records whose history can be opened from the app. */
export const HISTORY_ENTITIES = [
  AUDIT_ENTITY.PROJECT,
  AUDIT_ENTITY.PROJECT_CONTRIBUTION,
  AUDIT_ENTITY.COLLECTION_CONTRIBUTION,
  AUDIT_ENTITY.SALARY_PAYMENT,
  AUDIT_ENTITY.SALARY_MONTH,
  AUDIT_ENTITY.COLLECTION,
  AUDIT_ENTITY.EXPENSE,
] as const;

export type HistoryEntity = (typeof HISTORY_ENTITIES)[number];

/** How the app should show a changed value. `code` is an enum value (type, status). */
type FieldKind = 'money' | 'date' | 'text' | 'code';

/** Fields worth showing as "old → new". Totals moved by payments are left out. */
const TRACKED_FIELDS: Partial<Record<AuditEntity, Record<string, FieldKind>>> =
  {
    PROJECT: {
      title: 'text',
      description: 'text',
      targetAmount: 'money',
      spentAmount: 'money',
      status: 'code',
      startDate: 'date',
      endDate: 'date',
    },
    COLLECTION: {
      type: 'code',
      amount: 'money',
      title: 'text',
      description: 'text',
      collectedAt: 'date',
    },
    EXPENSE: {
      type: 'code',
      amount: 'money',
      title: 'text',
      description: 'text',
      spentAt: 'date',
    },
    SALARY_MONTH: { amountPerHead: 'money' },
  };

export type HistoryChange = {
  field: string;
  kind: FieldKind;
  from: string | number | null;
  to: string | number | null;
};

export type HistoryEvent = {
  id: string;
  action: string;
  actorName: string;
  at: Date;
  changes: HistoryChange[];
};

export type RecordHistory = {
  entity: HistoryEntity;
  entityId: string;
  /** When the record itself was saved (also for records older than the log). */
  createdAt: Date;
  /** Who received the money, when that can differ from who entered it. */
  collectedByName: string | null;
  /** Oldest first. No CREATE event means the record predates the log. */
  events: HistoryEvent[];
};

/** What the history needs to know about the record itself. */
type Target = {
  createdAt: Date;
  collectedByName: string | null;
  /** The member the payment belongs to, for "my own payment" access. */
  memberId: string | null;
  /** Log rows of another entity that belong to this record (contribution ↔ finance entry). */
  linked: { entity: AuditEntity; entityId: string } | null;
};

/**
 * "Who added this, who changed it, when" for one record, read from the
 * append-only audit log.
 *
 * Imam and committee (audit.read) can open any record of their masjid.
 * Everyone else can open projects and their own payments, so members can
 * check what was recorded in their name.
 */
@Injectable()
export class RecordHistoryService {
  constructor(private readonly prisma: PrismaService) {}

  async find(
    entity: HistoryEntity,
    entityId: string,
    actor: AuthenticatedUser,
  ): Promise<RecordHistory> {
    const masjidId = requireMasjidId(actor);
    const target = await this.loadTarget(entity, entityId, masjidId);
    if (!target) {
      throw new ApiException(
        'Record not found',
        HttpStatus.NOT_FOUND,
        ERROR_CODES.NOT_FOUND,
      );
    }
    if (!this.canSee(actor, entity, target)) {
      throw new ApiException(
        'You can only see the history of your own payments',
        HttpStatus.FORBIDDEN,
        ERROR_CODES.FORBIDDEN,
      );
    }

    const sources = [{ entity: entity as AuditEntity, entityId }];
    if (target.linked) sources.push(target.linked);
    const rows = await this.prisma.auditLog.findMany({
      where: { masjidId, OR: sources },
      orderBy: { createdAt: 'asc' },
      select: {
        id: true,
        action: true,
        actorName: true,
        entity: true,
        before: true,
        after: true,
        createdAt: true,
      },
    });

    return {
      entity,
      entityId,
      createdAt: target.createdAt,
      collectedByName: target.collectedByName,
      events: rows
        // The finance entry made for a contribution is created with it; its
        // CREATE row would show the same moment twice.
        .filter(
          (row) => row.entity === entity || row.action !== AUDIT_ACTION.CREATE,
        )
        .map((row) => ({
          id: row.id,
          action: row.action,
          actorName: row.actorName,
          at: row.createdAt,
          changes:
            row.action === AUDIT_ACTION.UPDATE
              ? diff(row.entity as AuditEntity, row.before, row.after)
              : [],
        })),
    };
  }

  private canSee(
    actor: AuthenticatedUser,
    entity: HistoryEntity,
    target: Target,
  ): boolean {
    if (hasPermission(actor, PERMISSIONS.AUDIT_READ)) return true;
    if (entity === AUDIT_ENTITY.PROJECT) return true;
    return target.memberId !== null && target.memberId === actor.id;
  }

  private async loadTarget(
    entity: HistoryEntity,
    id: string,
    masjidId: string,
  ): Promise<Target | null> {
    const where = { id, masjidId };
    const none = { collectedByName: null, memberId: null, linked: null };
    switch (entity) {
      case AUDIT_ENTITY.PROJECT: {
        const row = await this.prisma.project.findFirst({
          where,
          select: { createdAt: true },
        });
        return row && { ...none, createdAt: row.createdAt };
      }
      case AUDIT_ENTITY.PROJECT_CONTRIBUTION:
        return this.prisma.projectContribution
          .findFirst({
            where,
            select: { createdAt: true, collectedByName: true, memberId: true },
          })
          .then((row) => row && { ...row, linked: null });
      case AUDIT_ENTITY.COLLECTION_CONTRIBUTION: {
        const row = await this.prisma.collectionContribution.findFirst({
          where,
          select: {
            createdAt: true,
            collectedByName: true,
            memberId: true,
            collectionId: true,
          },
        });
        if (!row) return null;
        const { collectionId, ...rest } = row;
        return {
          ...rest,
          linked: collectionId
            ? { entity: AUDIT_ENTITY.COLLECTION, entityId: collectionId }
            : null,
        };
      }
      case AUDIT_ENTITY.SALARY_PAYMENT:
        return this.prisma.imamSalaryPayment
          .findFirst({
            where,
            select: { createdAt: true, collectedByName: true, memberId: true },
          })
          .then((row) => row && { ...row, linked: null });
      case AUDIT_ENTITY.SALARY_MONTH: {
        const row = await this.prisma.imamSalaryMonth.findFirst({
          where,
          select: { createdAt: true },
        });
        return row && { ...none, createdAt: row.createdAt };
      }
      case AUDIT_ENTITY.COLLECTION: {
        const row = await this.prisma.collection.findFirst({
          where,
          select: {
            createdAt: true,
            contribution: {
              select: { id: true, collectedByName: true, memberId: true },
            },
          },
        });
        if (!row) return null;
        const contribution = row.contribution;
        return {
          createdAt: row.createdAt,
          collectedByName: contribution?.collectedByName ?? null,
          memberId: contribution?.memberId ?? null,
          linked: contribution
            ? {
                entity: AUDIT_ENTITY.COLLECTION_CONTRIBUTION,
                entityId: contribution.id,
              }
            : null,
        };
      }
      case AUDIT_ENTITY.EXPENSE: {
        const row = await this.prisma.expense.findFirst({
          where,
          select: { createdAt: true },
        });
        return row && { ...none, createdAt: row.createdAt };
      }
    }
  }
}

/** The tracked fields that differ between two logged snapshots. */
export function diff(
  entity: AuditEntity,
  before: unknown,
  after: unknown,
): HistoryChange[] {
  const fields = TRACKED_FIELDS[entity];
  if (!fields || !isObject(before) || !isObject(after)) return [];
  const changes: HistoryChange[] = [];
  for (const [field, kind] of Object.entries(fields)) {
    if (!(field in after)) continue;
    const from = normalize(before[field], kind);
    const to = normalize(after[field], kind);
    if (from !== to) changes.push({ field, kind, from, to });
  }
  return changes;
}

function isObject(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null;
}

/** Same value, same output: Decimals are strings in some snapshots and numbers in others. */
function normalize(value: unknown, kind: FieldKind): string | number | null {
  if (value === null || value === undefined || value === '') return null;
  switch (kind) {
    case 'money': {
      const amount = Number(value);
      return Number.isFinite(amount) ? amount : null;
    }
    case 'date': {
      const date = new Date(value as string);
      return Number.isNaN(date.getTime()) ? null : date.toISOString();
    }
    default: {
      const text = String(value as string).trim();
      return text === '' ? null : text;
    }
  }
}

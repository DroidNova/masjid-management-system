import { Injectable, Logger } from '@nestjs/common';
import { Prisma } from '../../generated/prisma/client';
import { PrismaService } from '../../prisma/prisma.service';

/** What was changed. Add new values here; the column is plain text. */
export const AUDIT_ENTITY = {
  COLLECTION: 'COLLECTION',
  EXPENSE: 'EXPENSE',
  PROJECT: 'PROJECT',
  PROJECT_CONTRIBUTION: 'PROJECT_CONTRIBUTION',
  COLLECTION_CONTRIBUTION: 'COLLECTION_CONTRIBUTION',
  SALARY_MONTH: 'SALARY_MONTH',
  SALARY_PAYMENT: 'SALARY_PAYMENT',
  MEMBER: 'MEMBER',
  MASJID: 'MASJID',
  MASJID_REQUEST: 'MASJID_REQUEST',
  USER: 'USER',
} as const;

export const AUDIT_ACTION = {
  CREATE: 'CREATE',
  UPDATE: 'UPDATE',
  CANCEL: 'CANCEL',
  STATUS_CHANGE: 'STATUS_CHANGE',
  ROLES_CHANGE: 'ROLES_CHANGE',
  JOIN: 'JOIN',
  LEAVE: 'LEAVE',
  APPROVE: 'APPROVE',
  REJECT: 'REJECT',
} as const;

export type AuditEntity = (typeof AUDIT_ENTITY)[keyof typeof AUDIT_ENTITY];
export type AuditAction = (typeof AUDIT_ACTION)[keyof typeof AUDIT_ACTION];

export type AuditEntry = {
  masjidId: string | null;
  actor: { id: string; fullName: string } | null;
  action: AuditAction;
  entity: AuditEntity;
  entityId: string;
  /** One readable line, e.g. "Expense ELECTRICITY_BILL 845.30". */
  summary: string;
  /** Record before the change (omit for CREATE). Decimals and dates are stored as strings. */
  before?: unknown;
  /** Record after the change (omit for CANCEL if nothing else changed). */
  after?: unknown;
};

/** Converts Decimals/Dates to plain JSON for the Json column. */
function toJson(value: unknown): Prisma.InputJsonValue | typeof Prisma.DbNull {
  if (value === undefined || value === null) return Prisma.DbNull;
  return JSON.parse(JSON.stringify(value)) as Prisma.InputJsonValue;
}

/**
 * Append-only audit trail. Call `record` inside the same transaction as the
 * change (pass `tx`) so the log and the data can never disagree.
 */
@Injectable()
export class AuditService {
  private readonly logger = new Logger(AuditService.name);

  constructor(private readonly prisma: PrismaService) {}

  async record(
    entry: AuditEntry,
    db: Prisma.TransactionClient = this.prisma,
  ): Promise<void> {
    await db.auditLog.create({
      data: {
        masjidId: entry.masjidId,
        actorId: entry.actor?.id ?? null,
        actorName: entry.actor?.fullName ?? 'system',
        action: entry.action,
        entity: entry.entity,
        entityId: entry.entityId,
        summary: entry.summary,
        before: toJson(entry.before),
        after: toJson(entry.after),
      },
    });
    this.logger.debug({
      message: 'Audit entry',
      action: entry.action,
      entity: entry.entity,
      entityId: entry.entityId,
    });
  }
}

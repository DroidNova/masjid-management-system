import { Injectable } from '@nestjs/common';
import { AuditEntity } from '../../../common/audit/audit.service';
import { MoneyInput, toAmount } from '../../../common/money';
import { pageArgs, paged } from '../../../common/pagination';
import { requireMasjidId } from '../../../common/tenant';
import { Prisma } from '../../../generated/prisma/client';
import { PrismaService } from '../../../prisma/prisma.service';
import { AuthenticatedUser } from '../../platform-core/auth/types/jwt-payload.type';

export const NOTIFICATION_KIND = {
  /** Money was recorded in this person's name. */
  PAYMENT_RECORDED: 'PAYMENT_RECORDED',
  /** An entry recorded in their name was edited. */
  PAYMENT_CHANGED: 'PAYMENT_CHANGED',
  /** An entry recorded in their name was cancelled. */
  PAYMENT_CANCELLED: 'PAYMENT_CANCELLED',
} as const;

export type NotificationKind =
  (typeof NOTIFICATION_KIND)[keyof typeof NOTIFICATION_KIND];

/** What the money was for, so the app can say it in the reader's language. */
export type PaymentFor =
  | { purpose: 'SALARY'; month: number; year: number }
  | { purpose: 'PROJECT'; projectTitle: string }
  | { purpose: 'DONATION'; collectionType: string };

export type PaymentNotice = {
  masjidId: string;
  /** The member the payment belongs to; null (no member) sends nothing. */
  memberId: string | null;
  actor: { id: string; fullName: string };
  kind: NotificationKind;
  /** The record to open from the notification (an AuditLog entity). */
  entity: AuditEntity;
  entityId: string;
  amount: MoneyInput;
  /** PAYMENT_CHANGED only: the amount after the edit, if it changed. */
  newAmount?: MoneyInput;
  paymentFor: PaymentFor;
};

const notificationSelect = {
  id: true,
  kind: true,
  entity: true,
  entityId: true,
  actorName: true,
  data: true,
  readAt: true,
  createdAt: true,
} satisfies Prisma.NotificationSelect;

/**
 * In-app notices (the bell). Money recorded, changed or cancelled in a
 * member's name tells that member, so nobody can quietly record a wrong
 * amount or cancel an entry. Call `paymentNotice` inside the same
 * transaction as the change (pass `tx`).
 */
@Injectable()
export class NotificationsService {
  constructor(private readonly prisma: PrismaService) {}

  async paymentNotice(
    notice: PaymentNotice,
    db: Prisma.TransactionClient = this.prisma,
  ): Promise<void> {
    // Nobody to tell, or they did it themselves.
    if (!notice.memberId || notice.memberId === notice.actor.id) return;
    const changedAmount =
      notice.newAmount === undefined
        ? {}
        : { newAmount: toAmount(notice.newAmount) };
    await db.notification.create({
      data: {
        masjidId: notice.masjidId,
        userId: notice.memberId,
        kind: notice.kind,
        entity: notice.entity,
        entityId: notice.entityId,
        actorName: notice.actor.fullName,
        data: {
          amount: toAmount(notice.amount),
          ...changedAmount,
          ...notice.paymentFor,
        },
      },
    });
  }

  /** The signed-in person's notices, newest first. */
  async listMine(
    query: { page?: number; limit?: number },
    actor: AuthenticatedUser,
  ) {
    const where = this.mine(actor);
    const { page, limit, skip, take } = pageArgs(query);
    const [items, total] = await this.prisma.$transaction([
      this.prisma.notification.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip,
        take,
        select: notificationSelect,
      }),
      this.prisma.notification.count({ where }),
    ]);
    return paged(items, total, page, limit);
  }

  async unreadCount(actor: AuthenticatedUser) {
    const count = await this.prisma.notification.count({
      where: { ...this.mine(actor), readAt: null },
    });
    return { count };
  }

  async markAllRead(actor: AuthenticatedUser) {
    const { count } = await this.prisma.notification.updateMany({
      where: { ...this.mine(actor), readAt: null },
      data: { readAt: new Date() },
    });
    return { marked: count };
  }

  /**
   * Deletes notices nobody needs any more: read ones after a year, unread
   * ones after two (someone who never opens the app). The record and its
   * history stay; only the bell entry goes.
   */
  async deleteOld(now = new Date()): Promise<number> {
    const yearsAgo = (years: number) => {
      const date = new Date(now);
      date.setFullYear(date.getFullYear() - years);
      return date;
    };
    const { count } = await this.prisma.notification.deleteMany({
      where: {
        OR: [
          { readAt: { not: null }, createdAt: { lt: yearsAgo(1) } },
          { createdAt: { lt: yearsAgo(2) } },
        ],
      },
    });
    return count;
  }

  /** Only this person's notices, and only for the masjid they are in now. */
  private mine(actor: AuthenticatedUser): Prisma.NotificationWhereInput {
    return { userId: actor.id, masjidId: requireMasjidId(actor) };
  }
}

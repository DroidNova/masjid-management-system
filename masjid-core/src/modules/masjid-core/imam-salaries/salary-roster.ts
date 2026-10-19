import { Prisma } from '../../../generated/prisma/client';
import {
  ImamSalaryAssignmentStatus,
  RoleName,
  UserStatus,
} from '../../../generated/prisma/enums';
import { money, nonNegative, sumMoney } from '../../../common/money';

/**
 * Keeps salary months in step with who the family heads are.
 *
 * A salary month is created with one assignment per active family head. Without
 * this, a person added (or marked as family head, or re-activated) after the
 * month was created never appears in it, and a person who leaves or is
 * deactivated stays "unpaid" forever.
 *
 * Rule: only the current month (India time) and later months change. Past
 * months are history and stay as they are. An assignment that already has a
 * payment is never removed.
 */

/** India has no daylight saving, so a fixed +5:30 offset is exact. */
const INDIA_OFFSET_MS = (5 * 60 + 30) * 60 * 1000;

/** Current month and year in India, as 1-12 and a full year. */
export function currentIndiaMonth(now: Date = new Date()): {
  month: number;
  year: number;
} {
  const india = new Date(now.getTime() + INDIA_OFFSET_MS);
  return { month: india.getUTCMonth() + 1, year: india.getUTCFullYear() };
}

/** Prisma filter for salary months from the current month onward. */
function currentAndLaterMonths(): Prisma.ImamSalaryMonthWhereInput {
  const { month, year } = currentIndiaMonth();
  return {
    OR: [{ year: { gt: year } }, { year, month: { gte: month } }],
  };
}

/**
 * Adds or removes this user's assignments in the current and later salary
 * months so they match the user's state now. Call inside the transaction that
 * changed the user. Returns how many assignments were added and removed.
 */
export async function syncSalaryRoster(
  tx: Prisma.TransactionClient,
  userId: string,
): Promise<{ added: number; removed: number }> {
  const user = await tx.user.findUnique({
    where: { id: userId },
    select: {
      id: true,
      fullName: true,
      phone: true,
      masjidId: true,
      status: true,
      isFamilyHead: true,
      userRoles: { select: { role: { select: { name: true } } } },
    },
  });
  if (!user) return { added: 0, removed: 0 };

  const eligible =
    user.masjidId !== null &&
    user.status === UserStatus.ACTIVE &&
    user.isFamilyHead &&
    user.userRoles.some(({ role }) => role.name === RoleName.MEMBER);

  const touched = new Set<string>();

  // Remove untouched assignments that no longer belong: any masjid when not
  // eligible, or another masjid than the user's own.
  const stale = await tx.imamSalaryAssignment.findMany({
    where: {
      memberId: user.id,
      paidAmount: 0,
      status: ImamSalaryAssignmentStatus.UNPAID,
      imamSalaryMonth: currentAndLaterMonths(),
      ...(eligible ? { masjidId: { not: user.masjidId! } } : {}),
    },
    select: { id: true, imamSalaryMonthId: true },
  });
  if (stale.length) {
    await tx.imamSalaryAssignment.deleteMany({
      where: { id: { in: stale.map((row) => row.id) } },
    });
    stale.forEach((row) => touched.add(row.imamSalaryMonthId));
  }

  let added = 0;
  if (eligible) {
    const missing = await tx.imamSalaryMonth.findMany({
      where: {
        masjidId: user.masjidId!,
        ...currentAndLaterMonths(),
        assignments: { none: { memberId: user.id } },
      },
      select: { id: true, amountPerHead: true },
    });
    if (missing.length) {
      const result = await tx.imamSalaryAssignment.createMany({
        data: missing.map((month) => ({
          masjidId: user.masjidId!,
          imamSalaryMonthId: month.id,
          memberId: user.id,
          memberName: user.fullName,
          memberPhone: user.phone ?? '',
          expectedAmount: month.amountPerHead,
          dueAmount: month.amountPerHead,
        })),
        skipDuplicates: true,
      });
      added = result.count;
      missing.forEach((month) => touched.add(month.id));
    }
  }

  for (const monthId of touched) await recomputeSalaryMonth(tx, monthId);
  return { added, removed: stale.length };
}

/**
 * Rewrites a month's totals, counts and status from its assignments. Used
 * after people are added to or removed from a month.
 */
export async function recomputeSalaryMonth(
  tx: Prisma.TransactionClient,
  monthId: string,
): Promise<void> {
  const rows = await tx.imamSalaryAssignment.findMany({
    where: { imamSalaryMonthId: monthId },
    select: { expectedAmount: true, paidAmount: true, status: true },
  });
  const expected = sumMoney(rows.map((row) => row.expectedAmount));
  const collected = sumMoney(rows.map((row) => row.paidAmount));
  const count = (status: ImamSalaryAssignmentStatus) =>
    rows.filter((row) => row.status === status).length;

  let status: ImamSalaryAssignmentStatus = ImamSalaryAssignmentStatus.UNPAID;
  if (collected.greaterThan(0))
    status = collected.greaterThanOrEqualTo(expected)
      ? ImamSalaryAssignmentStatus.PAID
      : ImamSalaryAssignmentStatus.PARTIAL;

  await tx.imamSalaryMonth.update({
    where: { id: monthId },
    data: {
      totalExpected: expected,
      totalCollected: collected,
      totalDue: nonNegative(money(expected).minus(collected)),
      paidCount: count(ImamSalaryAssignmentStatus.PAID),
      partialCount: count(ImamSalaryAssignmentStatus.PARTIAL),
      unpaidCount: count(ImamSalaryAssignmentStatus.UNPAID),
      status,
    },
    select: { id: true },
  });
}

/**
 * Date-range helpers shared by the masjid-level list endpoints
 * (collections, expenses, contributions).
 *
 * `toDate` is inclusive: "to 2026-06-30" means up to the end of that day
 * (23:59:59.999 UTC), so a date-only value from a date picker still matches
 * entries made later that day.
 */

/** The last millisecond (UTC) of the day `value` falls on. */
export function endOfDay(value: string): Date {
  const date = new Date(value);
  date.setUTCHours(23, 59, 59, 999);
  return date;
}

/** `{ gte, lte }` for a Prisma DateTime filter, or undefined when neither is set. */
export function dateRange(
  fromDate?: string,
  toDate?: string,
): { gte?: Date; lte?: Date } | undefined {
  if (!fromDate && !toDate) return undefined;
  return {
    ...(fromDate ? { gte: new Date(fromDate) } : {}),
    ...(toDate ? { lte: endOfDay(toDate) } : {}),
  };
}

import { Prisma } from '../generated/prisma/client';

/**
 * Money helpers.
 *
 * Amounts are stored as Decimal(12,2). Do all arithmetic with Prisma.Decimal
 * (exact) and convert to a JS number only when building an API response.
 * Never add or subtract money as JS numbers: 0.1 + 0.2 !== 0.3.
 */

export type Money = Prisma.Decimal;
export type MoneyInput = Prisma.Decimal.Value | null | undefined;

export const ZERO: Money = new Prisma.Decimal(0);

/** Converts a DTO number, a string or a Decimal to a Decimal. null/undefined → 0. */
export function money(value: MoneyInput): Money {
  if (value === null || value === undefined) return ZERO;
  return value instanceof Prisma.Decimal ? value : new Prisma.Decimal(value);
}

/** Exact sum of amounts. */
export function sumMoney(values: Iterable<MoneyInput>): Money {
  let total = ZERO;
  for (const value of values) total = total.plus(money(value));
  return total;
}

/** For API responses: a plain number rounded to 2 decimals (paise). */
export function toAmount(value: MoneyInput): number {
  return money(value).toDecimalPlaces(2).toNumber();
}

/** Like toAmount but keeps null for optional amounts. */
export function toAmountOrNull(value: MoneyInput): number | null {
  return value === null || value === undefined ? null : toAmount(value);
}

/** max(value, 0), for "due" amounts that must never go negative. */
export function nonNegative(value: Money): Money {
  return value.isNegative() ? ZERO : value;
}

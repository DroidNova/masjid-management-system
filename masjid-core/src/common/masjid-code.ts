import { randomInt } from 'node:crypto';
import { Prisma } from '../generated/prisma/client';

/**
 * Public masjid codes: 6 characters people type or read out ("K7M 2QX").
 * No look-alikes (0/O, 1/I/L), so a code read from a poster or WhatsApp is
 * typed right. 31^6 ≈ 887 million codes. The migration
 * 20261020150000_public_masjid_pages uses the same alphabet.
 */
const ALPHABET = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
const LENGTH = 6;

export function randomMasjidCode(): string {
  let code = '';
  for (let i = 0; i < LENGTH; i++) code += ALPHABET[randomInt(ALPHABET.length)];
  return code;
}

/** "k7m-2qx " → "K7M2QX"; null when it cannot be a code. */
export function normalizeMasjidCode(input: string): string | null {
  const code = input.toUpperCase().replace(/[\s-]/g, '');
  if (code.length !== LENGTH) return null;
  return [...code].every((char) => ALPHABET.includes(char)) ? code : null;
}

/** A code no masjid has yet. */
export async function uniqueMasjidCode(
  db: Prisma.TransactionClient,
): Promise<string> {
  for (;;) {
    const code = randomMasjidCode();
    const taken = await db.masjid.findUnique({
      where: { publicCode: code },
      select: { id: true },
    });
    if (!taken) return code;
  }
}

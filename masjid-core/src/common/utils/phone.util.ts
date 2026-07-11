import { BadRequestException } from '@nestjs/common';

export function normalizePhone(input: string, defaultCountryCode = '+91'): string {
  if (typeof input !== 'string') throw new BadRequestException('Phone is required');
  const trimmed = input.trim();
  if (!trimmed) throw new BadRequestException('Phone is required');

  const compact = trimmed.replace(/[\s\-()]/g, '');
  let normalized: string;

  if (compact.startsWith('+')) {
    normalized = `+${compact.slice(1).replace(/\D/g, '')}`;
  } else if (compact.startsWith('00')) {
    normalized = `+${compact.slice(2).replace(/\D/g, '')}`;
  } else {
    const digits = compact.replace(/\D/g, '');
    normalized = digits.length === 10 ? `${defaultCountryCode}${digits}` : digits;
  }

  assertValidPhone(normalized);
  return normalized;
}

export function getPhoneSearchVariants(input: string): string[] {
  const variants = new Set<string>();
  const normalized = normalizePhone(input);
  variants.add(normalized);

  if (normalized.startsWith('+91') && normalized.length === 13) {
    variants.add(normalized.slice(3));
  }

  const digits = String(input ?? '').replace(/\D/g, '');
  if (digits.length === 10) variants.add(digits);

  return Array.from(variants);
}

function assertValidPhone(phone: string): void {
  if (/^\+\d{6,15}$/.test(phone)) return;
  if (/^\d{10}$/.test(phone)) return;
  throw new BadRequestException('Enter a valid phone number');
}

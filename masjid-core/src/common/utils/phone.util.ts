export function normalizePhone(input: string, defaultCountryCode = '+91'): string {
  if (typeof input !== 'string') return '';
  const trimmed = input.trim();
  if (!trimmed) return '';

  const startsWithPlus = trimmed.startsWith('+');
  const digits = trimmed.replace(/\D/g, '');
  if (!digits) return '';

  if (startsWithPlus) return `+${digits}`;
  if (trimmed.startsWith('00')) return `+${digits.slice(2)}`;
  if (digits.length === 10) return `${defaultCountryCode}${digits}`;
  return digits === trimmed ? digits : `+${digits}`;
}

export function getPhoneSearchVariants(input: string): string[] {
  const normalized = normalizePhone(input);
  const variants = new Set<string>();
  if (normalized) variants.add(normalized);
  const rawDigits = typeof input === 'string' ? input.replace(/\D/g, '') : '';
  if (rawDigits.length === 10) variants.add(rawDigits);
  if (normalized.startsWith('+91') && normalized.length === 13) {
    variants.add(normalized.slice(3));
  }
  return [...variants];
}

export function isValidNormalizedPhone(phone: string): boolean {
  if (/^\+\d{6,15}$/.test(phone)) return true;
  if (/^\d{10}$/.test(phone)) return true;
  return false;
}

import { randomBytes } from 'node:crypto';
import { AppConfig } from '../../../config/app-config';

export type InitialPassword = {
  password: string;
  /** True when the password is the known dev password and may be shown to the creator. */
  disclosable: boolean;
};

/**
 * Password given to a newly created imam or committee member.
 *
 * Dev mode: AUTH_DEV_PASSWORD (123456), so testers can log in straight away.
 * Otherwise: a random secret nobody knows. The user will set their own
 * password through the OTP reset flow added in milestone M6.
 */
export function initialPasswordFor(config: AppConfig): InitialPassword {
  if (config.auth.devMode) {
    return { password: config.auth.devPassword, disclosable: true };
  }
  return { password: randomBytes(32).toString('hex'), disclosable: false };
}

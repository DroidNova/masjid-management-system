import {
  Injectable,
  Logger,
  OnApplicationBootstrap,
  OnApplicationShutdown,
} from '@nestjs/common';
import { AppConfig } from '../../../../config/app-config';
import { AuthService } from '../auth.service';
import { OtpService } from './otp.service';

const HOUR_MS = 60 * 60 * 1000;

/**
 * Deletes expired sessions and stale OTP challenges once an hour. A plain
 * interval keeps us off an extra scheduling dependency; we run one API
 * container, so there is no risk of several instances racing.
 */
@Injectable()
export class AuthCleanupService
  implements OnApplicationBootstrap, OnApplicationShutdown
{
  private readonly logger = new Logger(AuthCleanupService.name);
  private timer: NodeJS.Timeout | undefined;

  constructor(
    private readonly authService: AuthService,
    private readonly otpService: OtpService,
    private readonly config: AppConfig,
  ) {}

  onApplicationBootstrap(): void {
    if (this.config.isTest) return;
    this.timer = setInterval(() => void this.runOnce(), HOUR_MS);
    this.timer.unref();
    void this.runOnce();
  }

  onApplicationShutdown(): void {
    if (this.timer) clearInterval(this.timer);
  }

  async runOnce(): Promise<void> {
    try {
      const [sessions, otps] = await Promise.all([
        this.authService.deleteExpiredSessions(),
        this.otpService.deleteStale(),
      ]);
      if (sessions || otps) {
        this.logger.log({
          message: 'Auth cleanup finished',
          expiredSessions: sessions,
          staleOtpChallenges: otps,
        });
      }
    } catch (error) {
      this.logger.error({
        message: 'Auth cleanup failed',
        error: (error as Error).message,
      });
    }
  }
}

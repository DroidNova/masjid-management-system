import {
  Injectable,
  Logger,
  OnApplicationBootstrap,
  OnApplicationShutdown,
} from '@nestjs/common';
import { AppConfig } from '../../../config/app-config';
import { NotificationsService } from './notifications.service';

const DAY_MS = 24 * 60 * 60 * 1000;

/**
 * Deletes old notices once a day (and at start-up), so the table stays
 * small. Same plain-interval approach as AuthCleanupService: one API
 * container, no scheduling dependency.
 */
@Injectable()
export class NotificationsCleanupService
  implements OnApplicationBootstrap, OnApplicationShutdown
{
  private readonly logger = new Logger(NotificationsCleanupService.name);
  private timer: NodeJS.Timeout | undefined;

  constructor(
    private readonly notifications: NotificationsService,
    private readonly config: AppConfig,
  ) {}

  onApplicationBootstrap(): void {
    if (this.config.isTest) return;
    this.timer = setInterval(() => void this.runOnce(), DAY_MS);
    this.timer.unref();
    void this.runOnce();
  }

  onApplicationShutdown(): void {
    if (this.timer) clearInterval(this.timer);
  }

  async runOnce(): Promise<void> {
    try {
      const deleted = await this.notifications.deleteOld();
      if (deleted) {
        this.logger.log({
          message: 'Notifications cleanup finished',
          oldNotifications: deleted,
        });
      }
    } catch (error) {
      this.logger.error({
        message: 'Notifications cleanup failed',
        error: (error as Error).message,
      });
    }
  }
}

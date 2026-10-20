import { Global, Module } from '@nestjs/common';
import { NotificationsController } from './notifications.controller';
import { NotificationsCleanupService } from './notifications-cleanup.service';
import { NotificationsService } from './notifications.service';

/** Global so every money service can write a notice in its transaction. */
@Global()
@Module({
  controllers: [NotificationsController],
  providers: [NotificationsService, NotificationsCleanupService],
  exports: [NotificationsService],
})
export class NotificationsModule {}

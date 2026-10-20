import { Global, Module } from '@nestjs/common';
import { AuditController } from './audit.controller';
import { AuditService } from './audit.service';
import { RecordHistoryService } from './record-history.service';

@Global()
@Module({
  controllers: [AuditController],
  providers: [AuditService, RecordHistoryService],
  exports: [AuditService],
})
export class AuditModule {}

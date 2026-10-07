import { Module } from '@nestjs/common';
import { PrismaModule } from '../../../prisma/prisma.module';
import { MasjidRequestsController } from './masjid-requests.controller';
import { MasjidRequestsService } from './masjid-requests.service';

@Module({
  imports: [PrismaModule],
  controllers: [MasjidRequestsController],
  providers: [MasjidRequestsService],
})
export class MasjidRequestsModule {}

import { Module } from '@nestjs/common';
import { RolesGuard } from '../../../common/guards/roles.guard';
import { PrismaModule } from '../../../prisma/prisma.module';
import { MasjidRequestsController } from './masjid-requests.controller';
import { MasjidRequestsService } from './masjid-requests.service';

@Module({
  imports: [PrismaModule],
  controllers: [MasjidRequestsController],
  providers: [MasjidRequestsService, RolesGuard],
})
export class MasjidRequestsModule {}

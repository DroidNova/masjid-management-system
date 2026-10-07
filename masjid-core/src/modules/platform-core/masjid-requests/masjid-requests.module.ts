import { Module } from '@nestjs/common';
import { PrismaModule } from '../../../prisma/prisma.module';
import { RolesModule } from '../roles/roles.module';
import { MasjidRequestsController } from './masjid-requests.controller';
import { MasjidRequestsService } from './masjid-requests.service';

@Module({
  imports: [PrismaModule, RolesModule],
  controllers: [MasjidRequestsController],
  providers: [MasjidRequestsService],
})
export class MasjidRequestsModule {}

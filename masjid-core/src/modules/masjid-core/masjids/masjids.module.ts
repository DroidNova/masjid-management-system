import { Module } from '@nestjs/common';
import { RolesGuard } from '../../../common/guards/roles.guard';
import { PrismaModule } from '../../../prisma/prisma.module';
import { MasjidsController } from './masjids.controller';
import { MasjidsService } from './masjids.service';

@Module({
  imports: [PrismaModule],
  controllers: [MasjidsController],
  providers: [MasjidsService, RolesGuard],
})
export class MasjidsModule {}

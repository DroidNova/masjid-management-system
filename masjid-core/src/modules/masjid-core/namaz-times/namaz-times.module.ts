import { Module } from '@nestjs/common';
import { RolesGuard } from '../../../common/guards/roles.guard';
import { PrismaModule } from '../../../prisma/prisma.module';
import { NamazTimesController } from './namaz-times.controller';
import { NamazTimesService } from './namaz-times.service';

@Module({
  imports: [PrismaModule],
  controllers: [NamazTimesController],
  providers: [NamazTimesService, RolesGuard],
})
export class NamazTimesModule {}

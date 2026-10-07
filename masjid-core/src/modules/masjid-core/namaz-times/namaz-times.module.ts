import { Module } from '@nestjs/common';
import { PrismaModule } from '../../../prisma/prisma.module';
import { NamazTimesController } from './namaz-times.controller';
import { NamazTimesService } from './namaz-times.service';

@Module({
  imports: [PrismaModule],
  controllers: [NamazTimesController],
  providers: [NamazTimesService],
})
export class NamazTimesModule {}

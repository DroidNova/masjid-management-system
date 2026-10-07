import { Module } from '@nestjs/common';
import { ContributionsModule } from '../contributions/contributions.module';
import { PrismaModule } from '../../../prisma/prisma.module';
import { CollectionsController } from './collections.controller';
import { CollectionsService } from './collections.service';

@Module({
  imports: [PrismaModule, ContributionsModule],
  controllers: [CollectionsController],
  providers: [CollectionsService],
})
export class CollectionsModule {}

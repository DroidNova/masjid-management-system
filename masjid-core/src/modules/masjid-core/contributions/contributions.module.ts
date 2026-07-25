import { Module } from '@nestjs/common';
import { PrismaModule } from '../../../prisma/prisma.module';
import { ContributionTransactionsService } from './contribution-transactions.service';
import { ContributionsController } from './contributions.controller';
import { ContributionsService } from './contributions.service';

@Module({
  imports: [PrismaModule],
  controllers: [ContributionsController],
  providers: [ContributionsService, ContributionTransactionsService],
  exports: [ContributionTransactionsService],
})
export class ContributionsModule {}

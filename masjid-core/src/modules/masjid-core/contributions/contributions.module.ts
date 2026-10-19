import { Module } from '@nestjs/common';
import { PrismaModule } from '../../../prisma/prisma.module';
import { ImamSalariesModule } from '../imam-salaries/imam-salaries.module';
import { ContributionTransactionsService } from './contribution-transactions.service';
import { ContributionsController } from './contributions.controller';
import { ContributionsService } from './contributions.service';

@Module({
  imports: [PrismaModule, ImamSalariesModule],
  controllers: [ContributionsController],
  providers: [ContributionsService, ContributionTransactionsService],
  exports: [ContributionTransactionsService],
})
export class ContributionsModule {}

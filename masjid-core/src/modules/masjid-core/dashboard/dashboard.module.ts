import { Module } from '@nestjs/common';
import { PrismaModule } from '../../../prisma/prisma.module';
import { DashboardController } from './dashboard.controller';
import { DashboardService } from './dashboard.service';
import { FinanceModule } from '../finance/finance.module';
import { ImamSalariesModule } from '../imam-salaries/imam-salaries.module';

@Module({
  imports: [PrismaModule, FinanceModule, ImamSalariesModule],
  controllers: [DashboardController],
  providers: [DashboardService],
})
export class DashboardModule {}

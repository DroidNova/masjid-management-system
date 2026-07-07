import { Module } from '@nestjs/common';
import { RolesGuard } from '../../../common/guards/roles.guard';
import { PrismaModule } from '../../../prisma/prisma.module';
import { ImamSalariesController } from './imam-salaries.controller';
import { ImamSalariesService } from './imam-salaries.service';

@Module({
  imports: [PrismaModule],
  controllers: [ImamSalariesController],
  providers: [ImamSalariesService, RolesGuard],
})
export class ImamSalariesModule {}

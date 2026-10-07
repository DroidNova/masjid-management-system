import { Module } from '@nestjs/common';
import { PrismaModule } from '../../../prisma/prisma.module';
import { ImamSalariesController } from './imam-salaries.controller';
import { ImamSalariesService } from './imam-salaries.service';

@Module({
  imports: [PrismaModule],
  controllers: [ImamSalariesController],
  providers: [ImamSalariesService],
})
export class ImamSalariesModule {}

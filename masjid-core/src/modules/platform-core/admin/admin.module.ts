import { Module } from '@nestjs/common';
import { PrismaModule } from '../../../prisma/prisma.module';
import { RolesModule } from '../roles/roles.module';
import {
  AdminController,
  AdminDashboardController,
  AdminMasjidsController,
} from './admin.controller';
import { AdminService } from './admin.service';

@Module({
  imports: [PrismaModule, RolesModule],
  controllers: [
    AdminController,
    AdminDashboardController,
    AdminMasjidsController,
  ],
  providers: [AdminService],
  exports: [AdminService],
})
export class AdminModule {}

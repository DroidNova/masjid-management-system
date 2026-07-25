import { Module } from '@nestjs/common';
import { RolesGuard } from '../../../common/guards/roles.guard';
import { ContributionsModule } from '../contributions/contributions.module';
import { PrismaModule } from '../../../prisma/prisma.module';
import { ProjectsController } from './projects.controller';
import { ProjectsService } from './projects.service';

@Module({
  imports: [PrismaModule, ContributionsModule],
  controllers: [ProjectsController],
  providers: [ProjectsService, RolesGuard],
})
export class ProjectsModule {}

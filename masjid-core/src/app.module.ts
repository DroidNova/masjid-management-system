import { Module } from '@nestjs/common';
import { AdminModule } from './modules/platform-core/admin/admin.module';
import { AnnouncementsModule } from './modules/masjid-core/announcements/announcements.module';
import { AuthModule } from './modules/platform-core/auth/auth.module';
import { DashboardModule } from './modules/masjid-core/dashboard/dashboard.module';
import { FinanceModule } from './modules/masjid-core/finance/finance.module';
import { ExpensesModule } from './modules/masjid-core/expenses/expenses.module';
import { CollectionsModule } from './modules/masjid-core/collections/collections.module';
import { MasjidsModule } from './modules/masjid-core/masjids/masjids.module';
import { NamazTimesModule } from './modules/masjid-core/namaz-times/namaz-times.module';
import { ProjectsModule } from './modules/masjid-core/projects/projects.module';
import { HealthModule } from './modules/platform-core/health/health.module';
import { ImamSalariesModule } from './modules/masjid-core/imam-salaries/imam-salaries.module';
import { MasjidRequestsModule } from './modules/platform-core/masjid-requests/masjid-requests.module';
import { PermissionsModule } from './modules/platform-core/permissions/permissions.module';
import { RolesModule } from './modules/platform-core/roles/roles.module';
import { SessionsModule } from './modules/platform-core/sessions/sessions.module';
import { SettingsModule } from './modules/platform-core/settings/settings.module';
import { UsersModule } from './modules/platform-core/users/users.module';
import { PrismaModule } from './prisma/prisma.module';

@Module({
  imports: [
    PrismaModule,
    AdminModule,
    AuthModule,
    HealthModule,
    ImamSalariesModule,
    AnnouncementsModule,
    DashboardModule,
    FinanceModule,
    ExpensesModule,
    CollectionsModule,
    MasjidRequestsModule,
    MasjidsModule,
    NamazTimesModule,
    ProjectsModule,
    PermissionsModule,
    RolesModule,
    SessionsModule,
    SettingsModule,
    UsersModule,
  ],
})
export class AppModule {}

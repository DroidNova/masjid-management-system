import { Module } from '@nestjs/common';
import { LoggerModule } from 'nestjs-pino';
import { AdminModule } from './modules/platform-core/admin/admin.module';
import { AnnouncementsModule } from './modules/masjid-core/announcements/announcements.module';
import { AuthModule } from './modules/platform-core/auth/auth.module';
import { DashboardModule } from './modules/masjid-core/dashboard/dashboard.module';
import { FinanceModule } from './modules/masjid-core/finance/finance.module';
import { ExpensesModule } from './modules/masjid-core/expenses/expenses.module';
import { ContributionsModule } from './modules/masjid-core/contributions/contributions.module';
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
import { HttpExceptionFilter } from './common/filters/http-exception.filter';
import { getLogUser } from './common/utils/log-user.util';
import { getOrCreateRequestId } from './common/utils/request-id.util';

const isProduction = process.env.NODE_ENV === 'production';
const logLevel = process.env.LOG_LEVEL ?? (isProduction ? 'info' : 'debug');

@Module({
  imports: [
    LoggerModule.forRoot({
      pinoHttp: {
        level: logLevel,
        genReqId: (req, res) => {
          const requestId = getOrCreateRequestId(req);
          res.setHeader('x-request-id', requestId);
          return requestId;
        },
        transport:
          !isProduction
            ? {
                target: 'pino-pretty',
                options: {
                  singleLine: true,
                  colorize: true,
                  translateTime: 'SYS:standard',
                  ignore: 'pid,hostname',
                },
              }
            : undefined,
        redact: {
          paths: [
            'req.headers.authorization',
            'req.headers.cookie',
            'req.body.password',
            'req.body.passwordHash',
            'req.body.otp',
            'req.body.accessToken',
            'req.body.refreshToken',
            'req.body.token',
            'req.body.refreshTokenHash',
            'res.headers["set-cookie"]',
          ],
          censor: '[REDACTED]',
        },
        customProps: (req) => ({
          requestId: req.id,
          ...getLogUser(req),
        }),
        customSuccessObject: (req, res, value) => ({
          ...value,
          requestId: req.id,
          method: req.method,
          url: req.url,
          statusCode: res.statusCode,
          responseTime: (value as { responseTime?: number }).responseTime,
          ...getLogUser(req),
        }),
        customErrorObject: (req, res, error, value) => ({
          ...value,
          requestId: req.id,
          method: req.method,
          url: req.url,
          statusCode: res.statusCode,
          responseTime: (value as { responseTime?: number }).responseTime,
          errorCode: (error as { code?: string } | undefined)?.code,
          message: error?.message,
          ...getLogUser(req),
        }),
      },
    }),
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
    ContributionsModule,
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
  providers: [HttpExceptionFilter],
})
export class AppModule {}

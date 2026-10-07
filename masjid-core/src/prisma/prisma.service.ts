import {
  Injectable,
  Logger,
  OnModuleDestroy,
  OnModuleInit,
} from '@nestjs/common';
import { PrismaPg } from '@prisma/adapter-pg';
import { Prisma, PrismaClient } from '../generated/prisma/client';
import { AppConfig } from '../config/app-config';

@Injectable()
export class PrismaService
  extends PrismaClient
  implements OnModuleInit, OnModuleDestroy
{
  private readonly logger = new Logger(PrismaService.name);

  constructor(config: AppConfig) {
    const adapter = new PrismaPg({ connectionString: config.databaseUrl });
    const log: Prisma.LogLevel[] = config.prismaLogQueries
      ? ['query', 'warn', 'error']
      : ['warn', 'error'];

    super({ adapter, log });
  }

  async onModuleInit(): Promise<void> {
    await this.$connect();
    this.logger.log('Database connection established');
  }

  async onModuleDestroy(): Promise<void> {
    await this.$disconnect();
  }

  /** Cheap round trip used by the health check. */
  async ping(): Promise<void> {
    await this.$queryRaw`SELECT 1`;
  }
}

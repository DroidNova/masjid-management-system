import { Injectable, Logger, OnModuleDestroy, OnModuleInit } from '@nestjs/common';
import { PrismaPg } from '@prisma/adapter-pg';
import { Prisma, PrismaClient } from '../generated/prisma/client';

@Injectable()
export class PrismaService
  extends PrismaClient
  implements OnModuleInit, OnModuleDestroy
{
  private readonly logger = new Logger(PrismaService.name);

  constructor() {
    const databaseUrl = process.env.DATABASE_URL;

    if (!databaseUrl) {
      throw new Error('DATABASE_URL is required to initialize PrismaService');
    }

    const adapter = new PrismaPg({ connectionString: databaseUrl });
    const isDevelopment = process.env.NODE_ENV !== 'production';
    const shouldLogQueries =
      isDevelopment && process.env.PRISMA_LOG_QUERIES === 'true';
    const log: Prisma.LogLevel[] = shouldLogQueries
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
}

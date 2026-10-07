import { HttpStatus, Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../../../prisma/prisma.service';
import { ApiException } from '../../../common/exceptions/api.exception';
import { ERROR_CODES } from '../../../common/constants/error-codes.constant';

@Injectable()
export class HealthService {
  private readonly logger = new Logger(HealthService.name);

  constructor(private readonly prisma: PrismaService) {}

  /** Returns 200 only when the API can reach the database; 503 otherwise. */
  async getHealth() {
    try {
      await this.prisma.ping();
    } catch (error) {
      this.logger.error({
        message: 'Health check: database unreachable',
        error: (error as Error).message,
      });
      throw new ApiException(
        'Database is unreachable',
        HttpStatus.SERVICE_UNAVAILABLE,
        ERROR_CODES.SERVICE_UNAVAILABLE,
      );
    }

    return { status: 'ok', database: 'up' };
  }
}

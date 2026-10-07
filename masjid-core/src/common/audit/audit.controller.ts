import {
  Controller,
  Get,
  HttpStatus,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiPropertyOptional,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsIn, IsInt, IsOptional, Max, Min } from 'class-validator';
import { Request } from 'express';
import { PERMISSIONS } from '../../access/permissions';
import { RequirePermissions } from '../../access/require-permissions';
import { JwtAuthGuard } from '../../modules/platform-core/auth/guards/jwt-auth.guard';
import { AuthenticatedUser } from '../../modules/platform-core/auth/types/jwt-payload.type';
import { PrismaService } from '../../prisma/prisma.service';
import { requireMasjidId } from '../tenant';
import { AUDIT_ENTITY } from './audit.service';

export class AuditLogQueryDto {
  @ApiPropertyOptional({ enum: Object.values(AUDIT_ENTITY) })
  @IsOptional()
  @IsIn(Object.values(AUDIT_ENTITY))
  entity?: string;

  @ApiPropertyOptional({ minimum: 1, default: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number;

  @ApiPropertyOptional({ minimum: 1, maximum: 100, default: 20 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number;
}

@ApiTags('Audit log')
@ApiBearerAuth('bearer')
@UseGuards(JwtAuthGuard)
@Controller('audit-log')
export class AuditController {
  constructor(private readonly prisma: PrismaService) {}

  @Get('my-masjid')
  @RequirePermissions(PERMISSIONS.AUDIT_READ)
  @ApiOperation({
    summary: "Who changed what in the current user's masjid, newest first",
  })
  @ApiResponse({ status: HttpStatus.OK })
  async findMyMasjidLog(
    @Req() req: Request & { user: AuthenticatedUser },
    @Query() query: AuditLogQueryDto,
  ) {
    const masjidId = requireMasjidId(req.user);
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const where = { masjidId, entity: query.entity };

    const [items, total] = await this.prisma.$transaction([
      this.prisma.auditLog.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      this.prisma.auditLog.count({ where }),
    ]);

    return {
      items,
      meta: { page, limit, total, totalPages: Math.ceil(total / limit) },
    };
  }
}

import { ApiPropertyOptional } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import {
  IsEnum,
  IsIn,
  IsInt,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  Min,
} from 'class-validator';
import { UserStatus } from '../../../../generated/prisma/enums';
import { ROLE_NAMES } from '../../../../access/permissions';

export class ListAdminUsersDto {
  @ApiPropertyOptional({ example: 1, minimum: 1 })
  @IsOptional()
  @Transform(({ value }: { value: unknown }) => Number(value))
  @IsInt()
  @Min(1)
  page?: number = 1;

  @ApiPropertyOptional({ example: 10, minimum: 1, maximum: 100 })
  @IsOptional()
  @Transform(({ value }: { value: unknown }) => Number(value))
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number = 10;

  @ApiPropertyOptional({ example: 'alex' })
  @IsOptional()
  @IsString()
  search?: string;

  @ApiPropertyOptional({ enum: UserStatus, example: 'ACTIVE' })
  @IsOptional()
  @IsEnum(UserStatus)
  status?: UserStatus;

  @ApiPropertyOptional({ enum: ROLE_NAMES, example: 'IMAM' })
  @IsOptional()
  @IsIn(ROLE_NAMES)
  role?: string;

  @ApiPropertyOptional({ example: '4e0798d2-3fd3-4caa-9966-9f85c96f8b2f' })
  @IsOptional()
  @IsUUID()
  masjidId?: string;
}

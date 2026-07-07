import { ApiPropertyOptional } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import {
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  Min,
} from 'class-validator';

export enum MasjidRequestStatusQueryDto {
  PENDING = 'PENDING',
  APPROVED = 'APPROVED',
  REJECTED = 'REJECTED',
}

const trimString = ({ value }: { value: unknown }) =>
  typeof value === 'string' ? value.trim() : value;

export class GetMasjidRequestsQueryDto {
  @ApiPropertyOptional({ enum: MasjidRequestStatusQueryDto })
  @IsOptional()
  @IsEnum(MasjidRequestStatusQueryDto)
  status?: MasjidRequestStatusQueryDto;

  @ApiPropertyOptional({ example: 'jama' })
  @Transform(trimString)
  @IsOptional()
  @IsString()
  search?: string;

  @ApiPropertyOptional({ example: '4e0798d2-3fd3-4caa-9966-9f85c96f8b2f' })
  @Transform(trimString)
  @IsOptional()
  @IsUUID('4')
  id?: string;

  @ApiPropertyOptional({ example: 'Jama Masjid' })
  @Transform(trimString)
  @IsOptional()
  @IsString()
  masjidName?: string;

  @ApiPropertyOptional({ example: 'Bhopal' })
  @Transform(trimString)
  @IsOptional()
  @IsString()
  city?: string;

  @ApiPropertyOptional({ example: 'Bhopal' })
  @Transform(trimString)
  @IsOptional()
  @IsString()
  district?: string;

  @ApiPropertyOptional({ example: 'Madhya Pradesh' })
  @Transform(trimString)
  @IsOptional()
  @IsString()
  state?: string;

  @ApiPropertyOptional({ example: '9876543210' })
  @Transform(trimString)
  @IsOptional()
  @IsString()
  requesterPhone?: string;

  @ApiPropertyOptional({ example: 1, default: 1, minimum: 1 })
  @Transform(({ value }: { value: unknown }) => Number(value))
  @IsOptional()
  @IsInt()
  @Min(1)
  page?: number = 1;

  @ApiPropertyOptional({ example: 20, default: 20, minimum: 1, maximum: 100 })
  @Transform(({ value }: { value: unknown }) => Number(value))
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number = 20;
}

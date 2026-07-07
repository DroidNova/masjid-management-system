import { ApiPropertyOptional } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import {
  IsDateString,
  IsEnum,
  IsNumber,
  IsOptional,
  IsString,
  MaxLength,
  Min,
  MinLength,
} from 'class-validator';
import { ProjectStatusDto } from './create-project.dto';

const trimString = ({ value }: { value: unknown }) =>
  typeof value === 'string' ? value.trim() : value;

const toOptionalNumber = ({ value }: { value: unknown }) => {
  if (value === undefined || value === null || value === '') {
    return undefined;
  }

  return Number(value);
};

const toOptionalDate = ({ value }: { value: unknown }) => {
  if (value === undefined || value === '') {
    return undefined;
  }

  return value;
};

export class UpdateProjectDto {
  @ApiPropertyOptional({ example: 'Updated project title', maxLength: 150 })
  @Transform(trimString)
  @IsOptional()
  @IsString({ message: 'Title must be a string' })
  @MinLength(1, { message: 'Title cannot be empty' })
  @MaxLength(150, { message: 'Title must be 150 characters or less' })
  title?: string;

  @ApiPropertyOptional({ example: 'Updated description', maxLength: 2000 })
  @Transform(trimString)
  @IsOptional()
  @IsString({ message: 'Description must be a string' })
  @MaxLength(2000, { message: 'Description must be 2000 characters or less' })
  description?: string | null;

  @ApiPropertyOptional({ example: 250000, minimum: 0 })
  @Transform(toOptionalNumber)
  @IsOptional()
  @IsNumber({}, { message: 'Target amount must be a number' })
  @Min(0, { message: 'Target amount must be zero or greater' })
  targetAmount?: number;

  @ApiPropertyOptional({ example: 120000, minimum: 0 })
  @Transform(toOptionalNumber)
  @IsOptional()
  @IsNumber({}, { message: 'Collected amount must be a number' })
  @Min(0, { message: 'Collected amount must be zero or greater' })
  collectedAmount?: number;

  @ApiPropertyOptional({ example: 50000, minimum: 0 })
  @Transform(toOptionalNumber)
  @IsOptional()
  @IsNumber({}, { message: 'Spent amount must be a number' })
  @Min(0, { message: 'Spent amount must be zero or greater' })
  spentAmount?: number;

  @ApiPropertyOptional({ enum: ProjectStatusDto })
  @IsOptional()
  @IsEnum(ProjectStatusDto)
  status?: ProjectStatusDto;

  @ApiPropertyOptional({ example: '2026-06-01T00:00:00.000Z' })
  @Transform(toOptionalDate)
  @IsOptional()
  @IsDateString({}, { message: 'Start date must be a valid ISO date string' })
  startDate?: string | null;

  @ApiPropertyOptional({ example: null, nullable: true })
  @Transform(toOptionalDate)
  @IsOptional()
  @IsDateString({}, { message: 'End date must be a valid ISO date string' })
  endDate?: string | null;
}

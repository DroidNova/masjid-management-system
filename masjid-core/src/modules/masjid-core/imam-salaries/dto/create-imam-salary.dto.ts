import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import {
  IsDateString,
  IsEnum,
  IsInt,
  IsNumber,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
} from 'class-validator';

export enum PaymentStatusDto {
  PAID = 'PAID',
  UNPAID = 'UNPAID',
  PARTIAL = 'PARTIAL',
}

const trimString = ({ value }: { value: unknown }) =>
  typeof value === 'string' ? value.trim() : value;

const toOptionalNumber = ({ value }: { value: unknown }) => {
  if (value === undefined || value === null || value === '') {
    return undefined;
  }

  return Number(value);
};

const toRequiredNumber = ({ value }: { value: unknown }) => Number(value);

const toOptionalDate = ({ value }: { value: unknown }) => {
  if (value === undefined || value === null || value === '') {
    return undefined;
  }

  return value;
};

export class CreateImamSalaryDto {
  @ApiProperty({ example: 6, minimum: 1, maximum: 12 })
  @Transform(toRequiredNumber)
  @IsInt({ message: 'Month must be an integer' })
  @Min(1, { message: 'Month must be between 1 and 12' })
  @Max(12, { message: 'Month must be between 1 and 12' })
  month!: number;

  @ApiProperty({ example: 2026, minimum: 1900 })
  @Transform(toRequiredNumber)
  @IsInt({ message: 'Year must be an integer' })
  @Min(1900, { message: 'Year must be valid' })
  year!: number;

  @ApiProperty({ example: 15000, minimum: 0 })
  @Transform(toRequiredNumber)
  @IsNumber({}, { message: 'Salary amount must be a number' })
  @Min(0, { message: 'Salary amount must be zero or greater' })
  salaryAmount!: number;

  @ApiPropertyOptional({ example: 10000, default: 0, minimum: 0 })
  @Transform(toOptionalNumber)
  @IsOptional()
  @IsNumber({}, { message: 'Paid amount must be a number' })
  @Min(0, { message: 'Paid amount must be zero or greater' })
  paidAmount?: number;

  @ApiPropertyOptional({ enum: PaymentStatusDto })
  @IsOptional()
  @IsEnum(PaymentStatusDto)
  status?: PaymentStatusDto;

  @ApiPropertyOptional({ example: '2026-06-10T00:00:00.000Z' })
  @Transform(toOptionalDate)
  @IsOptional()
  @IsDateString({}, { message: 'Paid date must be a valid ISO date string' })
  paidDate?: string;

  @ApiPropertyOptional({
    example: 'Remaining will be paid next week',
    maxLength: 500,
  })
  @Transform(trimString)
  @IsOptional()
  @IsString({ message: 'Note must be a string' })
  @MaxLength(500, { message: 'Note must be 500 characters or less' })
  note?: string;
}

import { ApiPropertyOptional } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import {
  IsDateString,
  IsInt,
  IsNumber,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
} from 'class-validator';
import { PaymentStatusDto } from './create-imam-salary.dto';

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

export class UpdateImamSalaryDto {
  @ApiPropertyOptional({ example: 6, minimum: 1, maximum: 12 })
  @Transform(toOptionalNumber)
  @IsOptional()
  @IsInt({ message: 'Month must be an integer' })
  @Min(1, { message: 'Month must be between 1 and 12' })
  @Max(12, { message: 'Month must be between 1 and 12' })
  month?: number;

  @ApiPropertyOptional({ example: 2026, minimum: 1900 })
  @Transform(toOptionalNumber)
  @IsOptional()
  @IsInt({ message: 'Year must be an integer' })
  @Min(1900, { message: 'Year must be valid' })
  year?: number;

  @ApiPropertyOptional({ example: 15000, minimum: 0 })
  @Transform(toOptionalNumber)
  @IsOptional()
  @IsNumber({}, { message: 'Salary amount must be a number' })
  @Min(0, { message: 'Salary amount must be zero or greater' })
  salaryAmount?: number;

  @ApiPropertyOptional({ example: 15000, minimum: 0 })
  @Transform(toOptionalNumber)
  @IsOptional()
  @IsNumber({}, { message: 'Paid amount must be a number' })
  @Min(0, { message: 'Paid amount must be zero or greater' })
  paidAmount?: number;


  @ApiPropertyOptional({ example: '2026-06-15T00:00:00.000Z', nullable: true })
  @Transform(toOptionalDate)
  @IsOptional()
  @IsDateString({}, { message: 'Paid date must be a valid ISO date string' })
  paidDate?: string | null;

  @ApiPropertyOptional({ example: 'Fully paid', maxLength: 500 })
  @Transform(trimString)
  @IsOptional()
  @IsString({ message: 'Note must be a string' })
  @MaxLength(500, { message: 'Note must be 500 characters or less' })
  note?: string | null;
}

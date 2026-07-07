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
} from 'class-validator';
import {
  ExpenseTypeDto,
  FinanceEntryStatusDto,
  toOptionalDate,
  toOptionalNumber,
  trimString,
} from './create-expense.dto';

export class UpdateExpenseDto {
  @ApiPropertyOptional({ enum: ExpenseTypeDto })
  @IsOptional()
  @IsEnum(ExpenseTypeDto)
  type?: ExpenseTypeDto;

  @ApiPropertyOptional({ example: 3000, minimum: 0 })
  @Transform(toOptionalNumber)
  @IsOptional()
  @IsNumber({}, { message: 'Amount must be a number' })
  @Min(0, { message: 'Amount must be zero or greater' })
  amount?: number;

  @ApiPropertyOptional({ example: 'Fan repair', maxLength: 150 })
  @Transform(trimString)
  @IsOptional()
  @IsString({ message: 'Title must be a string' })
  @MaxLength(150, { message: 'Title must be 150 characters or less' })
  title?: string | null;

  @ApiPropertyOptional({ example: 'Repair work', maxLength: 1000 })
  @Transform(trimString)
  @IsOptional()
  @IsString({ message: 'Description must be a string' })
  @MaxLength(1000, { message: 'Description must be 1000 characters or less' })
  description?: string | null;

  @ApiPropertyOptional({ example: '2026-06-16T00:00:00.000Z' })
  @Transform(toOptionalDate)
  @IsOptional()
  @IsDateString({}, { message: 'Spent date must be a valid ISO date string' })
  spentAt?: string;

  @ApiPropertyOptional({ enum: FinanceEntryStatusDto })
  @IsOptional()
  @IsEnum(FinanceEntryStatusDto)
  status?: FinanceEntryStatusDto;
}

import { ApiPropertyOptional } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import {
  IsDateString,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  Max,
  Min,
} from 'class-validator';
import {
  ExpenseTypeDto,
  FinanceEntryStatusDto,
  toOptionalDate,
  trimString,
} from './create-expense.dto';

const toOptionalNumber = ({ value }: { value: unknown }) =>
  value === undefined || value === null || value === ''
    ? undefined
    : Number(value);

export class GetExpensesQueryDto {
  @ApiPropertyOptional({ enum: ExpenseTypeDto })
  @IsOptional()
  @IsEnum(ExpenseTypeDto)
  type?: ExpenseTypeDto;

  @ApiPropertyOptional({ enum: FinanceEntryStatusDto })
  @IsOptional()
  @IsEnum(FinanceEntryStatusDto)
  status?: FinanceEntryStatusDto;

  @ApiPropertyOptional({ example: '2026-06-01T00:00:00.000Z' })
  @Transform(toOptionalDate)
  @IsOptional()
  @IsDateString({}, { message: 'From date must be a valid ISO date string' })
  fromDate?: string;

  @ApiPropertyOptional({ example: '2026-06-30T23:59:59.999Z' })
  @Transform(toOptionalDate)
  @IsOptional()
  @IsDateString({}, { message: 'To date must be a valid ISO date string' })
  toDate?: string;

  @ApiPropertyOptional({ example: 'bill' })
  @Transform(trimString)
  @IsOptional()
  @IsString()
  search?: string;

  @ApiPropertyOptional({ example: 1, default: 1, minimum: 1 })
  @Transform(toOptionalNumber)
  @IsOptional()
  @IsInt()
  @Min(1)
  page?: number = 1;

  @ApiPropertyOptional({ example: 20, default: 20, minimum: 1, maximum: 100 })
  @Transform(toOptionalNumber)
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number = 20;
}

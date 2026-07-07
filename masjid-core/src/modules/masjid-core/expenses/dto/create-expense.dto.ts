import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
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
import { FinanceEntryStatusDto } from '../../collections/dto/create-collection.dto';

export enum ExpenseTypeDto {
  ELECTRICITY_BILL = 'ELECTRICITY_BILL',
  WATER_BILL = 'WATER_BILL',
  IMAM_SALARY = 'IMAM_SALARY',
  CLEANING = 'CLEANING',
  REPAIR = 'REPAIR',
  CONSTRUCTION = 'CONSTRUCTION',
  OTHER = 'OTHER',
}

const trimString = ({ value }: { value: unknown }) =>
  typeof value === 'string' ? value.trim() : value;

const toRequiredNumber = ({ value }: { value: unknown }) => Number(value);
const toOptionalNumber = ({ value }: { value: unknown }) =>
  value === undefined || value === null || value === ''
    ? undefined
    : Number(value);
const toOptionalDate = ({ value }: { value: unknown }) =>
  value === undefined || value === null || value === '' ? undefined : value;

export class CreateExpenseDto {
  @ApiProperty({ enum: ExpenseTypeDto })
  @IsEnum(ExpenseTypeDto)
  type!: ExpenseTypeDto;

  @ApiProperty({ example: 1200, minimum: 0 })
  @Transform(toRequiredNumber)
  @IsNumber({}, { message: 'Amount must be a number' })
  @Min(0, { message: 'Amount must be zero or greater' })
  amount!: number;

  @ApiPropertyOptional({ example: 'Electricity bill', maxLength: 150 })
  @Transform(trimString)
  @IsOptional()
  @IsString({ message: 'Title must be a string' })
  @MaxLength(150, { message: 'Title must be 150 characters or less' })
  title?: string;

  @ApiPropertyOptional({ example: 'June electricity bill', maxLength: 1000 })
  @Transform(trimString)
  @IsOptional()
  @IsString({ message: 'Description must be a string' })
  @MaxLength(1000, { message: 'Description must be 1000 characters or less' })
  description?: string;

  @ApiPropertyOptional({ example: '2026-06-15T00:00:00.000Z' })
  @Transform(toOptionalDate)
  @IsOptional()
  @IsDateString({}, { message: 'Spent date must be a valid ISO date string' })
  spentAt?: string;
}

export { FinanceEntryStatusDto, toOptionalDate, toOptionalNumber, trimString };

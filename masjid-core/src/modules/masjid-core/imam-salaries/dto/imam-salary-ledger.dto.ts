import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
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
import { PaginationQueryDto } from '../../../../common/dto/pagination-query.dto';

export enum AssignmentStatusDto {
  UNPAID = 'UNPAID',
  PARTIAL = 'PARTIAL',
  PAID = 'PAID',
}
export enum PaymentModeDto {
  CASH = 'CASH',
  ONLINE = 'ONLINE',
}

export class CreateSalaryMonthDto {
  @ApiProperty({ example: 6, minimum: 1, maximum: 12 })
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(12)
  month!: number;

  @ApiProperty({ example: 2026, minimum: 2000, maximum: 2200 })
  @Type(() => Number)
  @IsInt()
  @Min(2000)
  @Max(2200)
  year!: number;

  @ApiProperty({
    example: 600,
    minimum: 0.01,
    description: 'Amount each family head owes for the month (2 decimals).',
  })
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0.01)
  amountPerHead!: number;

  @ApiPropertyOptional({ example: 'Imam salary for June', maxLength: 500 })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  note?: string;
}

export class UpdateSalaryAmountDto {
  @ApiProperty({
    example: 700,
    minimum: 0.01,
    description:
      'New amount per head. Can only be increased, and never below an amount already paid.',
  })
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0.01)
  amountPerHead!: number;

  @ApiPropertyOptional({
    example: 'Salary revised by committee',
    maxLength: 500,
    description: 'Appended to the month note.',
  })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  reason?: string;
}

export class CreateSalaryPaymentDto {
  @ApiProperty({
    example: '3f1c2a4e-8b7d-4c1e-9a2b-5d6e7f8a9b0c',
    description: 'Salary assignment id',
  })
  @IsString()
  assignmentId!: string;

  @ApiProperty({
    example: 250.5,
    minimum: 0.01,
    description: 'Must not exceed the assignment due amount.',
  })
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0.01)
  amount!: number;

  @ApiProperty({ enum: PaymentModeDto, example: PaymentModeDto.CASH })
  @IsEnum(PaymentModeDto)
  paymentMode!: PaymentModeDto;

  @ApiProperty({ example: '2026-06-05T10:30:00.000Z' })
  @IsDateString()
  paidAt!: string;

  @ApiPropertyOptional({ example: 'Paid after Jumma', maxLength: 500 })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  note?: string;
}

export class SalaryMonthsQueryDto extends PaginationQueryDto {
  @ApiPropertyOptional({ example: 6, minimum: 1, maximum: 12 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(12)
  month?: number;

  @ApiPropertyOptional({ example: 2026, minimum: 2000, maximum: 2200 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(2000)
  @Max(2200)
  year?: number;
}

export class SalaryAssignmentsQueryDto extends PaginationQueryDto {
  @ApiPropertyOptional({
    enum: AssignmentStatusDto,
    example: AssignmentStatusDto.PARTIAL,
  })
  @IsOptional()
  @IsEnum(AssignmentStatusDto)
  status?: AssignmentStatusDto;

  @ApiPropertyOptional({
    example: 'Ahmed',
    maxLength: 100,
    description: 'Matches member name (case-insensitive) or phone.',
  })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  search?: string;
}

export class SalaryPaymentsQueryDto extends SalaryMonthsQueryDto {
  @ApiPropertyOptional({ enum: PaymentModeDto, example: PaymentModeDto.CASH })
  @IsOptional()
  @IsEnum(PaymentModeDto)
  paymentMode?: PaymentModeDto;

  @ApiPropertyOptional({
    example: '98765',
    maxLength: 100,
    description: 'Matches member name (case-insensitive) or phone.',
  })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  search?: string;
}

export class MySalaryHistoryQueryDto {
  @ApiPropertyOptional({ example: 6, default: 6, minimum: 1, maximum: 24 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(24)
  monthsBack?: number = 6;
}

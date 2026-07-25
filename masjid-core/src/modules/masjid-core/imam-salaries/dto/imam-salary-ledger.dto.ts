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
  @Type(() => Number) @IsInt() @Min(1) @Max(12) month!: number;
  @Type(() => Number) @IsInt() @Min(2000) @Max(2200) year!: number;
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0.01)
  amountPerHead!: number;
  @IsOptional() @IsString() @MaxLength(500) note?: string;
}
export class UpdateSalaryAmountDto {
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0.01)
  amountPerHead!: number;
  @IsOptional() @IsString() @MaxLength(500) reason?: string;
}
export class CreateSalaryPaymentDto {
  @IsString() assignmentId!: string;
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0.01)
  amount!: number;
  @IsEnum(PaymentModeDto) paymentMode!: PaymentModeDto;
  @IsDateString() paidAt!: string;
  @IsOptional() @IsString() @MaxLength(500) note?: string;
}
export class SalaryMonthsQueryDto extends PaginationQueryDto {
  @IsOptional() @Type(() => Number) @IsInt() @Min(1) @Max(12) month?: number;
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(2000)
  @Max(2200)
  year?: number;
}
export class SalaryAssignmentsQueryDto extends PaginationQueryDto {
  @IsOptional() @IsEnum(AssignmentStatusDto) status?: AssignmentStatusDto;
  @IsOptional() @IsString() @MaxLength(100) search?: string;
}
export class SalaryPaymentsQueryDto extends SalaryMonthsQueryDto {
  @IsOptional() @IsEnum(PaymentModeDto) paymentMode?: PaymentModeDto;
  @IsOptional() @IsString() @MaxLength(100) search?: string;
}
export class MySalaryHistoryQueryDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(24)
  monthsBack?: number = 6;
}

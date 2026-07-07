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

export enum CollectionTypeDto {
  JUMMA_COLLECTION = 'JUMMA_COLLECTION',
  DONATION_BOX = 'DONATION_BOX',
  RAMADAN_FUND = 'RAMADAN_FUND',
  ZAKAT = 'ZAKAT',
  SADAQAH = 'SADAQAH',
  CONSTRUCTION_FUND = 'CONSTRUCTION_FUND',
  OTHER = 'OTHER',
}

export enum FinanceEntryStatusDto {
  ACTIVE = 'ACTIVE',
  CANCELLED = 'CANCELLED',
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

export class CreateCollectionDto {
  @ApiProperty({ enum: CollectionTypeDto })
  @IsEnum(CollectionTypeDto)
  type!: CollectionTypeDto;

  @ApiProperty({ example: 5000, minimum: 0 })
  @Transform(toRequiredNumber)
  @IsNumber({}, { message: 'Amount must be a number' })
  @Min(0, { message: 'Amount must be zero or greater' })
  amount!: number;

  @ApiPropertyOptional({ example: 'Friday collection', maxLength: 150 })
  @Transform(trimString)
  @IsOptional()
  @IsString({ message: 'Title must be a string' })
  @MaxLength(150, { message: 'Title must be 150 characters or less' })
  title?: string;

  @ApiPropertyOptional({
    example: 'Collected after Jumma prayer',
    maxLength: 1000,
  })
  @Transform(trimString)
  @IsOptional()
  @IsString({ message: 'Description must be a string' })
  @MaxLength(1000, { message: 'Description must be 1000 characters or less' })
  description?: string;

  @ApiPropertyOptional({ example: '2026-06-15T00:00:00.000Z' })
  @Transform(toOptionalDate)
  @IsOptional()
  @IsDateString(
    {},
    { message: 'Collected date must be a valid ISO date string' },
  )
  collectedAt?: string;
}

export { toOptionalDate, toOptionalNumber, trimString };

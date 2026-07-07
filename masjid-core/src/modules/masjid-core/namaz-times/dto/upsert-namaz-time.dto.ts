import { ApiPropertyOptional } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import { IsOptional, IsString, MaxLength } from 'class-validator';

const trimString = ({ value }: { value: unknown }) =>
  typeof value === 'string' ? value.trim() : value;

export class UpsertNamazTimeDto {
  @ApiPropertyOptional({ example: '05:00 AM', maxLength: 20 })
  @Transform(trimString)
  @IsOptional()
  @IsString({ message: 'Fajr time must be a string' })
  @MaxLength(20, { message: 'Fajr time must be 20 characters or less' })
  fajr?: string;

  @ApiPropertyOptional({ example: '01:30 PM', maxLength: 20 })
  @Transform(trimString)
  @IsOptional()
  @IsString({ message: 'Zuhr time must be a string' })
  @MaxLength(20, { message: 'Zuhr time must be 20 characters or less' })
  zuhr?: string;

  @ApiPropertyOptional({ example: '05:00 PM', maxLength: 20 })
  @Transform(trimString)
  @IsOptional()
  @IsString({ message: 'Asr time must be a string' })
  @MaxLength(20, { message: 'Asr time must be 20 characters or less' })
  asr?: string;

  @ApiPropertyOptional({ example: '06:45 PM', maxLength: 20 })
  @Transform(trimString)
  @IsOptional()
  @IsString({ message: 'Maghrib time must be a string' })
  @MaxLength(20, { message: 'Maghrib time must be 20 characters or less' })
  maghrib?: string;

  @ApiPropertyOptional({ example: '08:15 PM', maxLength: 20 })
  @Transform(trimString)
  @IsOptional()
  @IsString({ message: 'Isha time must be a string' })
  @MaxLength(20, { message: 'Isha time must be 20 characters or less' })
  isha?: string;

  @ApiPropertyOptional({ example: '01:15 PM', maxLength: 20 })
  @Transform(trimString)
  @IsOptional()
  @IsString({ message: 'Jumma time must be a string' })
  @MaxLength(20, { message: 'Jumma time must be 20 characters or less' })
  jumma?: string;

  @ApiPropertyOptional({
    example: 'Jumma time may change in Ramadan',
    maxLength: 500,
  })
  @Transform(trimString)
  @IsOptional()
  @IsString({ message: 'Note must be a string' })
  @MaxLength(500, { message: 'Note must be 500 characters or less' })
  note?: string;
}

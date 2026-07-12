import { ApiPropertyOptional } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import { IsEmail, IsEnum, IsOptional, IsString, MaxLength, MinLength } from 'class-validator';

const trimString = ({ value }: { value: unknown }) =>
  typeof value === 'string' ? value.trim() : value;
const lowerOptionalEmail = ({ value }: { value: unknown }) =>
  typeof value === 'string' ? value.trim().toLowerCase() || undefined : value;

export enum MasjidUserStatusDto {
  ACTIVE = 'ACTIVE',
  INACTIVE = 'INACTIVE',
  SUSPENDED = 'SUSPENDED',
}

export class UpdateMasjidUserDto {
  @ApiPropertyOptional({ example: 'Ahmed Khan' })
  @Transform(trimString)
  @IsOptional()
  @IsString({ message: 'Full name must be a string' })
  @MinLength(1, { message: 'Full name cannot be empty' })
  @MaxLength(120, { message: 'Full name must be 120 characters or less' })
  fullName?: string;

  @ApiPropertyOptional({ example: '+919876543210' })
  @Transform(trimString)
  @IsOptional()
  @IsString({ message: 'Phone must be a string' })
  @MinLength(1, { message: 'Phone cannot be empty' })
  phone?: string;

  @ApiPropertyOptional({ example: 'member@example.com', nullable: true })
  @Transform(lowerOptionalEmail)
  @IsOptional()
  @IsEmail({}, { message: 'Email must be valid' })
  email?: string;
}

export class UpdateMasjidUserStatusDto {
  @ApiPropertyOptional({ enum: MasjidUserStatusDto, example: MasjidUserStatusDto.ACTIVE })
  @IsEnum(MasjidUserStatusDto, { message: 'Status must be ACTIVE, INACTIVE, or SUSPENDED' })
  status!: MasjidUserStatusDto;
}

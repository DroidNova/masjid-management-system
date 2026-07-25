import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import {
  IsBoolean,
  IsEmail,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
  MinLength,
} from 'class-validator';
import { GenderDto } from './create-masjid-user.dto';

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
  @ApiProperty({ example: 'Ahmed Khan' })
  @Transform(trimString)
  @IsString({ message: 'Full name must be a string' })
  @MinLength(1, { message: 'Full name cannot be empty' })
  @MaxLength(120, { message: 'Full name must be 120 characters or less' })
  fullName!: string;

  @ApiProperty({ example: '+919876543210' })
  @Transform(trimString)
  @IsString({ message: 'Phone must be a string' })
  @MinLength(1, { message: 'Phone cannot be empty' })
  phone!: string;

  @ApiPropertyOptional({ example: 'member@example.com', nullable: true })
  @Transform(lowerOptionalEmail)
  @IsOptional()
  @IsEmail({}, { message: 'Email must be valid' })
  email?: string;

  @ApiProperty({ example: 'Rahim Khan' })
  @Transform(trimString)
  @IsString({ message: 'Father name must be a string' })
  @MinLength(1, { message: 'Father name is required' })
  @MaxLength(150, { message: 'Father name must be 150 characters or less' })
  fatherName!: string;

  @ApiProperty({ example: 45, minimum: 1, maximum: 120 })
  @IsInt({ message: 'Age must be a whole number' })
  @Min(1, { message: 'Age must be at least 1' })
  @Max(120, { message: 'Age must be 120 or less' })
  age!: number;

  @ApiProperty({ enum: GenderDto, example: GenderDto.MALE })
  @IsEnum(GenderDto, { message: 'Gender must be MALE, FEMALE, or OTHER' })
  gender!: GenderDto;

  @ApiPropertyOptional({
    example: false,
    description: 'Required for MEMBER users',
  })
  @IsOptional()
  @IsBoolean({ message: 'Is family head must be true or false' })
  isFamilyHead?: boolean;

  @ApiPropertyOptional({ example: 5, minimum: 0 })
  @IsOptional()
  @IsInt({ message: 'Family member count must be a whole number' })
  @Min(0, { message: 'Family member count cannot be negative' })
  familyMemberCount?: number;
}

export class UpdateMasjidUserStatusDto {
  @ApiPropertyOptional({
    enum: MasjidUserStatusDto,
    example: MasjidUserStatusDto.ACTIVE,
  })
  @IsEnum(MasjidUserStatusDto, {
    message: 'Status must be ACTIVE, INACTIVE, or SUSPENDED',
  })
  status!: MasjidUserStatusDto;
}

import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import {
  IsEmail,
  IsEnum,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
  MinLength,
} from 'class-validator';

export enum CreateMasjidUserRoleDto {
  MEMBER = 'MEMBER',
  IMAM = 'IMAM',
  COMMITTEE_MEMBER = 'COMMITTEE_MEMBER',
}

export class CreateMasjidUserDto {
  @ApiProperty({
    example: 'Ali Khan',
    minLength: 2,
    maxLength: 50,
  })
  @Transform(({ value }) => (typeof value === 'string' ? value.trim() : value))
  @IsString({ message: 'Full name must be a string' })
  @MinLength(2, { message: 'Full name must be at least 2 characters' })
  @MaxLength(50, { message: 'Full name must be 50 characters or less' })
  fullName!: string;

  @ApiProperty({
    example: '9876543210',
    minLength: 6,
    maxLength: 20,
  })
  @Transform(({ value }) => (typeof value === 'string' ? value.trim() : value))
  @IsString({ message: 'Phone must be a string' })
  @MinLength(6, { message: 'Phone must be at least 6 characters' })
  @MaxLength(20, { message: 'Phone must be 20 characters or less' })
  phone!: string;

  @ApiPropertyOptional({
    example: 'user@example.com',
    maxLength: 254,
  })
  @Transform(({ value }) =>
    typeof value === 'string' ? value.trim().toLowerCase() : value,
  )
  @IsOptional()
  @IsEmail({}, { message: 'Email must be a valid email address' })
  @MaxLength(254, { message: 'Email must be 254 characters or less' })
  email?: string;

  @ApiProperty({
    enum: CreateMasjidUserRoleDto,
    example: CreateMasjidUserRoleDto.MEMBER,
  })
  @IsEnum(CreateMasjidUserRoleDto)
  role!: CreateMasjidUserRoleDto;

  @ApiPropertyOptional({
    example: '4e0798d2-3fd3-4caa-9966-9f85c96f8b2f',
    description: 'Only SUPER_ADMIN may provide this when not assigned to a masjid',
  })
  @Transform(({ value }) => (typeof value === 'string' ? value.trim() : value))
  @IsOptional()
  @IsUUID('4')
  masjidId?: string;
}

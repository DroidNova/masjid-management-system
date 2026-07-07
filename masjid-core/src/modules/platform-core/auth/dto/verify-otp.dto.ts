import { ApiProperty } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import { IsString, MaxLength, MinLength } from 'class-validator';

export class VerifyOtpDto {
  @ApiProperty({
    example: '9876543210',
    description: 'Phone number associated with the OTP challenge',
    minLength: 6,
    maxLength: 20,
  })
  @Transform(({ value }) => (typeof value === 'string' ? value.trim() : value))
  @IsString({ message: 'Phone must be a string' })
  @MinLength(6, { message: 'Phone must be at least 6 characters' })
  @MaxLength(20, { message: 'Phone must be 20 characters or less' })
  phone!: string;

  @ApiProperty({ example: 'd0f5ec4c-7d04-4bb0-b481-efc2cd981a63' })
  @Transform(({ value }) => (typeof value === 'string' ? value.trim() : value))
  @IsString({ message: 'Challenge ID must be a string' })
  @MinLength(1, { message: 'Challenge ID is required' })
  challengeId!: string;

  @ApiProperty({ example: '111111', minLength: 6, maxLength: 6 })
  @Transform(({ value }) => (typeof value === 'string' ? value.trim() : value))
  @IsString({ message: 'OTP must be a string' })
  @MinLength(6, { message: 'OTP must be 6 digits' })
  @MaxLength(6, { message: 'OTP must be 6 digits' })
  otp!: string;
}

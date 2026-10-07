import { ApiProperty } from '@nestjs/swagger';
import { IsString, MaxLength, MinLength } from 'class-validator';

export class ChangePasswordDto {
  @ApiProperty({ example: '12345678', format: 'password' })
  @IsString({ message: 'Current password must be a string' })
  @MinLength(1, { message: 'Current password is required' })
  @MaxLength(128, {
    message: 'Current password must be 128 characters or less',
  })
  currentPassword!: string;

  @ApiProperty({
    example: 'a-new-strong-password',
    format: 'password',
    minLength: 8,
    maxLength: 128,
  })
  @IsString({ message: 'New password must be a string' })
  @MinLength(8, { message: 'New password must be at least 8 characters' })
  @MaxLength(128, { message: 'New password must be 128 characters or less' })
  newPassword!: string;
}

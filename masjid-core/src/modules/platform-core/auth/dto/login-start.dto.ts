import { ApiProperty } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import { IsString, MaxLength, MinLength } from 'class-validator';

export class LoginStartDto {
  @ApiProperty({
    example: '9876543210',
    description: 'Phone number used to start the login flow',
    minLength: 6,
    maxLength: 20,
  })
  @Transform(({ value }) => (typeof value === 'string' ? value.trim() : value))
  @IsString({ message: 'Phone must be a string' })
  @MinLength(6, { message: 'Phone must be at least 6 characters' })
  @MaxLength(20, { message: 'Phone must be 20 characters or less' })
  phone!: string;
}

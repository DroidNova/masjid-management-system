import { ApiProperty } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import { IsString, MaxLength, MinLength } from 'class-validator';

const trimString = ({ value }: { value: unknown }) =>
  typeof value === 'string' ? value.trim() : value;

export class UpdateWelcomeMessageDto {
  @ApiProperty({
    example: 'Assalamu Alaikum, welcome to Jama Masjid',
    maxLength: 500,
  })
  @Transform(trimString)
  @IsString({ message: 'Welcome message must be a string' })
  @MinLength(1, { message: 'Welcome message is required' })
  @MaxLength(500, { message: 'Welcome message must be 500 characters or less' })
  welcomeMsg!: string;
}

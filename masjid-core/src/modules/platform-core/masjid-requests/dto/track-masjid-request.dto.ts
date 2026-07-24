import { ApiProperty } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import { IsString, MinLength } from 'class-validator';

export class TrackMasjidRequestDto {
  @ApiProperty({ example: '+919876543210' })
  @Transform(({ value }: { value: unknown }) =>
    typeof value === 'string' ? value.trim() : value,
  )
  @IsString({ message: 'Requester phone must be a string' })
  @MinLength(1, { message: 'Requester phone is required' })
  requesterPhone!: string;
}

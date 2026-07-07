import { ApiProperty } from '@nestjs/swagger';
import { ArrayMinSize, IsArray, IsString } from 'class-validator';

export class AssignUserRolesDto {
  @ApiProperty({
    example: ['MASJID_ADMIN', 'IMAM'],
    description: 'Role names to assign to the user',
  })
  @IsArray()
  @ArrayMinSize(1)
  @IsString({ each: true })
  roleNames!: string[];
}

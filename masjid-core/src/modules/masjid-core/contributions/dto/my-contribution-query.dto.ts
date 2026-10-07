import { ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsInt, IsOptional, Max, Min } from 'class-validator';
import { PaginationQueryDto } from '../../../../common/dto/pagination-query.dto';

export class MyContributionQueryDto extends PaginationQueryDto {
  @ApiPropertyOptional({
    minimum: 1,
    maximum: 24,
    default: 6,
    description: 'Imam salary months to include',
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(24)
  monthsBack: number = 6;
}

import { ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsInt, IsOptional, Max, Min } from 'class-validator';
import { PaginationQueryDto } from '../../../../common/dto/pagination-query.dto';

export class MyContributionQueryDto extends PaginationQueryDto {
  @ApiPropertyOptional({
    minimum: 1,
    maximum: 24,
    description:
      'Only the latest N salary months. Leave out for every month (paged).',
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(24)
  monthsBack?: number;
}

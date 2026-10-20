import { Controller, Get, Param, Query } from '@nestjs/common';
import { ApiOperation, ApiPropertyOptional, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { IsOptional, IsString, MaxLength } from 'class-validator';
import { PaginationQueryDto } from '../../../common/dto/pagination-query.dto';
import { RATE_LIMITS } from '../../../common/rate-limit/rate-limit';
import { PublicMasjidsService } from './public-masjids.service';

export class PublicMasjidSearchDto {
  @ApiPropertyOptional({ example: 'Barota' })
  @IsOptional()
  @IsString()
  @MaxLength(80)
  q?: string;
}

/**
 * Public masjid pages for people outside the masjid. No bearer token:
 * these routes are open on purpose and listed in ROUTES_WITHOUT_PERMISSION.
 */
@ApiTags('Public masjid pages')
@Controller('public/masjids')
export class PublicMasjidsController {
  constructor(private readonly publicMasjids: PublicMasjidsService) {}

  @Get('search')
  @Throttle(RATE_LIMITS.publicRead)
  @ApiOperation({
    summary: 'Find approved masjids by name or place (at least 2 letters)',
    description: 'Public endpoint. Returns { items } (at most 20), not paged.',
  })
  search(@Query() query: PublicMasjidSearchDto) {
    return this.publicMasjids.search(query.q ?? '');
  }

  @Get(':code')
  @Throttle(RATE_LIMITS.publicRead)
  @ApiOperation({
    summary: 'Public page of a masjid: place, namaz times, latest public news',
    description:
      'Public endpoint. Only approved masjids; unknown code: 404 MASJID_NOT_FOUND.',
  })
  page(@Param('code') code: string) {
    return this.publicMasjids.page(code);
  }

  @Get(':code/announcements')
  @Throttle(RATE_LIMITS.publicRead)
  @ApiOperation({
    summary: 'Public announcements of a masjid, newest first',
    description: 'Public endpoint. Members-only announcements never appear.',
  })
  announcements(
    @Param('code') code: string,
    @Query() query: PaginationQueryDto,
  ) {
    return this.publicMasjids.announcements(code, query);
  }
}

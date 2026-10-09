import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiBody,
  ApiOperation,
  ApiParam,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { RATE_LIMITS } from '../../../common/rate-limit/rate-limit';
import { PERMISSIONS } from '../../../access/permissions';
import { RequirePermissions } from '../../../access/require-permissions';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { AuthenticatedUser } from '../auth/types/jwt-payload.type';
import { CreateMasjidRequestDto } from './dto/create-masjid-request.dto';
import { GetMasjidRequestsQueryDto } from './dto/get-masjid-requests-query.dto';
import { TrackMasjidRequestDto } from './dto/track-masjid-request.dto';
import { UpdateMasjidRequestStatusDto } from './dto/update-masjid-request-status.dto';
import { MasjidRequestsService } from './masjid-requests.service';

const UUID_V4 = new ParseUUIDPipe({ version: '4' });

type AuthenticatedRequest = {
  user: AuthenticatedUser;
};

const standardErrorSchema = {
  example: {
    success: false,
    message: 'Forbidden resource',
    errorCode: 'FORBIDDEN',
  },
};

@ApiTags('Masjid Requests')
@Controller('masjid-requests')
export class MasjidRequestsController {
  constructor(private readonly masjidRequestsService: MasjidRequestsService) {}

  @Post()
  @Throttle(RATE_LIMITS.publicSubmit)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Submit a public masjid registration request',
    description:
      'Public endpoint. No bearer token is required. Imam or committee member phone already in a masjid: 409 USER_IN_ANOTHER_MASJID (message names them as entered on the request; errors.phones lists the numbers).',
  })
  @ApiBody({ type: CreateMasjidRequestDto })
  @ApiResponse({
    status: HttpStatus.CREATED,
    description: 'Masjid request created successfully',
  })
  create(@Body() dto: CreateMasjidRequestDto) {
    return this.masjidRequestsService.create(dto);
  }

  @Post('track')
  @Throttle(RATE_LIMITS.publicLookup)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Track public masjid registration requests by requester phone',
    description:
      'Public endpoint. No bearer token or tracking token is required. Returns { items } with the 20 newest applications for the phone; this list is not paged (no meta).',
  })
  @ApiBody({ type: TrackMasjidRequestDto })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Applications fetched successfully',
    schema: {
      example: {
        success: true,
        message: 'Applications fetched successfully',
        data: {
          items: [
            {
              masjidName: 'Jama Masjid',
              status: 'PENDING',
              imamName: 'Abdul Rahman',
              requestedAt: '2026-06-19T00:00:00.000Z',
              reviewedAt: null,
            },
          ],
        },
      },
    },
  })
  track(@Body() dto: TrackMasjidRequestDto) {
    return this.masjidRequestsService.trackByRequesterPhone(dto.requesterPhone);
  }

  @Get()
  // Decorators apply bottom-up: JwtAuthGuard must run before the permission check.
  @RequirePermissions(PERMISSIONS.PLATFORM_MASJID_REQUESTS_MANAGE)
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('bearer')
  @ApiOperation({ summary: 'Get all masjid requests with filters' })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Masjid requests retrieved successfully',
  })
  @ApiResponse({ status: HttpStatus.FORBIDDEN, schema: standardErrorSchema })
  findAll(@Query() query: GetMasjidRequestsQueryDto) {
    return this.masjidRequestsService.findAll(query);
  }

  @Get(':id')
  // Decorators apply bottom-up: JwtAuthGuard must run before the permission check.
  @RequirePermissions(PERMISSIONS.PLATFORM_MASJID_REQUESTS_MANAGE)
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('bearer')
  @ApiOperation({
    summary: 'Get one masjid request',
    description: 'Same shape as an item of GET /masjid-requests.',
  })
  @ApiParam({ name: 'id', example: '4e0798d2-3fd3-4caa-9966-9f85c96f8b2f' })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Masjid request retrieved successfully',
  })
  @ApiResponse({ status: HttpStatus.FORBIDDEN, schema: standardErrorSchema })
  @ApiResponse({
    status: HttpStatus.NOT_FOUND,
    description: 'MASJID_REQUEST_NOT_FOUND',
    schema: standardErrorSchema,
  })
  findOne(@Param('id', UUID_V4) id: string) {
    return this.masjidRequestsService.findOne(id);
  }

  @Patch(':id/status')
  // Decorators apply bottom-up: JwtAuthGuard must run before the permission check.
  @RequirePermissions(PERMISSIONS.PLATFORM_MASJID_REQUESTS_MANAGE)
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('bearer')
  @ApiOperation({
    summary: 'Approve or reject a masjid request',
    description:
      'Only a PENDING request can change. Already decided: 409 MASJID_REQUEST_ALREADY_APPROVED / MASJID_REQUEST_ALREADY_REJECTED (also for the loser of two simultaneous decisions). Imam or committee member in another masjid: 409 USER_IN_ANOTHER_MASJID. New imam whose email belongs to another account: 409 EMAIL_ALREADY_EXISTS.',
  })
  @ApiParam({ name: 'id', example: '4e0798d2-3fd3-4caa-9966-9f85c96f8b2f' })
  @ApiBody({ type: UpdateMasjidRequestStatusDto })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Masjid request status updated successfully',
  })
  @ApiResponse({ status: HttpStatus.FORBIDDEN, schema: standardErrorSchema })
  @ApiResponse({ status: HttpStatus.NOT_FOUND, schema: standardErrorSchema })
  updateStatus(
    @Param('id', UUID_V4) id: string,
    @Body() dto: UpdateMasjidRequestStatusDto,
    @Req() request: AuthenticatedRequest,
  ) {
    return this.masjidRequestsService.updateStatus(id, dto, request.user);
  }
}

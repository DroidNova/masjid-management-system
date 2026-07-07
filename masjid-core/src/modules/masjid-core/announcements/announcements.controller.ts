import {
  Body,
  Controller,
  Delete,
  Get,
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
  ApiQuery,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { Roles } from '../../../common/decorators/roles.decorator';
import { RolesGuard } from '../../../common/guards/roles.guard';
import { JwtAuthGuard } from '../../platform-core/auth/guards/jwt-auth.guard';
import { AuthenticatedUser } from '../../platform-core/auth/types/jwt-payload.type';
import { AnnouncementsService } from './announcements.service';
import { CreateAnnouncementDto } from './dto/create-announcement.dto';
import { GetAnnouncementsQueryDto } from './dto/get-announcements-query.dto';
import { UpdateAnnouncementDto } from './dto/update-announcement.dto';

type AuthenticatedRequest = {
  user: AuthenticatedUser;
};

const standardErrorSchema = {
  example: {
    success: false,
    message: 'Current user is not assigned to a masjid',
    errorCode: 'USER_MASJID_NOT_ASSIGNED',
  },
};

@ApiTags('Announcements')
@ApiBearerAuth('bearer')
@UseGuards(JwtAuthGuard)
@Controller('announcements')
export class AnnouncementsController {
  constructor(private readonly announcementsService: AnnouncementsService) {}

  @Get('my-masjid')
  @ApiOperation({ summary: "Get current masjid's announcements" })
  @ApiQuery({ name: 'isActive', required: false, type: Boolean })
  @ApiQuery({ name: 'page', required: false, type: Number, example: 1 })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 20 })
  @ApiQuery({ name: 'search', required: false, type: String, example: 'jumma' })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Announcements retrieved successfully',
  })
  @ApiResponse({ status: HttpStatus.FORBIDDEN, schema: standardErrorSchema })
  findMyMasjidAnnouncements(
    @Query() query: GetAnnouncementsQueryDto,
    @Req() request: AuthenticatedRequest,
  ) {
    return this.announcementsService.findMyMasjidAnnouncements(
      query,
      request.user,
    );
  }

  @Post('my-masjid')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('MASJID_ADMIN', 'IMAM', 'COMMITTEE_MEMBER')
  @ApiOperation({ summary: "Create announcement for current user's masjid" })
  @ApiBody({ type: CreateAnnouncementDto })
  @ApiResponse({
    status: HttpStatus.CREATED,
    description: 'Announcement created successfully',
  })
  @ApiResponse({ status: HttpStatus.FORBIDDEN, schema: standardErrorSchema })
  create(
    @Body() dto: CreateAnnouncementDto,
    @Req() request: AuthenticatedRequest,
  ) {
    return this.announcementsService.create(dto, request.user);
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('MASJID_ADMIN', 'IMAM', 'COMMITTEE_MEMBER')
  @ApiOperation({ summary: 'Update an announcement from the current masjid' })
  @ApiParam({
    name: 'id',
    example: '4e0798d2-3fd3-4caa-9966-9f85c96f8b2f',
  })
  @ApiBody({ type: UpdateAnnouncementDto })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Announcement updated successfully',
  })
  @ApiResponse({ status: HttpStatus.FORBIDDEN, schema: standardErrorSchema })
  @ApiResponse({ status: HttpStatus.NOT_FOUND, schema: standardErrorSchema })
  update(
    @Param('id', new ParseUUIDPipe({ version: '4' })) id: string,
    @Body() dto: UpdateAnnouncementDto,
    @Req() request: AuthenticatedRequest,
  ) {
    return this.announcementsService.update(id, dto, request.user);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('MASJID_ADMIN', 'IMAM', 'COMMITTEE_MEMBER')
  @ApiOperation({
    summary: 'Deactivate an announcement from the current masjid',
  })
  @ApiParam({
    name: 'id',
    example: '4e0798d2-3fd3-4caa-9966-9f85c96f8b2f',
  })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Announcement deactivated successfully',
  })
  @ApiResponse({ status: HttpStatus.FORBIDDEN, schema: standardErrorSchema })
  @ApiResponse({ status: HttpStatus.NOT_FOUND, schema: standardErrorSchema })
  deactivate(
    @Param('id', new ParseUUIDPipe({ version: '4' })) id: string,
    @Req() request: AuthenticatedRequest,
  ) {
    return this.announcementsService.deactivate(id, request.user);
  }
}

import {
  Body,
  Controller,
  Get,
  HttpStatus,
  Patch,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiBody,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { Roles } from '../../../common/decorators/roles.decorator';
import { RolesGuard } from '../../../common/guards/roles.guard';
import { JwtAuthGuard } from '../../platform-core/auth/guards/jwt-auth.guard';
import { AuthenticatedUser } from '../../platform-core/auth/types/jwt-payload.type';
import { CreateMasjidUserDto } from './dto/create-masjid-user.dto';
import { UpdateWelcomeMessageDto } from './dto/update-welcome-message.dto';
import { MasjidsService } from './masjids.service';

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

@ApiTags('Masjids')
@ApiBearerAuth('bearer')
@UseGuards(JwtAuthGuard)
@Controller('masjids')
export class MasjidsController {
  constructor(private readonly masjidsService: MasjidsService) {}

  @Get('my')
  @ApiOperation({ summary: "Get the current user's masjid profile" })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Current masjid profile retrieved successfully',
  })
  @ApiResponse({ status: HttpStatus.FORBIDDEN, schema: standardErrorSchema })
  @ApiResponse({ status: HttpStatus.NOT_FOUND, schema: standardErrorSchema })
  getMyMasjid(@Req() request: AuthenticatedRequest) {
    return this.masjidsService.getMyMasjid(request.user);
  }

  @Patch('my/welcome-message')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('SUPER_ADMIN', 'MASJID_ADMIN', 'IMAM', 'COMMITTEE_MEMBER')
  @ApiOperation({ summary: "Update the current masjid's welcome message" })
  @ApiBody({ type: UpdateWelcomeMessageDto })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Welcome message updated successfully',
  })
  @ApiResponse({ status: HttpStatus.FORBIDDEN, schema: standardErrorSchema })
  @ApiResponse({ status: HttpStatus.NOT_FOUND, schema: standardErrorSchema })
  updateWelcomeMessage(
    @Body() dto: UpdateWelcomeMessageDto,
    @Req() request: AuthenticatedRequest,
  ) {
    return this.masjidsService.updateWelcomeMessage(dto, request.user);
  }

  @Post('my/users')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('SUPER_ADMIN', 'MASJID_ADMIN', 'COMMITTEE_MEMBER')
  @ApiOperation({ summary: 'Create a user in current masjid' })
  @ApiBody({ type: CreateMasjidUserDto })
  @ApiResponse({
    status: HttpStatus.CREATED,
    description: 'Masjid user created successfully',
  })
  @ApiResponse({ status: HttpStatus.FORBIDDEN, schema: standardErrorSchema })
  @ApiResponse({ status: HttpStatus.CONFLICT, schema: standardErrorSchema })
  createMyMasjidUser(
    @Body() dto: CreateMasjidUserDto,
    @Req() request: AuthenticatedRequest,
  ) {
    return this.masjidsService.createMyMasjidUser(request.user, dto);
  }

  @Get('my/users')
  @ApiOperation({ summary: "Get users linked to the current user's masjid" })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Current masjid users retrieved successfully',
  })
  @ApiResponse({ status: HttpStatus.FORBIDDEN, schema: standardErrorSchema })
  findMyMasjidUsers(@Req() request: AuthenticatedRequest) {
    return this.masjidsService.findMyMasjidUsers(request.user);
  }
}

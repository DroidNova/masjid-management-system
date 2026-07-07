import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
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
import { Roles } from '../../../common/decorators/roles.decorator';
import { RolesGuard } from '../../../common/guards/roles.guard';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { AuthenticatedUser } from '../auth/types/jwt-payload.type';
import { CreateMasjidRequestDto } from './dto/create-masjid-request.dto';
import { GetMasjidRequestsQueryDto } from './dto/get-masjid-requests-query.dto';
import { UpdateMasjidRequestStatusDto } from './dto/update-masjid-request-status.dto';
import { MasjidRequestsService } from './masjid-requests.service';

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
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Submit a public masjid registration request',
    description: 'Public endpoint. No bearer token is required.',
  })
  @ApiBody({ type: CreateMasjidRequestDto })
  @ApiResponse({
    status: HttpStatus.CREATED,
    description: 'Masjid request created successfully',
  })
  create(@Body() dto: CreateMasjidRequestDto) {
    return this.masjidRequestsService.create(dto);
  }

  @Get()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('SUPER_ADMIN')
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

  @Patch(':id/status')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('SUPER_ADMIN')
  @ApiBearerAuth('bearer')
  @ApiOperation({ summary: 'Approve or reject a masjid request' })
  @ApiParam({ name: 'id', example: '4e0798d2-3fd3-4caa-9966-9f85c96f8b2f' })
  @ApiBody({ type: UpdateMasjidRequestStatusDto })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Masjid request status updated successfully',
  })
  @ApiResponse({ status: HttpStatus.FORBIDDEN, schema: standardErrorSchema })
  @ApiResponse({ status: HttpStatus.NOT_FOUND, schema: standardErrorSchema })
  updateStatus(
    @Param('id') id: string,
    @Body() dto: UpdateMasjidRequestStatusDto,
    @Req() request: AuthenticatedRequest,
  ) {
    return this.masjidRequestsService.updateStatus(id, dto, request.user);
  }
}

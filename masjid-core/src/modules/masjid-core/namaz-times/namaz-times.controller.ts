import {
  Body,
  Controller,
  Get,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Put,
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
import { JwtAuthGuard } from '../../platform-core/auth/guards/jwt-auth.guard';
import { AuthenticatedUser } from '../../platform-core/auth/types/jwt-payload.type';
import { UpsertNamazTimeDto } from './dto/upsert-namaz-time.dto';
import { NamazTimesService } from './namaz-times.service';

type AuthenticatedRequest = {
  user: AuthenticatedUser;
};

const standardErrorSchema = {
  example: {
    success: false,
    message: 'You are not allowed to access this masjid',
    errorCode: 'MASJID_ACCESS_FORBIDDEN',
  },
};

@ApiTags('Namaz Times')
@ApiBearerAuth('bearer')
@UseGuards(JwtAuthGuard)
@Controller('namaz-times')
export class NamazTimesController {
  constructor(private readonly namazTimesService: NamazTimesService) {}

  @Get(':masjidId')
  @ApiOperation({ summary: 'Get namaz times by masjid id' })
  @ApiParam({
    name: 'masjidId',
    example: '4e0798d2-3fd3-4caa-9966-9f85c96f8b2f',
  })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Namaz times retrieved successfully',
  })
  @ApiResponse({ status: HttpStatus.FORBIDDEN, schema: standardErrorSchema })
  @ApiResponse({ status: HttpStatus.NOT_FOUND, schema: standardErrorSchema })
  findByMasjidId(
    @Param('masjidId', new ParseUUIDPipe({ version: '4' })) masjidId: string,
    @Req() request: AuthenticatedRequest,
  ) {
    return this.namazTimesService.findByMasjidId(masjidId, request.user);
  }

  @Put(':masjidId')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('SUPER_ADMIN', 'MASJID_ADMIN', 'IMAM', 'COMMITTEE_MEMBER')
  @ApiOperation({ summary: 'Insert or update namaz times by masjid id' })
  @ApiParam({
    name: 'masjidId',
    example: '4e0798d2-3fd3-4caa-9966-9f85c96f8b2f',
  })
  @ApiBody({ type: UpsertNamazTimeDto })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Namaz times saved successfully',
  })
  @ApiResponse({ status: HttpStatus.FORBIDDEN, schema: standardErrorSchema })
  @ApiResponse({ status: HttpStatus.NOT_FOUND, schema: standardErrorSchema })
  upsert(
    @Param('masjidId', new ParseUUIDPipe({ version: '4' })) masjidId: string,
    @Body() dto: UpsertNamazTimeDto,
    @Req() request: AuthenticatedRequest,
  ) {
    return this.namazTimesService.upsert(masjidId, dto, request.user);
  }
}

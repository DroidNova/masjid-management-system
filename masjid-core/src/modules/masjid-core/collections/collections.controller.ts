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
import { CollectionsService } from './collections.service';
import {
  CollectionTypeDto,
  FinanceEntryStatusDto,
  CreateCollectionDto,
} from './dto/create-collection.dto';
import { GetCollectionsQueryDto } from './dto/get-collections-query.dto';
import { UpdateCollectionDto } from './dto/update-collection.dto';

type AuthenticatedRequest = { user: AuthenticatedUser };
const standardErrorSchema = {
  example: {
    success: false,
    message: 'Current user is not assigned to a masjid',
    errorCode: 'USER_MASJID_NOT_ASSIGNED',
  },
};

@ApiTags('Collections')
@ApiBearerAuth('bearer')
@UseGuards(JwtAuthGuard)
@Controller('collections')
export class CollectionsController {
  constructor(private readonly collectionsService: CollectionsService) {}

  @Get('my-masjid')
  @ApiOperation({ summary: "Get current masjid's collections" })
  @ApiQuery({ name: 'type', required: false, enum: CollectionTypeDto })
  @ApiQuery({ name: 'status', required: false, enum: FinanceEntryStatusDto })
  @ApiQuery({ name: 'fromDate', required: false, type: String })
  @ApiQuery({ name: 'toDate', required: false, type: String })
  @ApiQuery({ name: 'search', required: false, type: String })
  @ApiQuery({ name: 'page', required: false, type: Number, example: 1 })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 20 })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Collections retrieved successfully',
  })
  @ApiResponse({ status: HttpStatus.FORBIDDEN, schema: standardErrorSchema })
  findMyMasjidCollections(
    @Query() query: GetCollectionsQueryDto,
    @Req() request: AuthenticatedRequest,
  ) {
    return this.collectionsService.findMyMasjidCollections(query, request.user);
  }

  @Post('my-masjid')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('MASJID_ADMIN', 'COMMITTEE_MEMBER')
  @ApiOperation({ summary: "Create current masjid's collection" })
  @ApiBody({ type: CreateCollectionDto })
  @ApiResponse({
    status: HttpStatus.CREATED,
    description: 'Collection created successfully',
  })
  create(
    @Body() dto: CreateCollectionDto,
    @Req() request: AuthenticatedRequest,
  ) {
    return this.collectionsService.create(dto, request.user);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get collection details' })
  @ApiParam({ name: 'id', example: '4e0798d2-3fd3-4caa-9966-9f85c96f8b2f' })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Collection retrieved successfully',
  })
  findOne(
    @Param('id', new ParseUUIDPipe({ version: '4' })) id: string,
    @Req() request: AuthenticatedRequest,
  ) {
    return this.collectionsService.findOne(id, request.user);
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('MASJID_ADMIN', 'COMMITTEE_MEMBER')
  @ApiOperation({ summary: 'Update a collection' })
  @ApiBody({ type: UpdateCollectionDto })
  update(
    @Param('id', new ParseUUIDPipe({ version: '4' })) id: string,
    @Body() dto: UpdateCollectionDto,
    @Req() request: AuthenticatedRequest,
  ) {
    return this.collectionsService.update(id, dto, request.user);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('MASJID_ADMIN', 'COMMITTEE_MEMBER')
  @ApiOperation({ summary: 'Cancel a collection' })
  cancel(
    @Param('id', new ParseUUIDPipe({ version: '4' })) id: string,
    @Req() request: AuthenticatedRequest,
  ) {
    return this.collectionsService.cancel(id, request.user);
  }
}

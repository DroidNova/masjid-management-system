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
import { CreateProjectDto, ProjectStatusDto } from './dto/create-project.dto';
import { GetProjectsQueryDto } from './dto/get-projects-query.dto';
import { UpdateProjectDto } from './dto/update-project.dto';
import { ProjectsService } from './projects.service';

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

@ApiTags('Projects')
@ApiBearerAuth('bearer')
@UseGuards(JwtAuthGuard)
@Controller('projects')
export class ProjectsController {
  constructor(private readonly projectsService: ProjectsService) {}

  @Get('my-masjid')
  @ApiOperation({ summary: "Get current masjid's projects" })
  @ApiQuery({ name: 'status', required: false, enum: ProjectStatusDto })
  @ApiQuery({ name: 'page', required: false, type: Number, example: 1 })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 20 })
  @ApiQuery({ name: 'search', required: false, type: String, example: 'wuzu' })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Projects retrieved successfully',
  })
  @ApiResponse({ status: HttpStatus.FORBIDDEN, schema: standardErrorSchema })
  findMyMasjidProjects(
    @Query() query: GetProjectsQueryDto,
    @Req() request: AuthenticatedRequest,
  ) {
    return this.projectsService.findMyMasjidProjects(query, request.user);
  }

  @Post('my-masjid')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('MASJID_ADMIN', 'COMMITTEE_MEMBER')
  @ApiOperation({ summary: "Create a project for current user's masjid" })
  @ApiBody({ type: CreateProjectDto })
  @ApiResponse({
    status: HttpStatus.CREATED,
    description: 'Project created successfully',
  })
  @ApiResponse({ status: HttpStatus.FORBIDDEN, schema: standardErrorSchema })
  create(@Body() dto: CreateProjectDto, @Req() request: AuthenticatedRequest) {
    return this.projectsService.create(dto, request.user);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get project details from the current masjid' })
  @ApiParam({
    name: 'id',
    example: '4e0798d2-3fd3-4caa-9966-9f85c96f8b2f',
  })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Project retrieved successfully',
  })
  @ApiResponse({ status: HttpStatus.FORBIDDEN, schema: standardErrorSchema })
  @ApiResponse({ status: HttpStatus.NOT_FOUND, schema: standardErrorSchema })
  findOne(
    @Param('id', new ParseUUIDPipe({ version: '4' })) id: string,
    @Req() request: AuthenticatedRequest,
  ) {
    return this.projectsService.findOne(id, request.user);
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('MASJID_ADMIN', 'COMMITTEE_MEMBER')
  @ApiOperation({ summary: 'Update a project from the current masjid' })
  @ApiParam({
    name: 'id',
    example: '4e0798d2-3fd3-4caa-9966-9f85c96f8b2f',
  })
  @ApiBody({ type: UpdateProjectDto })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Project updated successfully',
  })
  @ApiResponse({ status: HttpStatus.FORBIDDEN, schema: standardErrorSchema })
  @ApiResponse({ status: HttpStatus.NOT_FOUND, schema: standardErrorSchema })
  update(
    @Param('id', new ParseUUIDPipe({ version: '4' })) id: string,
    @Body() dto: UpdateProjectDto,
    @Req() request: AuthenticatedRequest,
  ) {
    return this.projectsService.update(id, dto, request.user);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('MASJID_ADMIN', 'COMMITTEE_MEMBER')
  @ApiOperation({ summary: 'Cancel a project from the current masjid' })
  @ApiParam({
    name: 'id',
    example: '4e0798d2-3fd3-4caa-9966-9f85c96f8b2f',
  })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Project cancelled successfully',
  })
  @ApiResponse({ status: HttpStatus.FORBIDDEN, schema: standardErrorSchema })
  @ApiResponse({ status: HttpStatus.NOT_FOUND, schema: standardErrorSchema })
  cancel(
    @Param('id', new ParseUUIDPipe({ version: '4' })) id: string,
    @Req() request: AuthenticatedRequest,
  ) {
    return this.projectsService.cancel(id, request.user);
  }
}

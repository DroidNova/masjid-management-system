import { Logger, HttpStatus, Injectable } from '@nestjs/common';
import { ERROR_CODES } from '../../../common/constants/error-codes.constant';
import { ApiException } from '../../../common/exceptions/api.exception';
import { PrismaService } from '../../../prisma/prisma.service';
import { AuthenticatedUser } from '../../platform-core/auth/types/jwt-payload.type';
import { CreateProjectDto, ProjectStatusDto } from './dto/create-project.dto';
import { GetProjectsQueryDto } from './dto/get-projects-query.dto';
import { UpdateProjectDto } from './dto/update-project.dto';

type DecimalLike =
  | number
  | string
  | { toNumber?: () => number; toString: () => string };

type ProjectRecord = {
  id: string;
  masjidId: string;
  title: string;
  description: string | null;
  targetAmount: DecimalLike;
  collectedAmount: DecimalLike;
  spentAmount: DecimalLike;
  status: string;
  startDate: Date | null;
  endDate: Date | null;
  createdAt: Date;
  updatedAt: Date;
};

type ProjectResponse = Omit<
  ProjectRecord,
  'targetAmount' | 'collectedAmount' | 'spentAmount'
> & {
  targetAmount: number;
  collectedAmount: number;
  spentAmount: number;
  remainingAmount: number;
  progressPercentage: number;
};

type ProjectsListResponse = {
  items: ProjectResponse[];
  meta: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
};

type ProjectWhereInput = {
  masjidId: string;
  status?: ProjectStatusDto;
  OR?: Array<{
    title?: { contains: string; mode: 'insensitive' };
    description?: { contains: string; mode: 'insensitive' };
  }>;
};

type ProjectCreateData = {
  masjidId: string;
  title: string;
  description?: string;
  targetAmount?: number;
  collectedAmount?: number;
  spentAmount?: number;
  status?: ProjectStatusDto;
  startDate?: Date;
  endDate?: Date;
};

type ProjectUpdateData = Partial<{
  title: string;
  description: string | null;
  targetAmount: number;
  collectedAmount: number;
  spentAmount: number;
  status: ProjectStatusDto;
  startDate: Date | null;
  endDate: Date | null;
}>;

type ProjectsProjectDelegate = {
  findMany(args: {
    where: ProjectWhereInput;
    skip: number;
    take: number;
    orderBy: { createdAt: 'desc' };
    select: typeof projectSelect;
  }): Promise<ProjectRecord[]>;
  count(args: { where: ProjectWhereInput }): Promise<number>;
  create(args: {
    data: ProjectCreateData;
    select: typeof projectSelect;
  }): Promise<ProjectRecord>;
  findUnique(args: {
    where: { id: string };
    select: typeof projectSelect;
  }): Promise<ProjectRecord | null>;
  update(args: {
    where: { id: string };
    data: ProjectUpdateData;
    select: typeof projectSelect;
  }): Promise<ProjectRecord>;
};

type ProjectsPrismaDelegate = {
  project: ProjectsProjectDelegate;
};

const projectSelect = {
  id: true,
  masjidId: true,
  title: true,
  description: true,
  targetAmount: true,
  collectedAmount: true,
  spentAmount: true,
  status: true,
  startDate: true,
  endDate: true,
  createdAt: true,
  updatedAt: true,
} as const;

@Injectable()
export class ProjectsService {
  private readonly logger = new Logger(ProjectsService.name);

  constructor(private readonly prisma: PrismaService) {}

  private get db(): ProjectsPrismaDelegate {
    return this.prisma as unknown as ProjectsPrismaDelegate;
  }

  async findMyMasjidProjects(
    query: GetProjectsQueryDto,
    actor: AuthenticatedUser,
  ): Promise<ProjectsListResponse> {
    const masjidId = this.getCurrentUserMasjidId(actor);
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const where = this.buildProjectWhere(masjidId, query);

    const [items, total] = await Promise.all([
      this.db.project.findMany({
        where,
        skip: (page - 1) * limit,
        take: limit,
        orderBy: { createdAt: 'desc' },
        select: projectSelect,
      }),
      this.db.project.count({ where }),
    ]);

    return {
      items: items.map((project) => this.toProjectResponse(project)),
      meta: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async create(
    dto: CreateProjectDto,
    actor: AuthenticatedUser,
  ): Promise<ProjectResponse> {
    const masjidId = this.getCurrentUserMasjidId(actor);

    const project = await this.db.project.create({
      data: this.buildCreateData(dto, masjidId),
      select: projectSelect,
    });

    this.logger.log({ message: 'Project created', projectId: project.id, masjidId });
    return this.toProjectResponse(project);
  }

  async findOne(
    id: string,
    actor: AuthenticatedUser,
  ): Promise<ProjectResponse> {
    const masjidId = this.getCurrentUserMasjidId(actor);
    const project = await this.ensureProjectBelongsToMasjid(id, masjidId);

    return this.toProjectResponse(project);
  }

  async update(
    id: string,
    dto: UpdateProjectDto,
    actor: AuthenticatedUser,
  ): Promise<ProjectResponse> {
    const masjidId = this.getCurrentUserMasjidId(actor);
    await this.ensureProjectBelongsToMasjid(id, masjidId);

    const data = this.buildUpdateData(dto);

    if (Object.keys(data).length === 0) {
      throw new ApiException(
        'At least one project field must be provided',
        HttpStatus.BAD_REQUEST,
        ERROR_CODES.BAD_REQUEST,
      );
    }

    const project = await this.db.project.update({
      where: { id },
      data,
      select: projectSelect,
    });

    this.logger.log({ message: 'Project updated', projectId: project.id, masjidId });
    return this.toProjectResponse(project);
  }

  async cancel(id: string, actor: AuthenticatedUser): Promise<ProjectResponse> {
    const masjidId = this.getCurrentUserMasjidId(actor);
    await this.ensureProjectBelongsToMasjid(id, masjidId);

    const project = await this.db.project.update({
      where: { id },
      data: { status: ProjectStatusDto.CANCELLED },
      select: projectSelect,
    });

    this.logger.warn({ message: 'Project cancelled', projectId: project.id, masjidId });
    return this.toProjectResponse(project);
  }

  private getCurrentUserMasjidId(actor: AuthenticatedUser): string {
    if (!actor.masjidId) {
      throw new ApiException(
        'Current user is not assigned to a masjid',
        HttpStatus.FORBIDDEN,
        ERROR_CODES.USER_MASJID_NOT_ASSIGNED,
      );
    }

    return actor.masjidId;
  }

  private async ensureProjectBelongsToMasjid(
    id: string,
    masjidId: string,
  ): Promise<ProjectRecord> {
    const project = await this.db.project.findUnique({
      where: { id },
      select: projectSelect,
    });

    if (!project) {
      throw new ApiException(
        'Project not found',
        HttpStatus.NOT_FOUND,
        ERROR_CODES.PROJECT_NOT_FOUND,
      );
    }

    if (project.masjidId !== masjidId) {
      throw new ApiException(
        'You are not allowed to access this project',
        HttpStatus.FORBIDDEN,
        ERROR_CODES.PROJECT_ACCESS_FORBIDDEN,
      );
    }

    return project;
  }

  private buildProjectWhere(
    masjidId: string,
    query: GetProjectsQueryDto,
  ): ProjectWhereInput {
    const where: ProjectWhereInput = { masjidId };

    if (query.status !== undefined) {
      where.status = query.status;
    }

    if (query.search) {
      where.OR = [
        { title: { contains: query.search, mode: 'insensitive' } },
        { description: { contains: query.search, mode: 'insensitive' } },
      ];
    }

    return where;
  }

  private buildCreateData(
    dto: CreateProjectDto,
    masjidId: string,
  ): ProjectCreateData {
    const data: ProjectCreateData = {
      masjidId,
      title: dto.title,
      status: dto.status ?? ProjectStatusDto.ONGOING,
    };

    if (dto.description !== undefined) data.description = dto.description;
    if (dto.targetAmount !== undefined) data.targetAmount = dto.targetAmount;
    if (dto.collectedAmount !== undefined)
      data.collectedAmount = dto.collectedAmount;
    if (dto.spentAmount !== undefined) data.spentAmount = dto.spentAmount;
    if (dto.startDate !== undefined) data.startDate = new Date(dto.startDate);
    if (dto.endDate !== undefined && dto.endDate !== null) {
      data.endDate = new Date(dto.endDate);
    }

    return data;
  }

  private buildUpdateData(dto: UpdateProjectDto): ProjectUpdateData {
    const data: ProjectUpdateData = {};

    if (dto.title !== undefined) data.title = dto.title;
    if (dto.description !== undefined) data.description = dto.description;
    if (dto.targetAmount !== undefined) data.targetAmount = dto.targetAmount;
    if (dto.collectedAmount !== undefined)
      data.collectedAmount = dto.collectedAmount;
    if (dto.spentAmount !== undefined) data.spentAmount = dto.spentAmount;
    if (dto.status !== undefined) data.status = dto.status;
    if (dto.startDate !== undefined) {
      data.startDate = dto.startDate === null ? null : new Date(dto.startDate);
    }
    if (dto.endDate !== undefined) {
      data.endDate = dto.endDate === null ? null : new Date(dto.endDate);
    }

    return data;
  }

  private toProjectResponse(project: ProjectRecord): ProjectResponse {
    const targetAmount = this.toNumber(project.targetAmount);
    const collectedAmount = this.toNumber(project.collectedAmount);
    const spentAmount = this.toNumber(project.spentAmount);
    const remainingAmount = targetAmount - collectedAmount;
    const progressPercentage =
      targetAmount === 0
        ? 0
        : Math.min((collectedAmount / targetAmount) * 100, 100);

    return {
      ...project,
      targetAmount,
      collectedAmount,
      spentAmount,
      remainingAmount,
      progressPercentage: Math.round(progressPercentage * 100) / 100,
    };
  }

  private toNumber(value: DecimalLike): number {
    if (typeof value === 'number') return value;
    if (typeof value === 'string') return Number(value);
    if (typeof value.toNumber === 'function') return value.toNumber();

    return Number(value.toString());
  }
}

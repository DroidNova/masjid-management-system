import { Logger, HttpStatus, Injectable } from '@nestjs/common';
import { ERROR_CODES } from '../../../common/constants/error-codes.constant';
import { ApiException } from '../../../common/exceptions/api.exception';
import {
  AUDIT_ACTION,
  AUDIT_ENTITY,
  AuditService,
} from '../../../common/audit/audit.service';
import { formatMoney, nonNegative, toAmount } from '../../../common/money';
import { requireMasjidId } from '../../../common/tenant';
import { Prisma } from '../../../generated/prisma/client';
import { ProjectStatus } from '../../../generated/prisma/enums';
import { PrismaService } from '../../../prisma/prisma.service';
import { AuthenticatedUser } from '../../platform-core/auth/types/jwt-payload.type';
import { CreateProjectDto } from './dto/create-project.dto';
import { GetProjectsQueryDto } from './dto/get-projects-query.dto';
import { UpdateProjectDto } from './dto/update-project.dto';
import { PageMeta, pageArgs, paged } from '../../../common/pagination';

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
} as const satisfies Prisma.ProjectSelect;

type ProjectRecord = Prisma.ProjectGetPayload<{ select: typeof projectSelect }>;

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

type ProjectsListResponse = { items: ProjectResponse[]; meta: PageMeta };

@Injectable()
export class ProjectsService {
  private readonly logger = new Logger(ProjectsService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly audit: AuditService,
  ) {}

  async findMyMasjidProjects(
    query: GetProjectsQueryDto,
    actor: AuthenticatedUser,
  ): Promise<ProjectsListResponse> {
    const masjidId = requireMasjidId(actor);
    const { page, limit, skip, take } = pageArgs(query);
    const where = this.buildProjectWhere(masjidId, query);

    const [items, total] = await Promise.all([
      this.prisma.project.findMany({
        where,
        skip,
        take,
        orderBy: { createdAt: 'desc' },
        select: projectSelect,
      }),
      this.prisma.project.count({ where }),
    ]);

    return paged(
      items.map((project) => this.toProjectResponse(project)),
      total,
      page,
      limit,
    );
  }

  async create(
    dto: CreateProjectDto,
    actor: AuthenticatedUser,
  ): Promise<ProjectResponse> {
    const masjidId = requireMasjidId(actor);

    const project = await this.prisma.$transaction(async (tx) => {
      const created = await tx.project.create({
        data: this.buildCreateData(dto, masjidId),
        select: projectSelect,
      });
      await this.audit.record(
        {
          masjidId,
          actor,
          action: AUDIT_ACTION.CREATE,
          entity: AUDIT_ENTITY.PROJECT,
          entityId: created.id,
          summary: this.auditSummary(created),
          after: created,
        },
        tx,
      );
      return created;
    });

    this.logger.log({
      message: 'Project created',
      projectId: project.id,
      masjidId,
    });
    return this.toProjectResponse(project);
  }

  async findOne(
    id: string,
    actor: AuthenticatedUser,
  ): Promise<ProjectResponse> {
    const masjidId = requireMasjidId(actor);
    const project = await this.findScoped(this.prisma, id, masjidId);

    return this.toProjectResponse(project);
  }

  async update(
    id: string,
    dto: UpdateProjectDto,
    actor: AuthenticatedUser,
  ): Promise<ProjectResponse> {
    const masjidId = requireMasjidId(actor);
    const data = this.buildUpdateData(dto);

    if (Object.keys(data).length === 0) {
      throw new ApiException(
        'At least one project field must be provided',
        HttpStatus.BAD_REQUEST,
        ERROR_CODES.BAD_REQUEST,
      );
    }

    const project = await this.prisma.$transaction(async (tx) => {
      const before = await this.findScoped(tx, id, masjidId);
      const updated = await tx.project.update({
        where: { id: before.id },
        data,
        select: projectSelect,
      });
      await this.audit.record(
        {
          masjidId,
          actor,
          action: AUDIT_ACTION.UPDATE,
          entity: AUDIT_ENTITY.PROJECT,
          entityId: updated.id,
          summary: this.auditSummary(updated),
          before,
          after: updated,
        },
        tx,
      );
      return updated;
    });

    this.logger.log({
      message: 'Project updated',
      projectId: project.id,
      masjidId,
    });
    return this.toProjectResponse(project);
  }

  async cancel(id: string, actor: AuthenticatedUser): Promise<ProjectResponse> {
    const masjidId = requireMasjidId(actor);

    const project = await this.prisma.$transaction(async (tx) => {
      const before = await this.findScoped(tx, id, masjidId);
      const cancelled = await tx.project.update({
        where: { id: before.id },
        data: { status: ProjectStatus.CANCELLED },
        select: projectSelect,
      });
      await this.audit.record(
        {
          masjidId,
          actor,
          action: AUDIT_ACTION.CANCEL,
          entity: AUDIT_ENTITY.PROJECT,
          entityId: cancelled.id,
          summary: `${this.auditSummary(cancelled)} cancelled`,
          before,
          after: cancelled,
        },
        tx,
      );
      return cancelled;
    });

    this.logger.warn({
      message: 'Project cancelled',
      projectId: project.id,
      masjidId,
    });
    return this.toProjectResponse(project);
  }

  /** The project with this id in this masjid; 404 otherwise (also for another masjid's id). */
  private async findScoped(
    db: PrismaService | Prisma.TransactionClient,
    id: string,
    masjidId: string,
  ): Promise<ProjectRecord> {
    const project = await db.project.findFirst({
      where: { id, masjidId },
      select: projectSelect,
    });

    if (!project) {
      throw new ApiException(
        'Project not found',
        HttpStatus.NOT_FOUND,
        ERROR_CODES.PROJECT_NOT_FOUND,
      );
    }

    return project;
  }

  private buildProjectWhere(
    masjidId: string,
    query: GetProjectsQueryDto,
  ): Prisma.ProjectWhereInput {
    const where: Prisma.ProjectWhereInput = { masjidId };

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
  ): Prisma.ProjectUncheckedCreateInput {
    const data: Prisma.ProjectUncheckedCreateInput = {
      masjidId,
      title: dto.title,
      status: dto.status ?? ProjectStatus.ONGOING,
    };

    if (dto.description !== undefined) data.description = dto.description;
    if (dto.targetAmount !== undefined) data.targetAmount = dto.targetAmount;
    if (dto.startDate !== undefined) data.startDate = new Date(dto.startDate);
    if (dto.endDate !== undefined && dto.endDate !== null) {
      data.endDate = new Date(dto.endDate);
    }

    return data;
  }

  private buildUpdateData(dto: UpdateProjectDto): Prisma.ProjectUpdateInput {
    const data: Prisma.ProjectUpdateInput = {};

    if (dto.title !== undefined) data.title = dto.title;
    if (dto.description !== undefined) data.description = dto.description;
    if (dto.targetAmount !== undefined) data.targetAmount = dto.targetAmount;
    if (dto.status !== undefined) data.status = dto.status;
    if (dto.startDate !== undefined) {
      data.startDate = dto.startDate === null ? null : new Date(dto.startDate);
    }
    if (dto.endDate !== undefined) {
      data.endDate = dto.endDate === null ? null : new Date(dto.endDate);
    }

    return data;
  }

  private auditSummary(project: ProjectRecord): string {
    return `Project "${project.title}" target ${formatMoney(project.targetAmount)} ${project.status}`;
  }

  private toProjectResponse(project: ProjectRecord): ProjectResponse {
    const targetAmount = toAmount(project.targetAmount);
    const collectedAmount = toAmount(project.collectedAmount);
    const spentAmount = toAmount(project.spentAmount);
    // Collected can exceed the target; never report a negative remainder.
    const remainingAmount = toAmount(
      nonNegative(project.targetAmount.minus(project.collectedAmount)),
    );
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
}

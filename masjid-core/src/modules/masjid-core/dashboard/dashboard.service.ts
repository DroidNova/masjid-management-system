import { HttpStatus, Injectable } from '@nestjs/common';
import { ERROR_CODES } from '../../../common/constants/error-codes.constant';
import { ApiException } from '../../../common/exceptions/api.exception';
import { PrismaService } from '../../../prisma/prisma.service';
import { AuthenticatedUser } from '../../platform-core/auth/types/jwt-payload.type';

type BasicUser = {
  id: string;
  fullName: string;
  email: string | null;
  phone: string | null;
};

type DecimalLike =
  | number
  | string
  | { toNumber?: () => number; toString: () => string };

type DashboardMasjid = {
  id: string;
  name: string;
  country: string | null;
  locality: string | null;
  district: string | null;
  state: string | null;
  address: string | null;
  contactNo: string | null;
  description: string | null;
  welcomeMsg: string | null;
  status: string;
  namazTime: DashboardNamazTime | null;
  imamUser: BasicUser | null;
  announcements: DashboardAnnouncement[];
  projects: DashboardProject[];
  imamSalaries: DashboardImamSalary[];
};

type DashboardNamazTime = {
  fajr: string | null;
  zuhr: string | null;
  asr: string | null;
  maghrib: string | null;
  isha: string | null;
  jumma: string | null;
  note: string | null;
};

type DashboardAnnouncement = {
  id: string;
  title: string;
  message: string;
  createdAt: Date;
};

type DashboardProject = {
  id: string;
  title: string;
  targetAmount: DecimalLike;
  collectedAmount: DecimalLike;
  status: string;
};

type DashboardImamSalary = {
  month: number;
  year: number;
  salaryAmount: DecimalLike;
  paidAmount: DecimalLike;
  dueAmount: DecimalLike;
  status: string;
};

type DashboardProjectResponse = {
  id: string;
  title: string;
  targetAmount: number;
  collectedAmount: number;
  progressPercentage: number;
  status: string;
};

type DashboardImamSalaryResponse = {
  latestMonth: number;
  latestYear: number;
  salaryAmount: number;
  paidAmount: number;
  dueAmount: number;
  status: string;
};

type DashboardFinanceSummary = {
  totalCollection: number;
  totalExpense: number;
  currentBalance: number;
  thisMonthCollection: number;
  thisMonthExpense: number;
};

type DashboardResponse = {
  masjid: Omit<
    DashboardMasjid,
    'namazTime' | 'imamUser' | 'announcements' | 'projects' | 'imamSalaries'
  >;
  namazTime: DashboardNamazTime | null;
  imam: BasicUser | null;
  membersCount: number;
  latestAnnouncements: DashboardAnnouncement[];
  projectsSummary: {
    activeProjectsCount: number;
    latestProjects: DashboardProjectResponse[];
  };
  imamSalarySummary: DashboardImamSalaryResponse | null;
  financeSummary: DashboardFinanceSummary;
};

type DashboardUserDelegate = {
  count(args: {
    where: { masjidId: string; status: 'ACTIVE' };
  }): Promise<number>;
};

type DashboardMasjidDelegate = {
  findUnique(args: {
    where: { id: string };
    select: typeof dashboardMasjidSelect;
  }): Promise<DashboardMasjid | null>;
};

type DashboardProjectDelegate = {
  count(args: {
    where: { masjidId: string; status: { in: ['ONGOING', 'PLANNED'] } };
  }): Promise<number>;
};

type DashboardAggregateDelegate = {
  aggregate(args: {
    where: Record<string, unknown>;
    _sum: { amount: true };
  }): Promise<{ _sum: { amount: DecimalLike | null } }>;
};

type DashboardPrismaDelegate = {
  user: DashboardUserDelegate;
  masjid: DashboardMasjidDelegate;
  project: DashboardProjectDelegate;
  collection: DashboardAggregateDelegate;
  expense: DashboardAggregateDelegate;
};

const basicUserSelect = {
  id: true,
  fullName: true,
  email: true,
  phone: true,
} as const;

const dashboardMasjidSelect = {
  id: true,
  name: true,
  country: true,
  locality: true,
  district: true,
  state: true,
  address: true,
  contactNo: true,
  description: true,
  welcomeMsg: true,
  status: true,
  namazTime: {
    select: {
      fajr: true,
      zuhr: true,
      asr: true,
      maghrib: true,
      isha: true,
      jumma: true,
      note: true,
    },
  },
  imamUser: { select: basicUserSelect },
  announcements: {
    where: { isActive: true },
    orderBy: { createdAt: 'desc' },
    take: 3,
    select: {
      id: true,
      title: true,
      message: true,
      createdAt: true,
    },
  },
  projects: {
    where: { status: { in: ['ONGOING', 'PLANNED'] } },
    orderBy: { createdAt: 'desc' },
    take: 3,
    select: {
      id: true,
      title: true,
      targetAmount: true,
      collectedAmount: true,
      status: true,
    },
  },
  imamSalaries: {
    orderBy: [{ year: 'desc' }, { month: 'desc' }],
    take: 1,
    select: {
      month: true,
      year: true,
      salaryAmount: true,
      paidAmount: true,
      dueAmount: true,
      status: true,
    },
  },
} as const;

@Injectable()
export class DashboardService {
  constructor(private readonly prisma: PrismaService) {}

  private get db(): DashboardPrismaDelegate {
    return this.prisma as unknown as DashboardPrismaDelegate;
  }

  async getMyMasjidDashboard(
    actor: AuthenticatedUser,
  ): Promise<DashboardResponse> {
    if (!actor.masjidId) {
      throw new ApiException(
        'Current user is not assigned to a masjid',
        HttpStatus.FORBIDDEN,
        ERROR_CODES.USER_MASJID_NOT_ASSIGNED,
      );
    }

    const masjidRecord = await this.db.masjid.findUnique({
      where: { id: actor.masjidId },
      select: dashboardMasjidSelect,
    });

    if (!masjidRecord) {
      throw new ApiException(
        'Masjid not found',
        HttpStatus.NOT_FOUND,
        ERROR_CODES.MASJID_NOT_FOUND,
      );
    }

    const currentMonthRange = this.getCurrentMonthRange();

    const [
      membersCount,
      activeProjectsCount,
      totalCollection,
      totalExpense,
      thisMonthCollection,
      thisMonthExpense,
    ] = await Promise.all([
      this.db.user.count({
        where: { masjidId: actor.masjidId, status: 'ACTIVE' },
      }),
      this.db.project.count({
        where: {
          masjidId: actor.masjidId,
          status: { in: ['ONGOING', 'PLANNED'] },
        },
      }),
      this.sumCollection({ masjidId: actor.masjidId, status: 'ACTIVE' }),
      this.sumExpense({ masjidId: actor.masjidId, status: 'ACTIVE' }),
      this.sumCollection({
        masjidId: actor.masjidId,
        status: 'ACTIVE',
        collectedAt: currentMonthRange,
      }),
      this.sumExpense({
        masjidId: actor.masjidId,
        status: 'ACTIVE',
        spentAt: currentMonthRange,
      }),
    ]);

    const {
      namazTime,
      imamUser,
      announcements,
      projects,
      imamSalaries,
      ...masjid
    } = masjidRecord;

    return {
      masjid,
      namazTime,
      imam: imamUser,
      membersCount,
      latestAnnouncements: announcements,
      projectsSummary: {
        activeProjectsCount,
        latestProjects: projects.map((project) =>
          this.toDashboardProjectResponse(project),
        ),
      },
      imamSalarySummary: imamSalaries[0]
        ? this.toDashboardImamSalaryResponse(imamSalaries[0])
        : null,
      financeSummary: {
        totalCollection,
        totalExpense,
        currentBalance: totalCollection - totalExpense,
        thisMonthCollection,
        thisMonthExpense,
      },
    };
  }

  private toDashboardProjectResponse(
    project: DashboardProject,
  ): DashboardProjectResponse {
    const targetAmount = this.toNumber(project.targetAmount);
    const collectedAmount = this.toNumber(project.collectedAmount);
    const progressPercentage =
      targetAmount === 0
        ? 0
        : Math.min((collectedAmount / targetAmount) * 100, 100);

    return {
      id: project.id,
      title: project.title,
      targetAmount,
      collectedAmount,
      progressPercentage: Math.round(progressPercentage * 100) / 100,
      status: project.status,
    };
  }

  private toDashboardImamSalaryResponse(
    salary: DashboardImamSalary,
  ): DashboardImamSalaryResponse {
    return {
      latestMonth: salary.month,
      latestYear: salary.year,
      salaryAmount: this.toNumber(salary.salaryAmount),
      paidAmount: this.toNumber(salary.paidAmount),
      dueAmount: this.toNumber(salary.dueAmount),
      status: salary.status,
    };
  }

  private getCurrentMonthRange(): { gte: Date; lte: Date } {
    const now = new Date();
    return {
      gte: new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), 1)),
      lte: new Date(
        Date.UTC(
          now.getUTCFullYear(),
          now.getUTCMonth() + 1,
          0,
          23,
          59,
          59,
          999,
        ),
      ),
    };
  }

  private async sumCollection(where: Record<string, unknown>): Promise<number> {
    const result = await this.db.collection.aggregate({
      where,
      _sum: { amount: true },
    });
    return this.toNumber(result._sum.amount);
  }

  private async sumExpense(where: Record<string, unknown>): Promise<number> {
    const result = await this.db.expense.aggregate({
      where,
      _sum: { amount: true },
    });
    return this.toNumber(result._sum.amount);
  }

  private toNumber(value: DecimalLike | null): number {
    if (value === null) return 0;
    if (typeof value === 'number') return value;
    if (typeof value === 'string') return Number(value);
    if (typeof value.toNumber === 'function') return value.toNumber();

    return Number(value.toString());
  }
}

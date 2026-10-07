import { HttpStatus, Injectable } from '@nestjs/common';
import { ERROR_CODES } from '../../../common/constants/error-codes.constant';
import { ApiException } from '../../../common/exceptions/api.exception';
import { money, toAmount } from '../../../common/money';
import { requireMasjidId } from '../../../common/tenant';
import { Prisma } from '../../../generated/prisma/client';
import { PrismaService } from '../../../prisma/prisma.service';
import { AuthenticatedUser } from '../../platform-core/auth/types/jwt-payload.type';

const basicUserSelect = {
  id: true,
  fullName: true,
  email: true,
  phone: true,
} satisfies Prisma.UserSelect;

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
  // Legacy ImamSalary model; kept as-is until the dashboard is moved to
  // ImamSalaryMonth/Assignment.
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
} satisfies Prisma.MasjidSelect;

type DashboardMasjid = Prisma.MasjidGetPayload<{
  select: typeof dashboardMasjidSelect;
}>;
type DashboardProject = DashboardMasjid['projects'][number];
type DashboardImamSalary = DashboardMasjid['imamSalaries'][number];

@Injectable()
export class DashboardService {
  constructor(private readonly prisma: PrismaService) {}

  async getMyMasjidDashboard(actor: AuthenticatedUser) {
    const masjidId = requireMasjidId(actor);

    const masjidRecord = await this.prisma.masjid.findUnique({
      where: { id: masjidId },
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
      this.prisma.user.count({
        where: { masjidId, status: 'ACTIVE' },
      }),
      this.prisma.project.count({
        where: {
          masjidId,
          status: { in: ['ONGOING', 'PLANNED'] },
        },
      }),
      this.sumCollection({ masjidId, status: 'ACTIVE' }),
      this.sumExpense({ masjidId, status: 'ACTIVE' }),
      this.sumCollection({
        masjidId,
        status: 'ACTIVE',
        collectedAt: currentMonthRange,
      }),
      this.sumExpense({
        masjidId,
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
        totalCollection: toAmount(totalCollection),
        totalExpense: toAmount(totalExpense),
        currentBalance: toAmount(totalCollection.minus(totalExpense)),
        thisMonthCollection: toAmount(thisMonthCollection),
        thisMonthExpense: toAmount(thisMonthExpense),
      },
    };
  }

  private toDashboardProjectResponse(project: DashboardProject) {
    const targetAmount = money(project.targetAmount);
    const collectedAmount = money(project.collectedAmount);
    const progressPercentage = targetAmount.isZero()
      ? money(0)
      : Prisma.Decimal.min(collectedAmount.div(targetAmount).times(100), 100);

    return {
      id: project.id,
      title: project.title,
      targetAmount: toAmount(targetAmount),
      collectedAmount: toAmount(collectedAmount),
      progressPercentage: toAmount(progressPercentage),
      status: project.status,
    };
  }

  private toDashboardImamSalaryResponse(salary: DashboardImamSalary) {
    return {
      latestMonth: salary.month,
      latestYear: salary.year,
      salaryAmount: toAmount(salary.salaryAmount),
      paidAmount: toAmount(salary.paidAmount),
      dueAmount: toAmount(salary.dueAmount),
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

  private async sumCollection(where: Prisma.CollectionWhereInput) {
    const result = await this.prisma.collection.aggregate({
      where,
      _sum: { amount: true },
    });
    return money(result._sum.amount);
  }

  private async sumExpense(where: Prisma.ExpenseWhereInput) {
    const result = await this.prisma.expense.aggregate({
      where,
      _sum: { amount: true },
    });
    return money(result._sum.amount);
  }
}

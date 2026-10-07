import { HttpStatus, Injectable } from '@nestjs/common';
import { ERROR_CODES } from '../../../common/constants/error-codes.constant';
import { ApiException } from '../../../common/exceptions/api.exception';
import { money, toAmount } from '../../../common/money';
import { requireMasjidId } from '../../../common/tenant';
import { Prisma } from '../../../generated/prisma/client';
import { PrismaService } from '../../../prisma/prisma.service';
import { FinanceCalculator } from '../finance/finance-calculator';
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
  // Latest month of the imam salary ledger.
  imamSalaryMonths: {
    orderBy: [{ year: 'desc' }, { month: 'desc' }],
    take: 1,
    select: {
      month: true,
      year: true,
      totalExpected: true,
      totalCollected: true,
      totalDue: true,
      status: true,
    },
  },
} satisfies Prisma.MasjidSelect;

type DashboardMasjid = Prisma.MasjidGetPayload<{
  select: typeof dashboardMasjidSelect;
}>;
type DashboardProject = DashboardMasjid['projects'][number];
type DashboardImamSalary = DashboardMasjid['imamSalaryMonths'][number];

@Injectable()
export class DashboardService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly finance: FinanceCalculator,
  ) {}

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

    const [membersCount, activeProjectsCount, total, thisMonth] =
      await Promise.all([
        this.prisma.user.count({
          where: { masjidId, status: 'ACTIVE' },
        }),
        this.prisma.project.count({
          where: {
            masjidId,
            status: { in: ['ONGOING', 'PLANNED'] },
          },
        }),
        // Same numbers as the finance screen (FinanceCalculator).
        this.finance.totals(masjidId),
        this.finance.totals(masjidId, this.finance.currentMonth()),
      ]);

    const {
      namazTime,
      imamUser,
      announcements,
      projects,
      imamSalaryMonths,
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
      imamSalarySummary: imamSalaryMonths[0]
        ? this.toDashboardImamSalaryResponse(imamSalaryMonths[0])
        : null,
      financeSummary: {
        totalCollection: toAmount(total.income),
        totalExpense: toAmount(total.expenses),
        currentBalance: toAmount(total.balance),
        thisMonthCollection: toAmount(thisMonth.income),
        thisMonthExpense: toAmount(thisMonth.expenses),
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
      // Field names kept for the app: salary = expected from all families.
      salaryAmount: toAmount(salary.totalExpected),
      paidAmount: toAmount(salary.totalCollected),
      dueAmount: toAmount(salary.totalDue),
      status: salary.status,
    };
  }
}

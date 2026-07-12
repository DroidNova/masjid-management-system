import { HttpStatus, Injectable } from '@nestjs/common';
import { ERROR_CODES } from '../../../common/constants/error-codes.constant';
import { ApiException } from '../../../common/exceptions/api.exception';
import { PrismaService } from '../../../prisma/prisma.service';
import { AuthenticatedUser } from '../../platform-core/auth/types/jwt-payload.type';
import {
  CreateImamSalaryDto,
  PaymentStatusDto,
} from './dto/create-imam-salary.dto';
import { GetImamSalariesQueryDto } from './dto/get-imam-salaries-query.dto';
import { UpdateImamSalaryDto } from './dto/update-imam-salary.dto';

type DecimalLike =
  | number
  | string
  | { toNumber?: () => number; toString: () => string };

type BasicUser = {
  id: string;
  fullName: string;
  email: string | null;
  phone: string | null;
};

type ImamSalaryRecord = {
  id: string;
  masjidId: string;
  imamId: string;
  month: number;
  year: number;
  salaryAmount: DecimalLike;
  paidAmount: DecimalLike;
  dueAmount: DecimalLike;
  status: string;
  paidDate: Date | null;
  note: string | null;
  createdAt: Date;
  updatedAt: Date;
  imam: BasicUser;
};

type ImamSalaryResponse = Omit<
  ImamSalaryRecord,
  'salaryAmount' | 'paidAmount' | 'dueAmount'
> & {
  salaryAmount: number;
  paidAmount: number;
  dueAmount: number;
};

type ImamSalaryListResponse = {
  items: ImamSalaryResponse[];
  meta: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
};

type ImamSalaryWhereInput = {
  masjidId: string;
  status?: PaymentStatusDto;
  month?: number;
  year?: number;
};

type ImamSalaryCreateData = {
  masjidId: string;
  imamId: string;
  month: number;
  year: number;
  salaryAmount: number;
  paidAmount: number;
  dueAmount: number;
  status: PaymentStatusDto;
  paidDate?: Date;
  note?: string;
};

type ImamSalaryUpdateData = Partial<{
  month: number;
  year: number;
  salaryAmount: number;
  paidAmount: number;
  dueAmount: number;
  status: PaymentStatusDto;
  paidDate: Date | null;
  note: string | null;
}>;

type ImamSalariesMasjidDelegate = {
  findUnique(args: {
    where: { id: string };
    select: { id: true; imamUserId: true };
  }): Promise<{ id: string; imamUserId: string | null } | null>;
};

type ImamSalariesDelegate = {
  findMany(args: {
    where: ImamSalaryWhereInput;
    skip: number;
    take: number;
    orderBy: [{ year: 'desc' }, { month: 'desc' }];
    select: typeof imamSalarySelect;
  }): Promise<ImamSalaryRecord[]>;
  count(args: { where: ImamSalaryWhereInput }): Promise<number>;
  create(args: {
    data: ImamSalaryCreateData;
    select: typeof imamSalarySelect;
  }): Promise<ImamSalaryRecord>;
  findUnique(args: {
    where: { id: string };
    select: typeof imamSalarySelect;
  }): Promise<ImamSalaryRecord | null>;
  update(args: {
    where: { id: string };
    data: ImamSalaryUpdateData;
    select: typeof imamSalarySelect;
  }): Promise<ImamSalaryRecord>;
  delete(args: {
    where: { id: string };
    select: typeof imamSalarySelect;
  }): Promise<ImamSalaryRecord>;
};

type ImamSalariesPrismaDelegate = {
  masjid: ImamSalariesMasjidDelegate;
  imamSalary: ImamSalariesDelegate;
};

const basicUserSelect = {
  id: true,
  fullName: true,
  email: true,
  phone: true,
} as const;

const imamSalarySelect = {
  id: true,
  masjidId: true,
  imamId: true,
  month: true,
  year: true,
  salaryAmount: true,
  paidAmount: true,
  dueAmount: true,
  status: true,
  paidDate: true,
  note: true,
  createdAt: true,
  updatedAt: true,
  imam: { select: basicUserSelect },
} as const;

@Injectable()
export class ImamSalariesService {
  constructor(private readonly prisma: PrismaService) {}

  private get db(): ImamSalariesPrismaDelegate {
    return this.prisma as unknown as ImamSalariesPrismaDelegate;
  }

  async findMyMasjidSalaries(
    query: GetImamSalariesQueryDto,
    actor: AuthenticatedUser,
  ): Promise<ImamSalaryListResponse> {
    const { masjidId } = await this.getCurrentUserMasjid(actor);
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const where = this.buildSalaryWhere(masjidId, query);

    const [items, total] = await Promise.all([
      this.db.imamSalary.findMany({
        where,
        skip: (page - 1) * limit,
        take: limit,
        orderBy: [{ year: 'desc' }, { month: 'desc' }],
        select: imamSalarySelect,
      }),
      this.db.imamSalary.count({ where }),
    ]);

    return {
      items: items.map((salary) => this.toSalaryResponse(salary)),
      meta: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async create(
    dto: CreateImamSalaryDto,
    actor: AuthenticatedUser,
  ): Promise<ImamSalaryResponse> {
    const { masjidId, imamUserId } = await this.getCurrentUserMasjid(actor);

    if (!imamUserId) {
      throw new ApiException(
        'Imam is not assigned to this masjid',
        HttpStatus.BAD_REQUEST,
        ERROR_CODES.IMAM_NOT_ASSIGNED,
      );
    }

    const paidAmount = dto.paidAmount ?? 0;
    const payment = this.calculatePayment(dto.salaryAmount, paidAmount);

    try {
      const salary = await this.db.imamSalary.create({
        data: {
          masjidId,
          imamId: imamUserId,
          month: dto.month,
          year: dto.year,
          salaryAmount: dto.salaryAmount,
          paidAmount,
          dueAmount: payment.dueAmount,
          status: payment.status,
          ...(dto.paidDate ? { paidDate: new Date(dto.paidDate) } : {}),
          ...(dto.note !== undefined ? { note: dto.note } : {}),
        },
        select: imamSalarySelect,
      });

      return this.toSalaryResponse(salary);
    } catch (error) {
      if (this.isUniqueConstraintError(error)) {
        throw new ApiException(
          'Imam salary record already exists for this month and year',
          HttpStatus.CONFLICT,
          ERROR_CODES.IMAM_SALARY_ALREADY_EXISTS,
        );
      }

      throw error;
    }
  }

  async findOne(
    id: string,
    actor: AuthenticatedUser,
  ): Promise<ImamSalaryResponse> {
    const { masjidId } = await this.getCurrentUserMasjid(actor);
    const salary = await this.ensureSalaryBelongsToMasjid(id, masjidId);

    return this.toSalaryResponse(salary);
  }

  async update(
    id: string,
    dto: UpdateImamSalaryDto,
    actor: AuthenticatedUser,
  ): Promise<ImamSalaryResponse> {
    const { masjidId } = await this.getCurrentUserMasjid(actor);
    const existingSalary = await this.ensureSalaryBelongsToMasjid(id, masjidId);
    const data = this.buildUpdateData(dto, existingSalary);

    if (Object.keys(data).length === 0) {
      throw new ApiException(
        'At least one salary field must be provided',
        HttpStatus.BAD_REQUEST,
        ERROR_CODES.BAD_REQUEST,
      );
    }

    try {
      const salary = await this.db.imamSalary.update({
        where: { id },
        data,
        select: imamSalarySelect,
      });

      return this.toSalaryResponse(salary);
    } catch (error) {
      if (this.isUniqueConstraintError(error)) {
        throw new ApiException(
          'Imam salary record already exists for this month and year',
          HttpStatus.CONFLICT,
          ERROR_CODES.IMAM_SALARY_ALREADY_EXISTS,
        );
      }

      throw error;
    }
  }

  async remove(
    id: string,
    actor: AuthenticatedUser,
  ): Promise<ImamSalaryResponse> {
    const { masjidId } = await this.getCurrentUserMasjid(actor);
    await this.ensureSalaryBelongsToMasjid(id, masjidId);

    const salary = await this.db.imamSalary.delete({
      where: { id },
      select: imamSalarySelect,
    });

    return this.toSalaryResponse(salary);
  }

  private async getCurrentUserMasjid(actor: AuthenticatedUser): Promise<{
    masjidId: string;
    imamUserId: string | null;
  }> {
    if (!actor.masjidId) {
      throw new ApiException(
        'Current user is not assigned to a masjid',
        HttpStatus.FORBIDDEN,
        ERROR_CODES.USER_MASJID_NOT_ASSIGNED,
      );
    }

    const masjid = await this.db.masjid.findUnique({
      where: { id: actor.masjidId },
      select: { id: true, imamUserId: true },
    });

    if (!masjid) {
      throw new ApiException(
        'Masjid not found',
        HttpStatus.NOT_FOUND,
        ERROR_CODES.MASJID_NOT_FOUND,
      );
    }

    return {
      masjidId: actor.masjidId,
      imamUserId: masjid.imamUserId,
    };
  }

  private async ensureSalaryBelongsToMasjid(
    id: string,
    masjidId: string,
  ): Promise<ImamSalaryRecord> {
    const salary = await this.db.imamSalary.findUnique({
      where: { id },
      select: imamSalarySelect,
    });

    if (!salary) {
      throw new ApiException(
        'Imam salary record not found',
        HttpStatus.NOT_FOUND,
        ERROR_CODES.IMAM_SALARY_NOT_FOUND,
      );
    }

    if (salary.masjidId !== masjidId) {
      throw new ApiException(
        'You are not allowed to access this imam salary record',
        HttpStatus.FORBIDDEN,
        ERROR_CODES.IMAM_SALARY_ACCESS_FORBIDDEN,
      );
    }

    return salary;
  }

  private buildSalaryWhere(
    masjidId: string,
    query: GetImamSalariesQueryDto,
  ): ImamSalaryWhereInput {
    const where: ImamSalaryWhereInput = { masjidId };

    if (query.status !== undefined) where.status = query.status;
    if (query.month !== undefined) where.month = query.month;
    if (query.year !== undefined) where.year = query.year;

    return where;
  }

  private buildUpdateData(
    dto: UpdateImamSalaryDto,
    existingSalary: ImamSalaryRecord,
  ): ImamSalaryUpdateData {
    const data: ImamSalaryUpdateData = {};
    const salaryAmount =
      dto.salaryAmount ?? this.toNumber(existingSalary.salaryAmount);
    const paidAmount =
      dto.paidAmount ?? this.toNumber(existingSalary.paidAmount);
    const shouldRecalculatePayment =
      dto.salaryAmount !== undefined || dto.paidAmount !== undefined;

    if (dto.month !== undefined) data.month = dto.month;
    if (dto.year !== undefined) data.year = dto.year;
    if (dto.salaryAmount !== undefined) data.salaryAmount = dto.salaryAmount;
    if (dto.paidAmount !== undefined) data.paidAmount = dto.paidAmount;
    if (dto.paidDate !== undefined) {
      data.paidDate = dto.paidDate === null ? null : new Date(dto.paidDate);
    }
    if (dto.note !== undefined) data.note = dto.note;

    if (shouldRecalculatePayment) {
      const payment = this.calculatePayment(salaryAmount, paidAmount);
      data.dueAmount = payment.dueAmount;
      data.status = payment.status;
    }

    return data;
  }

  private calculatePayment(
    salaryAmount: number,
    paidAmount: number,
  ): { dueAmount: number; status: PaymentStatusDto } {
    if (paidAmount > salaryAmount) {
      throw new ApiException(
        'Paid amount cannot be greater than salary amount',
        HttpStatus.BAD_REQUEST,
        ERROR_CODES.BAD_REQUEST,
      );
    }

    const dueAmount = salaryAmount - paidAmount;

    if (paidAmount === 0) {
      return { dueAmount, status: PaymentStatusDto.UNPAID };
    }

    if (paidAmount >= salaryAmount) {
      return { dueAmount, status: PaymentStatusDto.PAID };
    }

    return { dueAmount, status: PaymentStatusDto.PARTIAL };
  }

  private toSalaryResponse(salary: ImamSalaryRecord): ImamSalaryResponse {
    return {
      ...salary,
      salaryAmount: this.toNumber(salary.salaryAmount),
      paidAmount: this.toNumber(salary.paidAmount),
      dueAmount: this.toNumber(salary.dueAmount),
    };
  }

  private toNumber(value: DecimalLike): number {
    if (typeof value === 'number') return value;
    if (typeof value === 'string') return Number(value);
    if (typeof value.toNumber === 'function') return value.toNumber();

    return Number(value.toString());
  }

  private isUniqueConstraintError(error: unknown): boolean {
    return (
      typeof error === 'object' &&
      error !== null &&
      'code' in error &&
      (error as { code?: string }).code === 'P2002'
    );
  }
}

import { Logger, HttpStatus, Injectable } from '@nestjs/common';
import { ERROR_CODES } from '../../../common/constants/error-codes.constant';
import { ApiException } from '../../../common/exceptions/api.exception';
import { PrismaService } from '../../../prisma/prisma.service';
import { AuthenticatedUser } from '../../platform-core/auth/types/jwt-payload.type';
import { UpsertNamazTimeDto } from './dto/upsert-namaz-time.dto';

const SUPER_ADMIN_ROLE = 'SUPER_ADMIN';

type NamazTimeRecord = {
  id?: string;
  masjidId: string;
  fajr: string | null;
  zuhr: string | null;
  asr: string | null;
  maghrib: string | null;
  isha: string | null;
  jumma: string | null;
  note: string | null;
  createdAt?: Date;
  updatedAt?: Date;
};

type NamazTimeWriteData = {
  fajr?: string | null;
  zuhr?: string | null;
  asr?: string | null;
  maghrib?: string | null;
  isha?: string | null;
  jumma?: string | null;
  note?: string | null;
};

type NamazTimesMasjidDelegate = {
  findUnique(args: {
    where: { id: string };
    select: { id: true };
  }): Promise<{ id: string } | null>;
};

type NamazTimeDelegate = {
  findUnique(args: {
    where: { masjidId: string };
    select: typeof namazTimeSelect;
  }): Promise<NamazTimeRecord | null>;
  upsert(args: {
    where: { masjidId: string };
    create: { masjidId: string } & NamazTimeWriteData;
    update: NamazTimeWriteData;
    select: typeof namazTimeSelect;
  }): Promise<NamazTimeRecord>;
};

type NamazTimesPrismaDelegate = {
  masjid: NamazTimesMasjidDelegate;
  namazTime: NamazTimeDelegate;
};

const namazTimeSelect = {
  id: true,
  masjidId: true,
  fajr: true,
  zuhr: true,
  asr: true,
  maghrib: true,
  isha: true,
  jumma: true,
  note: true,
  createdAt: true,
  updatedAt: true,
} as const;

@Injectable()
export class NamazTimesService {
  private readonly logger = new Logger(NamazTimesService.name);

  constructor(private readonly prisma: PrismaService) {}

  private get db(): NamazTimesPrismaDelegate {
    return this.prisma as unknown as NamazTimesPrismaDelegate;
  }

  async findByMasjidId(
    masjidId: string,
    actor: AuthenticatedUser,
  ): Promise<NamazTimeRecord> {
    await this.ensureCanAccessMasjid(masjidId, actor);

    const namazTime = await this.db.namazTime.findUnique({
      where: { masjidId },
      select: namazTimeSelect,
    });

    return (
      namazTime ?? {
        masjidId,
        fajr: null,
        zuhr: null,
        asr: null,
        maghrib: null,
        isha: null,
        jumma: null,
        note: null,
      }
    );
  }

  async upsert(
    masjidId: string,
    dto: UpsertNamazTimeDto,
    actor: AuthenticatedUser,
  ): Promise<NamazTimeRecord> {
    await this.ensureCanAccessMasjid(masjidId, actor);
    const data = this.toNamazTimeWriteData(dto);

    const namazTime = await this.db.namazTime.upsert({
      where: { masjidId },
      create: { masjidId, ...data },
      update: data,
      select: namazTimeSelect,
    });
    this.logger.log({ message: 'Namaz times updated', masjidId });
    return namazTime;
  }

  private async ensureCanAccessMasjid(
    masjidId: string,
    actor: AuthenticatedUser,
  ): Promise<void> {
    const masjid = await this.db.masjid.findUnique({
      where: { id: masjidId },
      select: { id: true },
    });

    if (!masjid) {
      throw new ApiException(
        'Masjid not found',
        HttpStatus.NOT_FOUND,
        ERROR_CODES.MASJID_NOT_FOUND,
      );
    }

    if (actor.roles.includes(SUPER_ADMIN_ROLE)) {
      return;
    }

    if (!actor.masjidId) {
      throw new ApiException(
        'Current user is not assigned to a masjid',
        HttpStatus.FORBIDDEN,
        ERROR_CODES.USER_MASJID_NOT_ASSIGNED,
      );
    }

    if (actor.masjidId !== masjidId) {
      throw new ApiException(
        'You are not allowed to access this masjid',
        HttpStatus.FORBIDDEN,
        ERROR_CODES.MASJID_ACCESS_FORBIDDEN,
      );
    }
  }

  private toNamazTimeWriteData(dto: UpsertNamazTimeDto): NamazTimeWriteData {
    const data: NamazTimeWriteData = {};

    this.assignIfDefined(data, 'fajr', dto.fajr);
    this.assignIfDefined(data, 'zuhr', dto.zuhr);
    this.assignIfDefined(data, 'asr', dto.asr);
    this.assignIfDefined(data, 'maghrib', dto.maghrib);
    this.assignIfDefined(data, 'isha', dto.isha);
    this.assignIfDefined(data, 'jumma', dto.jumma);
    this.assignIfDefined(data, 'note', dto.note);

    return data;
  }

  private assignIfDefined(
    data: NamazTimeWriteData,
    key: keyof NamazTimeWriteData,
    value?: string,
  ): void {
    if (value !== undefined) {
      data[key] = value.trim() || null;
    }
  }
}

import { Logger, HttpStatus, Injectable } from '@nestjs/common';
import { ERROR_CODES } from '../../../common/constants/error-codes.constant';
import { ApiException } from '../../../common/exceptions/api.exception';
import { assertSameMasjid, requireMasjidId } from '../../../common/tenant';
import { Prisma } from '../../../generated/prisma/client';
import { PrismaService } from '../../../prisma/prisma.service';
import { AuthenticatedUser } from '../../platform-core/auth/types/jwt-payload.type';
import { UpsertNamazTimeDto } from './dto/upsert-namaz-time.dto';
import { hasPermission, PERMISSIONS } from '../../../access/permissions';

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
} as const satisfies Prisma.NamazTimeSelect;

type NamazTimeRecord = Prisma.NamazTimeGetPayload<{
  select: typeof namazTimeSelect;
}>;

/** Returned when a masjid has not saved its times yet. */
type EmptyNamazTime = Omit<NamazTimeRecord, 'id' | 'createdAt' | 'updatedAt'>;

type NamazTimeField =
  | 'fajr'
  | 'zuhr'
  | 'asr'
  | 'maghrib'
  | 'isha'
  | 'jumma'
  | 'note';

type NamazTimeWriteData = Partial<Record<NamazTimeField, string | null>>;

@Injectable()
export class NamazTimesService {
  private readonly logger = new Logger(NamazTimesService.name);

  constructor(private readonly prisma: PrismaService) {}

  /** Times of the signed-in user's masjid (masjid from the token; one query). */
  findMyMasjid(
    actor: AuthenticatedUser,
  ): Promise<NamazTimeRecord | EmptyNamazTime> {
    return this.read(requireMasjidId(actor));
  }

  /** Saves the signed-in user's masjid times (masjid from the token; one query). */
  upsertMyMasjid(
    dto: UpsertNamazTimeDto,
    actor: AuthenticatedUser,
  ): Promise<NamazTimeRecord> {
    return this.write(requireMasjidId(actor), dto);
  }

  async findByMasjidId(
    masjidId: string,
    actor: AuthenticatedUser,
  ): Promise<NamazTimeRecord | EmptyNamazTime> {
    await this.ensureCanAccessMasjid(masjidId, actor);
    return this.read(masjidId);
  }

  async upsert(
    masjidId: string,
    dto: UpsertNamazTimeDto,
    actor: AuthenticatedUser,
  ): Promise<NamazTimeRecord> {
    await this.ensureCanAccessMasjid(masjidId, actor);
    return this.write(masjidId, dto);
  }

  private async read(
    masjidId: string,
  ): Promise<NamazTimeRecord | EmptyNamazTime> {
    const namazTime = await this.prisma.namazTime.findUnique({
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

  private async write(
    masjidId: string,
    dto: UpsertNamazTimeDto,
  ): Promise<NamazTimeRecord> {
    const data = this.toNamazTimeWriteData(dto);

    const namazTime = await this.prisma.namazTime.upsert({
      where: { masjidId },
      create: { masjidId, ...data },
      update: data,
      select: namazTimeSelect,
    });
    this.logger.log({ message: 'Namaz times updated', masjidId });
    return namazTime;
  }

  /**
   * Super admin: any existing masjid. Everyone else: only their own masjid,
   * checked against the token first (no query); their masjid exists (FK).
   */
  private async ensureCanAccessMasjid(
    masjidId: string,
    actor: AuthenticatedUser,
  ): Promise<void> {
    if (!hasPermission(actor, PERMISSIONS.PLATFORM_MASJIDS_MANAGE)) {
      assertSameMasjid(
        masjidId,
        requireMasjidId(actor),
        'You are not allowed to access this masjid',
        ERROR_CODES.MASJID_ACCESS_FORBIDDEN,
      );
      return;
    }

    const masjid = await this.prisma.masjid.findUnique({
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
    key: NamazTimeField,
    value?: string,
  ): void {
    if (value !== undefined) {
      data[key] = value.trim() || null;
    }
  }
}

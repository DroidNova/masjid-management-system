import { HttpStatus, Injectable } from '@nestjs/common';
import { ERROR_CODES } from '../../../common/constants/error-codes.constant';
import { ApiException } from '../../../common/exceptions/api.exception';
import { normalizeMasjidCode } from '../../../common/masjid-code';
import { pageArgs, paged } from '../../../common/pagination';
import { Prisma } from '../../../generated/prisma/client';
import { MasjidStatus } from '../../../generated/prisma/enums';
import { PrismaService } from '../../../prisma/prisma.service';

/*
 * What people outside a masjid may see, with no login. Every field is
 * listed here on purpose: never spread a record or reuse a members'
 * select, so a new column can never become public by accident.
 * Not public: money, projects, members, phone numbers, emails, the imam,
 * the namaz-time note, members-only announcements.
 */

const publicMasjidSelect = {
  publicCode: true,
  name: true,
  locality: true,
  district: true,
  state: true,
  address: true,
} satisfies Prisma.MasjidSelect;

const publicTimesSelect = {
  fajr: true,
  zuhr: true,
  asr: true,
  maghrib: true,
  isha: true,
  jumma: true,
  updatedAt: true,
} satisfies Prisma.NamazTimeSelect;

const publicAnnouncementSelect = {
  id: true,
  title: true,
  message: true,
  createdAt: true,
} satisfies Prisma.AnnouncementSelect;

/** Shown on the masjid's page; older ones are on the announcements list. */
const LATEST_ANNOUNCEMENTS = 5;
const SEARCH_RESULTS = 20;

@Injectable()
export class PublicMasjidsService {
  constructor(private readonly prisma: PrismaService) {}

  /** Approved masjids whose name or place matches, for "find a masjid". */
  async search(query: string) {
    const text = query.trim();
    if (text.length < 2) return { items: [] };
    const items = await this.prisma.masjid.findMany({
      where: {
        status: MasjidStatus.APPROVED,
        OR: [
          { name: { contains: text, mode: 'insensitive' } },
          { locality: { contains: text, mode: 'insensitive' } },
          { district: { contains: text, mode: 'insensitive' } },
        ],
      },
      orderBy: { name: 'asc' },
      take: SEARCH_RESULTS,
      select: publicMasjidSelect,
    });
    return { items };
  }

  /** The masjid's public page: where it is, namaz times, latest public news. */
  async page(code: string) {
    const masjid = await this.prisma.masjid.findFirst({
      where: this.byCode(code),
      select: {
        ...publicMasjidSelect,
        namazTime: { select: publicTimesSelect },
        announcements: {
          where: { isPublic: true, isActive: true },
          orderBy: { createdAt: 'desc' },
          take: LATEST_ANNOUNCEMENTS,
          select: publicAnnouncementSelect,
        },
      },
    });
    if (!masjid) throw this.notFound();
    const { announcements, ...profile } = masjid;
    return { ...profile, latestAnnouncements: announcements };
  }

  /** All public announcements of the masjid, newest first. */
  async announcements(code: string, query: { page?: number; limit?: number }) {
    const masjid = await this.prisma.masjid.findFirst({
      where: this.byCode(code),
      select: { id: true },
    });
    if (!masjid) throw this.notFound();
    const where = { masjidId: masjid.id, isPublic: true, isActive: true };
    const { page, limit, skip, take } = pageArgs(query);
    const [items, total] = await this.prisma.$transaction([
      this.prisma.announcement.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip,
        take,
        select: publicAnnouncementSelect,
      }),
      this.prisma.announcement.count({ where }),
    ]);
    return paged(items, total, page, limit);
  }

  /** Only approved masjids have a public page. */
  private byCode(code: string): Prisma.MasjidWhereInput {
    const publicCode = normalizeMasjidCode(code);
    if (!publicCode) throw this.notFound();
    return { publicCode, status: MasjidStatus.APPROVED };
  }

  private notFound(): ApiException {
    return new ApiException(
      'No masjid with this code',
      HttpStatus.NOT_FOUND,
      ERROR_CODES.MASJID_NOT_FOUND,
    );
  }
}

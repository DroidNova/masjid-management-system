/**
 * The one shape for every paged list in the API:
 *
 *   { items: T[], meta: { page, limit, total, totalPages, hasNextPage } }
 *
 * Build it with `paged(...)`; never hand-roll the envelope.
 */

export type PageMeta = {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
  hasNextPage: boolean;
};

export type Paged<T> = { items: T[]; meta: PageMeta };

export function pageMeta(total: number, page: number, limit: number): PageMeta {
  const totalPages = Math.ceil(total / limit);
  return { page, limit, total, totalPages, hasNextPage: page < totalPages };
}

export function paged<T>(
  items: T[],
  total: number,
  page: number,
  limit: number,
): Paged<T> {
  return { items, meta: pageMeta(total, page, limit) };
}

/** skip/take for Prisma from 1-based page and limit (default 20). */
export function pageArgs(query: { page?: number; limit?: number }) {
  const page = query.page ?? 1;
  const limit = query.limit ?? 20;
  return { page, limit, skip: (page - 1) * limit, take: limit };
}

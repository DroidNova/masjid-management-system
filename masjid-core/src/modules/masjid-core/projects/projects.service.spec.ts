import { Prisma } from '../../../generated/prisma/client';
import { ProjectsService } from './projects.service';

describe('ProjectsService', () => {
  const project = (target: number, collected: number) => ({
    id: 'project-1',
    masjidId: 'masjid-1',
    title: 'Wuzu area',
    description: null,
    targetAmount: new Prisma.Decimal(target),
    collectedAmount: new Prisma.Decimal(collected),
    spentAmount: new Prisma.Decimal(0),
    status: 'ONGOING',
    startDate: null,
    endDate: null,
    createdAt: new Date(),
    updatedAt: new Date(),
  });
  const tx = { project: { findFirst: jest.fn(), update: jest.fn() } };
  const prisma = {
    project: { findFirst: jest.fn() },
    $transaction: jest.fn((fn: (client: typeof tx) => unknown) => fn(tx)),
  };
  const audit = { record: jest.fn() };
  const service = new ProjectsService(prisma as never, audit as never);
  const actor = { id: 'admin-1', fullName: 'Admin', masjidId: 'masjid-1' };

  beforeEach(() => jest.clearAllMocks());

  it('never reports a negative remaining amount', async () => {
    prisma.project.findFirst.mockResolvedValue(project(1000, 1250.5));

    const result = await service.findOne('project-1', actor as never);

    expect(result).toMatchObject({
      collectedAmount: 1250.5,
      remainingAmount: 0,
      progressPercentage: 100,
    });
  });

  it('returns PROJECT_NOT_FOUND for an id of another masjid', async () => {
    prisma.project.findFirst.mockResolvedValue(null);

    await expect(
      service.findOne('project-1', actor as never),
    ).rejects.toMatchObject({
      status: 404,
      response: expect.objectContaining({
        errorCode: 'PROJECT_NOT_FOUND',
      }) as unknown,
    });
    expect(prisma.project.findFirst).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { id: 'project-1', masjidId: 'masjid-1' },
      }),
    );
  });

  it('never writes collected or spent amounts from the request', async () => {
    tx.project.findFirst.mockResolvedValue(project(1000, 200));
    tx.project.update.mockResolvedValue(project(2000, 200));

    await service.update(
      'project-1',
      { targetAmount: 2000, collectedAmount: 9999 } as never,
      actor as never,
    );

    expect(tx.project.update).toHaveBeenCalledWith(
      expect.objectContaining({ data: { targetAmount: 2000 } }),
    );
  });
});

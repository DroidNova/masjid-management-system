import 'package:masjid_core_frontend/core/pagination/page.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/auth/data/models/app_user.dart';
import 'package:masjid_core_frontend/features/projects/data/models/project_model.dart';
import 'package:masjid_core_frontend/features/projects/data/models/projects_filter.dart';
import 'package:masjid_core_frontend/features/projects/data/projects_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockProjectsRepository extends Mock implements ProjectsRepository {}

/// Auth fixed to a signed-in user with [permissions] (no storage, no network).
class SignedInAs extends AuthController {
  SignedInAs(this.permissions);

  final List<String> permissions;

  @override
  AuthState build() => AuthSignedIn(
    AppUser(id: 'u1', fullName: 'Test User', permissions: permissions),
  );
}

void registerProjectFallbacks() {
  registerFallbackValue(const ProjectsFilter());
}

ProjectModel project(String id, {String title = 'New Wuzu Area'}) =>
    ProjectModel.fromJson(<String, dynamic>{
      'id': id,
      'title': title,
      'description': 'Construction of new wuzu area',
      'targetAmount': 200000,
      'collectedAmount': 80000,
      'spentAmount': 30000,
      'remainingAmount': 120000,
      'progressPercentage': 40,
      'status': 'ONGOING',
      'startDate': '2026-06-01T00:00:00.000Z',
      'endDate': null,
      'createdAt': '2026-06-01T10:00:00.000Z',
    });

PageResult<ProjectModel> projectsPage(
  List<ProjectModel> items, {
  int page = 1,
  bool hasNext = false,
}) => PageResult<ProjectModel>(
  items: items,
  meta: PageMeta(
    page: page,
    limit: 20,
    total: items.length,
    totalPages: hasNext ? page + 1 : page,
    hasNextPage: hasNext,
  ),
);

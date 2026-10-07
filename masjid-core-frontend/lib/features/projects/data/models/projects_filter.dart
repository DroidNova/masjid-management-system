import 'package:freezed_annotation/freezed_annotation.dart';

part 'projects_filter.freezed.dart';

/// Query parameters of `GET /projects/my-masjid`.
@freezed
abstract class ProjectsFilter with _$ProjectsFilter {
  const ProjectsFilter._();

  const factory ProjectsFilter({
    /// PLANNED, ONGOING, COMPLETED or CANCELLED; null shows all.
    String? status,
    String? search,
  }) = _ProjectsFilter;

  Map<String, dynamic> toQuery() => <String, dynamic>{
    if (status != null) 'status': status,
    if (search != null && search!.trim().isNotEmpty) 'search': search!.trim(),
  };
}

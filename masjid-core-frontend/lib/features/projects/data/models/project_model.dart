import 'package:freezed_annotation/freezed_annotation.dart';

part 'project_model.freezed.dart';
part 'project_model.g.dart';

/// A masjid project (`/projects/my-masjid`, `/projects/{id}`).
@freezed
abstract class ProjectModel with _$ProjectModel {
  const factory ProjectModel({
    required String id,
    required String title,
    String? description,
    @Default(0) double targetAmount,
    @Default(0) double collectedAmount,
    @Default(0) double spentAmount,

    /// targetAmount - collectedAmount, computed by the server.
    @Default(0) double remainingAmount,

    /// 0-100, computed by the server.
    @Default(0) double progressPercentage,

    /// PLANNED, ONGOING, COMPLETED or CANCELLED.
    @Default('ONGOING') String status,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ProjectModel;

  factory ProjectModel.fromJson(Map<String, dynamic> json) =>
      _$ProjectModelFromJson(json);
}

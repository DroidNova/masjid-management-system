import 'package:platform_core_frontend/shared/models/audit_info.dart';
import 'package:platform_core_frontend/features/finance/data/models/finance_model_parsing.dart';

class CollectionEntryModel {
  const CollectionEntryModel({
    required this.id,
    required this.type,
    required this.amount,
    this.title,
    this.description,
    this.collectedAt,
    this.status,
    this.auditInfo = const AuditInfo(),
    this.createdAt,
  });

  factory CollectionEntryModel.fromJson(Map<String, dynamic> json) {
    return CollectionEntryModel(
      id: parseRequiredString(json['id']),
      type: parseRequiredString(json['type']),
      amount: parseDouble(json['amount']),
      title: parseOptionalString(json['title']),
      description: parseOptionalString(json['description']),
      collectedAt: parseOptionalString(json['collectedAt']),
      status: parseOptionalString(json['status']),
      auditInfo: AuditInfo.fromJson(json),
      createdAt: parseOptionalString(json['createdAt']),
    );
  }

  final String id;
  final String type;
  final double amount;
  final String? title;
  final String? description;
  final String? collectedAt;
  final String? status;
  final AuditInfo auditInfo;
  final String? createdAt;
}

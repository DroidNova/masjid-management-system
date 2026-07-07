import 'package:platform_core_frontend/features/finance/data/models/finance_model_parsing.dart';

class CreateCollectionRequest {
  const CreateCollectionRequest({
    required this.type,
    required this.amount,
    this.title,
    this.description,
    this.collectedAt,
  });

  final String type;
  final double amount;
  final String? title;
  final String? description;
  final String? collectedAt;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'type': type,
      'amount': amount,
    };
    addStringIfNotEmpty(json, 'title', title);
    addStringIfNotEmpty(json, 'description', description);
    addStringIfNotEmpty(json, 'collectedAt', collectedAt);
    return json;
  }
}

/// Body for recording a contribution. `collectionType` is required for a
/// general collection contribution and ignored for a project contribution.
class NewContribution {
  const NewContribution({
    this.memberId,
    required this.contributorName,
    this.contributorPhone,
    required this.amount,
    required this.paymentMode,
    required this.paidAt,
    this.note,
    this.collectionType,
  });

  final String? memberId;
  final String contributorName;
  final String? contributorPhone;
  final double amount;
  final String paymentMode;
  final DateTime paidAt;
  final String? note;
  final String? collectionType;

  Map<String, dynamic> toJson() {
    final phone = contributorPhone?.trim();
    final trimmedNote = note?.trim();
    return <String, dynamic>{
      if (memberId != null && memberId!.isNotEmpty) 'memberId': memberId,
      'contributorName': contributorName.trim(),
      if (phone != null && phone.isNotEmpty) 'contributorPhone': phone,
      if (collectionType != null) 'collectionType': collectionType,
      'amount': amount,
      'paymentMode': paymentMode,
      'paidAt': paidAt.toIso8601String(),
      if (trimmedNote != null && trimmedNote.isNotEmpty) 'note': trimmedNote,
    };
  }
}

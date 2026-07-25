class TrackMasjidApplicationResult {
  const TrackMasjidApplicationResult({
    required this.masjidName,
    required this.status,
    this.imamName,
    this.requestedAt,
    this.reviewedAt,
  });

  factory TrackMasjidApplicationResult.fromJson(Map<String, dynamic> json) {
    return TrackMasjidApplicationResult(
      masjidName: _readString(json['masjidName'], fallback: 'Masjid request'),
      status: _readString(json['status'], fallback: 'PENDING'),
      imamName: _readNullableString(json['imamName']),
      requestedAt: _readDate(json['requestedAt'] ?? json['createdAt']),
      reviewedAt: _readDate(json['reviewedAt']),
    );
  }

  final String masjidName;
  final String status;
  final String? imamName;
  final DateTime? requestedAt;
  final DateTime? reviewedAt;
}

String _readString(Object? value, {String fallback = ''}) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) return fallback;
  return text;
}

String? _readNullableString(Object? value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) return null;
  return text;
}

DateTime? _readDate(Object? value) {
  if (value is DateTime) return value;
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) return null;
  return DateTime.tryParse(text);
}

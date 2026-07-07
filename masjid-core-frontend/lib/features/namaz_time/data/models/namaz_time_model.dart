class NamazTimeModel {
  const NamazTimeModel({
    this.id,
    this.masjidId,
    this.fajr,
    this.zuhr,
    this.asr,
    this.maghrib,
    this.isha,
    this.jumma,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  factory NamazTimeModel.fromJson(Map<String, dynamic> json) {
    return NamazTimeModel(
      id: _optionalString(json['id']),
      masjidId: _optionalString(json['masjidId']),
      fajr: _optionalString(json['fajr']),
      zuhr: _optionalString(json['zuhr']),
      asr: _optionalString(json['asr']),
      maghrib: _optionalString(json['maghrib']),
      isha: _optionalString(json['isha']),
      jumma: _optionalString(json['jumma']),
      note: _optionalString(json['note']),
      createdAt: _optionalString(json['createdAt']),
      updatedAt: _optionalString(json['updatedAt']),
    );
  }

  final String? id;
  final String? masjidId;
  final String? fajr;
  final String? zuhr;
  final String? asr;
  final String? maghrib;
  final String? isha;
  final String? jumma;
  final String? note;
  final String? createdAt;
  final String? updatedAt;
}

String? _optionalString(Object? value) {
  final parsed = value?.toString();
  if (parsed == null || parsed.trim().isEmpty) return null;
  return parsed;
}

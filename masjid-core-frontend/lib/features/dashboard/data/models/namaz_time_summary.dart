import 'package:platform_core_frontend/features/dashboard/data/models/model_parsing.dart';

class NamazTimeSummary {
  const NamazTimeSummary({
    this.fajr,
    this.zuhr,
    this.asr,
    this.maghrib,
    this.isha,
    this.jumma,
    this.note,
  });

  factory NamazTimeSummary.fromJson(Map<String, dynamic> json) {
    return NamazTimeSummary(
      fajr: parseString(json['fajr']),
      zuhr: parseString(json['zuhr']),
      asr: parseString(json['asr']),
      maghrib: parseString(json['maghrib']),
      isha: parseString(json['isha']),
      jumma: parseString(json['jumma']),
      note: parseString(json['note']),
    );
  }

  final String? fajr;
  final String? zuhr;
  final String? asr;
  final String? maghrib;
  final String? isha;
  final String? jumma;
  final String? note;
}

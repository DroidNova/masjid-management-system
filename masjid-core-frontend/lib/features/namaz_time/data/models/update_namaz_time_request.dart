class UpdateNamazTimeRequest {
  const UpdateNamazTimeRequest({
    this.fajr,
    this.zuhr,
    this.asr,
    this.maghrib,
    this.isha,
    this.jumma,
    this.note,
  });

  final String? fajr;
  final String? zuhr;
  final String? asr;
  final String? maghrib;
  final String? isha;
  final String? jumma;
  final String? note;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    _addIfNotEmpty(json, 'fajr', fajr);
    _addIfNotEmpty(json, 'zuhr', zuhr);
    _addIfNotEmpty(json, 'asr', asr);
    _addIfNotEmpty(json, 'maghrib', maghrib);
    _addIfNotEmpty(json, 'isha', isha);
    _addIfNotEmpty(json, 'jumma', jumma);
    _addIfNotEmpty(json, 'note', note);
    return json;
  }

  void _addIfNotEmpty(Map<String, dynamic> json, String key, String? value) {
    final trimmedValue = value?.trim();
    if (trimmedValue != null && trimmedValue.isNotEmpty) {
      json[key] = trimmedValue;
    }
  }
}

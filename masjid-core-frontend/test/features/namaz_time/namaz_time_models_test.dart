import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/features/namaz_time/data/models/namaz_time_model.dart';
import 'package:masjid_core_frontend/features/namaz_time/data/models/update_namaz_time_request.dart';

void main() {
  test('reads a masjid that has not saved times yet', () {
    final model = NamazTimeModel.fromJson(const <String, dynamic>{
      'masjidId': 'm1',
      'fajr': null,
      'zuhr': null,
      'asr': null,
      'maghrib': null,
      'isha': null,
      'jumma': null,
      'note': null,
    });
    expect(model.masjidId, 'm1');
    expect(model.id, isNull);
    expect(model.fajr, isNull);
  });

  test('form request trims values and leaves out empty fields', () {
    final request = UpdateNamazTimeRequest.fromForm(
      fajr: ' 05:00 AM ',
      zuhr: '',
      asr: '   ',
      note: 'Ramadan',
    );
    expect(request.toJson(), <String, dynamic>{
      'fajr': '05:00 AM',
      'note': 'Ramadan',
    });
  });
}

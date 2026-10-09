import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/features/dashboard/data/models/namaz_time_summary.dart';
import 'package:masjid_core_frontend/features/namaz_time/application/prayer_schedule.dart';

const _times = NamazTimeSummary(
  fajr: '05:00 AM',
  zuhr: '01:30 PM',
  asr: '05:00 PM',
  maghrib: '06:45 PM',
  isha: '08:15 PM',
  jumma: '01:15 PM',
);

// 2026-10-08 is a Thursday, 2026-10-09 a Friday.
final _thursday = DateTime(2026, 10, 8);

void main() {
  group('parseNamazTime', () {
    test('reads 12-hour and 24-hour times', () {
      expect(parseNamazTime('05:00 AM'), const TimeOfDay(hour: 5, minute: 0));
      expect(parseNamazTime('1:30 pm'), const TimeOfDay(hour: 13, minute: 30));
      expect(parseNamazTime('12:10 AM'), const TimeOfDay(hour: 0, minute: 10));
      expect(parseNamazTime('12:10 PM'), const TimeOfDay(hour: 12, minute: 10));
      expect(parseNamazTime('17:05'), const TimeOfDay(hour: 17, minute: 5));
    });

    test('empty or unreadable text is null', () {
      expect(parseNamazTime(null), isNull);
      expect(parseNamazTime(''), isNull);
      expect(parseNamazTime('after Asr'), isNull);
      expect(parseNamazTime('13:00 PM'), isNull);
      expect(parseNamazTime('10:75'), isNull);
    });
  });

  group('prayersOfDay', () {
    test('five prayers in order, Zuhr on weekdays', () {
      final prayers = prayersOfDay(_times, isFriday: false);
      expect(prayers.map((p) => p.prayer), <Prayer>[
        Prayer.fajr,
        Prayer.zuhr,
        Prayer.asr,
        Prayer.maghrib,
        Prayer.isha,
      ]);
    });

    test('Jumma replaces Zuhr on Fridays when set', () {
      final prayers = prayersOfDay(_times, isFriday: true);
      expect(prayers[1].prayer, Prayer.jumma);
      expect(prayers[1].time, const TimeOfDay(hour: 13, minute: 15));

      const noJumma = NamazTimeSummary(zuhr: '01:30 PM');
      expect(prayersOfDay(noJumma, isFriday: true).single.prayer, Prayer.zuhr);
    });

    test('prayers without a time are left out', () {
      const partial = NamazTimeSummary(fajr: '05:00 AM', isha: '');
      expect(prayersOfDay(partial, isFriday: false).single.prayer, Prayer.fajr);
      expect(prayersOfDay(null, isFriday: false), isEmpty);
    });
  });

  group('nextPrayer', () {
    test('the next one today, with the time left', () {
      final now = _thursday.add(const Duration(hours: 15, minutes: 40));
      final next = nextPrayer(_times, now)!;
      expect(next.prayer.prayer, Prayer.asr);
      expect(next.until, const Duration(hours: 1, minutes: 20));
    });

    test("after Isha it is tomorrow's Fajr", () {
      final now = _thursday.add(const Duration(hours: 21));
      final next = nextPrayer(_times, now)!;
      expect(next.prayer.prayer, Prayer.fajr);
      expect(next.at, DateTime(2026, 10, 9, 5));
      expect(next.until, const Duration(hours: 8));
    });

    test('on Friday noon the next one is Jumma', () {
      final friday = DateTime(2026, 10, 9, 11);
      expect(nextPrayer(_times, friday)!.prayer.prayer, Prayer.jumma);
    });

    test('no times means no next prayer', () {
      expect(nextPrayer(const NamazTimeSummary(), _thursday), isNull);
    });
  });
}

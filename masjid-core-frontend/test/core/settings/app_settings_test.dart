import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/core/settings/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _container() async {
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  test('defaults: no language chosen, normal text, read-aloud on', () async {
    final settings = (await _container()).read(appSettingsProvider);
    expect(settings.language, isNull);
    expect(settings.hasChosenLanguage, isFalse);
    expect(settings.largeText, isFalse);
    expect(settings.readAloud, isTrue);
  });

  test('changes are saved and read back on the next start', () async {
    final first = await _container();
    final controller = first.read(appSettingsProvider.notifier);
    await controller.setLanguage(AppLanguage.urdu);
    await controller.setLargeText(true);
    await controller.setReadAloud(false);

    final settings = (await _container()).read(appSettingsProvider);
    expect(settings.language, AppLanguage.urdu);
    expect(settings.largeText, isTrue);
    expect(settings.readAloud, isFalse);
  });

  test('an unknown saved language code is ignored', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'settings.language': 'xx',
    });
    expect((await _container()).read(appSettingsProvider).language, isNull);
  });
}

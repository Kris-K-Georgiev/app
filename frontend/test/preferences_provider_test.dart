import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/providers/preferences_provider.dart';
import 'package:flutter/material.dart';
import 'package:frontend/ui/typography_scale.dart';

void main(){
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PreferencesProvider', (){
    test('load defaults then persist changes', () async {
      SharedPreferences.setMockInitialValues({});
      final p = PreferencesProvider();
      await p.load();
      expect(p.typographyMode, TypographyMode.app);
      expect(p.haptics, 2);
      expect(p.locale, isNull);

      await p.setTypographyMode(TypographyMode.material);
      await p.setHaptics(1);
      await p.setLocale(const Locale('en'));

      final p2 = PreferencesProvider();
      await p2.load();
      expect(p2.typographyMode, TypographyMode.material);
      expect(p2.haptics, 1);
      expect(p2.locale?.languageCode, 'en');
    });

    test('haptics level clamps', () async {
      SharedPreferences.setMockInitialValues({});
      final p = PreferencesProvider();
      await p.load();
      await p.setHaptics(99);
      expect(p.haptics, 2);
      await p.setHaptics(-5);
      expect(p.haptics, 0);
    });
  });
}

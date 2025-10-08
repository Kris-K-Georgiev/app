import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ui/typography_scale.dart';

/// Stores user UI preferences (typography scale, haptics accessibility, etc.)
class PreferencesProvider extends ChangeNotifier {
  static const _kTypographyKey = 'pref_typography_mode';
  static const _kHapticsKey = 'pref_haptics_intensity';
  static const _kLocaleKey = 'pref_locale';
  // haptics: 0 = off, 1 = reduced, 2 = full

  TypographyMode _typographyMode = TypographyMode.app;
  int _haptics = 2;
  Locale? _locale;
  bool _loaded = false;

  TypographyMode get typographyMode => _typographyMode;
  int get haptics => _haptics; // expose for adaptive feedback
  Locale? get locale => _locale;
  bool get loaded => _loaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final modeStr = prefs.getString(_kTypographyKey);
    final h = prefs.getInt(_kHapticsKey);
    if (modeStr != null) {
      _typographyMode = modeStr == 'material' ? TypographyMode.material : TypographyMode.app;
    }
    if (h != null) _haptics = h.clamp(0, 2);
    final loc = prefs.getString(_kLocaleKey);
    if(loc!=null){ final parts = loc.split('_'); if(parts.isNotEmpty){ _locale = parts.length>1? Locale(parts[0], parts[1]) : Locale(parts[0]); }}
    _loaded = true;
    notifyListeners();
  }

  Future<void> setTypographyMode(TypographyMode mode) async {
    _typographyMode = mode; notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTypographyKey, mode == TypographyMode.material ? 'material' : 'app');
  }

  Future<void> setHaptics(int level) async {
    _haptics = level.clamp(0, 2); notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kHapticsKey, _haptics);
  }

  Future<void> setLocale(Locale? locale) async {
    _locale = locale; notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if(locale==null){ await prefs.remove(_kLocaleKey); } else { await prefs.setString(_kLocaleKey, locale.countryCode==null? locale.languageCode : '${locale.languageCode}_${locale.countryCode}'); }
  }
}

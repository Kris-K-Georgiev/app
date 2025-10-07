import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { system, light, dark }

class ThemeProvider extends ChangeNotifier {
  AppThemeMode _mode = AppThemeMode.system;
  bool _initialized = false;
  AppThemeMode get mode => _mode;
  bool get initialized => _initialized;

  ThemeProvider(){ _load(); }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('theme_mode');
    if(value!=null){ _mode = AppThemeMode.values.firstWhere((e)=> e.name==value, orElse: ()=> AppThemeMode.system); }
    _initialized = true; notifyListeners();
  }

  Future<void> setMode(AppThemeMode m) async {
    _mode = m; notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', m.name);
  }

  ThemeMode get flutterMode => switch(_mode){
    AppThemeMode.system => ThemeMode.system,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
  };
}

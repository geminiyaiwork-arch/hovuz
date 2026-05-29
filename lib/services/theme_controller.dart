import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { light, dark, system }

class ThemeController extends ChangeNotifier {
  ThemeController(this._mode);

  AppThemeMode _mode;
  AppThemeMode get mode => _mode;

  static const _prefsKey = 'hovuz.theme.v1';

  Future<void> set(AppThemeMode m) async {
    if (_mode == m) return;
    _mode = m;
    notifyListeners();
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_prefsKey, m.name);
    } catch (_) {}
  }

  Future<void> cycle() async {
    final next = switch (_mode) {
      AppThemeMode.light => AppThemeMode.dark,
      AppThemeMode.dark => AppThemeMode.system,
      AppThemeMode.system => AppThemeMode.light,
    };
    await set(next);
  }

  static Future<ThemeController> load() async {
    AppThemeMode initial = AppThemeMode.light;
    try {
      final p = await SharedPreferences.getInstance();
      final s = p.getString(_prefsKey);
      if (s != null) {
        initial = AppThemeMode.values.firstWhere(
          (e) => e.name == s,
          orElse: () => AppThemeMode.light,
        );
      }
    } catch (_) {}
    return ThemeController(initial);
  }
}

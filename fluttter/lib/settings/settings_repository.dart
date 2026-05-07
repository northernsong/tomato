import 'package:shared_preferences/shared_preferences.dart';

import 'app_settings.dart';

/// 读写本地 [AppSettings]。
class SettingsRepository {
  SettingsRepository._();

  static final SettingsRepository instance = SettingsRepository._();

  static const _prefsKey = 'tomato_app_settings_v1';

  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings.decode(prefs.getString(_prefsKey));
  }

  Future<void> save(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, settings.encode());
  }
}

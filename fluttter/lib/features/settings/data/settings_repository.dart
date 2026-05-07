import 'package:shared_preferences/shared_preferences.dart';

import '../domain/app_settings.dart';

/// 使用 [SharedPreferences] 读写 [AppSettings]。
///
/// 单例即可：设置页与将来其它入口共享同一份本地缓存。
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

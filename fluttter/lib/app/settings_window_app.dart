import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../features/settings/presentation/settings_page.dart';
import 'theme/tomato_theme.dart';

/// 独立设置窗口根组件（单独 Flutter 引擎实例）。
class SettingsWindowApp extends StatelessWidget {
  const SettingsWindowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '番茄钟 · 设置',
      debugShowCheckedModeBanner: false,
      theme: buildTomatoLightTheme(),
      home: SettingsPage(
        onRequestCloseWindow: () async {
          await windowManager.close();
        },
      ),
    );
  }
}

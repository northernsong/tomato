import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'app/settings_window_app.dart';
import 'app/tomato_app.dart';
import 'windowing/tomato_platform.dart';
import 'windowing/tomato_window_arguments.dart';
import 'windowing/tomato_window_controller_x.dart';

/// 程序入口。
///
/// 桌面端初始化 [window_manager] 与 [desktop_multi_window]；按窗口参数分支为主窗或独立设置窗。
Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!tomatoIsDesktop) {
    runApp(const TomatoApp());
    return;
  }

  await windowManager.ensureInitialized();
  final windowController = await WindowController.fromCurrentEngine();
  await windowController.registerTomatoMethodHandlers();

  final windowKind = TomatoWindowArguments.parse(windowController.arguments);

  switch (windowKind) {
    case TomatoMainWindowArguments():
      const windowOptions = WindowOptions(
        size: Size(320, 440),
        minimumSize: Size(260, 220),
        maximumSize: Size(560, 920),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.hidden,
      );
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
      runApp(const TomatoApp());
    case TomatoSettingsWindowArguments():
      const settingsOptions = WindowOptions(
        size: Size(560, 720),
        minimumSize: Size(440, 480),
        center: true,
        backgroundColor: Color(0xFFF6F5F1),
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.normal,
      );
      windowManager.waitUntilReadyToShow(settingsOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
      runApp(const SettingsWindowApp());
  }
}

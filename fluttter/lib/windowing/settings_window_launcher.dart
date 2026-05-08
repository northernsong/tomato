import 'package:desktop_multi_window/desktop_multi_window.dart';

import 'tomato_platform.dart';
import 'tomato_window_arguments.dart';

/// 打开独立设置窗口；若已存在则 [WindowController.show] 前置。
Future<void> openSettingsWindowOrFocusExisting() async {
  if (!tomatoIsDesktop) return;

  final all = await WindowController.getAll();
  for (final c in all) {
    if (TomatoWindowArguments.parse(c.arguments) is TomatoSettingsWindowArguments) {
      await c.show();
      return;
    }
  }

  await WindowController.create(
    WindowConfiguration(
      hiddenAtLaunch: true,
      arguments: TomatoSettingsWindowArguments.createArguments(),
    ),
  );
}

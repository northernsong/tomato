import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

/// 与 [desktop_multi_window] 示例一致：子窗口通过 channel 调用 [windowManager.center] / [close]。
extension TomatoWindowControllerX on WindowController {
  Future<void> registerTomatoMethodHandlers() async {
    await setWindowMethodHandler((call) async {
      switch (call.method) {
        case 'window_center':
          return windowManager.center();
        case 'window_close':
          return windowManager.close();
        default:
          throw MissingPluginException(call.method);
      }
    });
  }
}

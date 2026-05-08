import 'package:flutter/foundation.dart';

/// 是否为桌面端（可安全使用 [window_manager] / [desktop_multi_window]）。
bool get tomatoIsDesktop {
  if (kIsWeb) return false;
  switch (defaultTargetPlatform) {
    case TargetPlatform.macOS:
    case TargetPlatform.windows:
    case TargetPlatform.linux:
      return true;
    default:
      return false;
  }
}

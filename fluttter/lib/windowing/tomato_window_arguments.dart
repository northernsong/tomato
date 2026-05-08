import 'dart:convert';

/// 多窗口引擎启动参数（[desktop_multi_window] 传入的 JSON）。
sealed class TomatoWindowArguments {
  const TomatoWindowArguments();

  static TomatoWindowArguments parse(String raw) {
    if (raw.isEmpty) {
      return const TomatoMainWindowArguments();
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final id = map['businessId'] as String? ?? '';
      switch (id) {
        case TomatoSettingsWindowArguments.businessId:
          return const TomatoSettingsWindowArguments();
        default:
          return const TomatoMainWindowArguments();
      }
    } on Object {
      return const TomatoMainWindowArguments();
    }
  }
}

final class TomatoMainWindowArguments extends TomatoWindowArguments {
  const TomatoMainWindowArguments();
}

final class TomatoSettingsWindowArguments extends TomatoWindowArguments {
  const TomatoSettingsWindowArguments();

  static const businessId = 'settings';

  /// 传给 [WindowController.create] 的 [WindowConfiguration.arguments]。
  static String createArguments() => jsonEncode({'businessId': businessId});
}

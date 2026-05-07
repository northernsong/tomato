import 'package:flutter/material.dart';

import 'tomato_colors.dart';

/// 构建浅色 Material 3 主题。
///
/// 与 [TomatoApp] 配套；若日后支持暗色模式，可在此增加 `buildTomatoDarkTheme`。
ThemeData buildTomatoLightTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: TomatoColors.sage,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: TomatoColors.scaffoldBackground,
  );
}

import 'package:flutter/material.dart';

/// 番茄钟桌面端调色板。
///
/// 视觉参考 Flow：米白底、灰绿强调、卡片略提亮，与系统窗口标题栏风格协调。
abstract final class TomatoColors {
  TomatoColors._();

  /// 主强调色（进度条、主操作圆形按钮）。
  static const Color sage = Color(0xFF7D8F75);

  /// 脚手架背景（窗口大面积底色）。
  static const Color scaffoldBackground = Color(0xFFE8E7E3);

  /// 中央番茄卡片背景。
  static const Color cardBackground = Color(0xFFF6F5F1);

  /// 卡片顶部「窗口化」小圆按钮的底色。
  static const Color chromeIconBackground = Color(0xFFEBEAE6);

  /// 主倒计时数字颜色。
  static const Color timerDigits = Color(0xFF2C2C2C);

  /// 次要说明文字。
  static const Color subtitle = Color(0xFF6B6B6B);

  /// 小图标默认色。
  static const Color chromeIconForeground = Color(0xFF4A4A4A);
}

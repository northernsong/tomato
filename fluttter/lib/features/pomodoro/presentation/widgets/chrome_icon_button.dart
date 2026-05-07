import 'package:flutter/material.dart';

import '../../../../app/theme/tomato_colors.dart';

/// 番茄卡片顶部工具条里的小圆图标按钮。
///
/// 与 macOS/Windows 无边框窗口上的「关闭 / 刷新」等 chrome 操作视觉一致。
class ChromeIconButton extends StatelessWidget {
  const ChromeIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: TomatoColors.chromeIconBackground,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            width: 32,
            height: 32,
            child: Icon(icon, size: 18, color: TomatoColors.chromeIconForeground),
          ),
        ),
      ),
    );
  }
}

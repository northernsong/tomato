import 'package:flutter/material.dart';

import '../../../../app/theme/tomato_colors.dart';

/// 卡片底部主操作：开始 / 暂停 / 继续。
///
/// 根据 [running]、[idle]、[paused] 决定图标与 Tooltip；[ended] 时由外层禁用或隐藏逻辑处理。
class PomodoroMainActionButton extends StatelessWidget {
  const PomodoroMainActionButton({
    super.key,
    required this.running,
    required this.idle,
    required this.paused,
    required this.onPressed,
  });

  final bool running;
  final bool idle;
  final bool paused;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = idle || running || paused;
    final IconData icon;
    final String tip;
    if (idle) {
      icon = Icons.play_arrow;
      tip = '开始';
    } else if (running) {
      icon = Icons.pause;
      tip = '暂停';
    } else {
      icon = Icons.play_arrow;
      tip = '继续';
    }

    return Tooltip(
      message: tip,
      child: Material(
        color: enabled ? TomatoColors.sage : TomatoColors.sage.withValues(alpha: 0.35),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          child: SizedBox(
            width: 52,
            height: 52,
            child: Icon(icon, size: 28, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

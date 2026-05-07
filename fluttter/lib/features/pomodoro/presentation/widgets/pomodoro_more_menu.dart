import 'package:flutter/material.dart';

import '../../../../app/theme/tomato_colors.dart';

/// 「更多」弹出菜单：设置、关于。
///
/// 使用 [PopupMenuButton]；选中「设置」时由 [onOpenSettings] 负责导航，
/// 调用方通常在下一帧再 `Navigator.push`，避免与菜单关闭动画抢同一帧 context。
///
/// [onMenuOpened] / [onMenuClosed] 供父组件在菜单展示期间保持布局（例如悬停工具条），
/// 避免鼠标移入 Overlay 菜单时触发外层的 [MouseRegion.onExit] 把本按钮从树上摘掉。
class PomodoroMoreMenu extends StatelessWidget {
  const PomodoroMoreMenu({
    super.key,
    required this.onAbout,
    required this.onOpenSettings,
    this.onMenuOpened,
    this.onMenuClosed,
  });

  final VoidCallback onAbout;
  final VoidCallback onOpenSettings;

  /// 菜单路由已展示（在打开同步调用）。
  final VoidCallback? onMenuOpened;

  /// 菜单已关闭（无选中、或选中后于下一帧调用，便于与 [onSelected] 收尾顺序一致）。
  final VoidCallback? onMenuClosed;

  void _notifyMenuClosed() {
    final cb = onMenuClosed;
    if (cb == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => cb());
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: '更多操作',
      onOpened: onMenuOpened,
      onCanceled: _notifyMenuClosed,
      padding: EdgeInsets.zero,
      icon: Material(
        color: TomatoColors.chromeIconBackground,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: const SizedBox(
          width: 32,
          height: 32,
          child: Icon(Icons.more_vert, size: 18, color: TomatoColors.chromeIconForeground),
        ),
      ),
      itemBuilder: (ctx) => const [
        PopupMenuItem(value: 'settings', child: Text('设置')),
        PopupMenuItem(value: 'about', child: Text('关于')),
      ],
      onSelected: (value) {
        if (value == 'about') {
          onAbout();
        } else if (value == 'settings') {
          onOpenSettings();
        }
        _notifyMenuClosed();
      },
    );
  }
}

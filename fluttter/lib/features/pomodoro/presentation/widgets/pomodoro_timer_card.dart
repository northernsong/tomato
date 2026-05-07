import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';

import '../../../../app/theme/tomato_colors.dart';
import '../../domain/pomodoro_controller.dart';
import '../../domain/pomodoro_state.dart';
import 'chrome_icon_button.dart';
import 'pomodoro_main_action_button.dart';
import 'pomodoro_more_menu.dart';

/// 中央「番茄卡片」：倒计时、进度条、顶部 chrome、主操作按钮。
///
/// 自己维护鼠标悬停展开工具条的交互，避免把 hover 状态摊到 [PomodoroHomePage]。
/// [PomodoroHomePage] 只负责对话框与 [Navigator] 等需要上层 [BuildContext] 的事。
class PomodoroTimerCard extends StatefulWidget {
  const PomodoroTimerCard({
    super.key,
    required this.controller,
    required this.onCloseWindow,
    required this.onShowHistoryPlaceholder,
    required this.onShowAbout,
    required this.onRequestOpenSettings,
  });

  final PomodoroController controller;

  /// 桌面端关闭窗口（调用 [SystemNavigator.pop] 由首页注入）。
  final VoidCallback onCloseWindow;

  /// 历史记录占位对话框。
  final VoidCallback onShowHistoryPlaceholder;

  final VoidCallback onShowAbout;

  /// 用户点了「设置」；首页应在 [WidgetsBinding.instance.addPostFrameCallback] 里 push。
  final VoidCallback onRequestOpenSettings;

  @override
  State<PomodoroTimerCard> createState() => _PomodoroTimerCardState();
}

class _PomodoroTimerCardState extends State<PomodoroTimerCard> {
  bool _chromeExpanded = false;

  /// 弹出菜单在 Overlay 上，鼠标移入菜单时外层 [MouseRegion] 会收到 onExit；
  /// 为 true 时保持工具条占位，避免 [PopupMenuButton] 被卸载导致无法选中项。
  bool _moreMenuOpen = false;

  void _setMoreMenuOpen(bool open) {
    if (!mounted || _moreMenuOpen == open) return;
    setState(() => _moreMenuOpen = open);
  }

  bool get _chromeVisible => _chromeExpanded || _moreMenuOpen;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return MouseRegion(
      onEnter: (_) => setState(() => _chromeExpanded = true),
      onExit: (_) => setState(() => _chromeExpanded = false),
      child: Material(
        key: const ValueKey('tomato-pomodoro-card'),
        elevation: 2,
        shadowColor: Colors.black26,
        color: TomatoColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: ListenableBuilder(
              listenable: widget.controller,
              builder: (context, _) {
                final s = widget.controller.state;
                final running = s == PomodoroState.running;
                final idle = s == PomodoroState.idle;
                final paused = s == PomodoroState.paused;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        height: _chromeVisible ? 36 : 0,
                        child: _chromeVisible
                            ? Row(
                                children: [
                                  ChromeIconButton(
                                    icon: Icons.close,
                                    tooltip: '关闭',
                                    onPressed: widget.onCloseWindow,
                                  ),
                                  const Spacer(),
                                  ChromeIconButton(
                                    icon: Icons.refresh,
                                    tooltip: '刷新',
                                    onPressed: widget.controller.refresh,
                                  ),
                                  const SizedBox(width: 6),
                                  ChromeIconButton(
                                    icon: Icons.bar_chart_outlined,
                                    tooltip: '历史记录',
                                    onPressed: widget.onShowHistoryPlaceholder,
                                  ),
                                  const SizedBox(width: 2),
                                  PomodoroMoreMenu(
                                    onAbout: widget.onShowAbout,
                                    onOpenSettings: widget.onRequestOpenSettings,
                                    onMenuOpened: () => _setMoreMenuOpen(true),
                                    onMenuClosed: () => _setMoreMenuOpen(false),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.controller.formattedTime,
                      textAlign: TextAlign.center,
                      style: textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 44,
                        height: 1.05,
                        letterSpacing: 1,
                        color: TomatoColors.timerDigits,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      alignment: Alignment.topCenter,
                      child: _chromeVisible
                          ? Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                subtitleForPomodoroState(s),
                                textAlign: TextAlign.center,
                                style: textTheme.bodySmall?.copyWith(
                                  color: TomatoColors.subtitle,
                                  fontSize: 12,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        minHeight: 4,
                        value: widget.controller.progress.clamp(0.0, 1.0),
                        backgroundColor: TomatoColors.sage.withValues(alpha: 0.15),
                        color: TomatoColors.sage,
                      ),
                    ),
                    const SizedBox(height: 16),
                    PomodoroMainActionButton(
                      running: running,
                      idle: idle,
                      paused: paused,
                      onPressed: () {
                        if (idle) {
                          widget.controller.start();
                        } else if (running) {
                          widget.controller.pause();
                        } else if (paused) {
                          widget.controller.resume();
                        }
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// 悬停时倒计时下方的一行状态说明。
String subtitleForPomodoroState(PomodoroState s) {
  switch (s) {
    case PomodoroState.idle:
      return '准备开始';
    case PomodoroState.running:
      return '保持专注';
    case PomodoroState.paused:
      return '已暂停';
    case PomodoroState.ended:
      return '';
  }
}

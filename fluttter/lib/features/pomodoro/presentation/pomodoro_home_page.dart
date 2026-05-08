import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

import '../../../app/theme/tomato_colors.dart';
import '../../../windowing/desktop_window_resize_coordinator.dart';
import '../../../windowing/settings_window_launcher.dart';
import '../../../windowing/tomato_platform.dart';
import '../../settings/presentation/settings_page.dart';
import '../domain/pomodoro_controller.dart';
import '../domain/pomodoro_state.dart';
import 'widgets/pomodoro_timer_card.dart';

/// 番茄钟主界面（单页 Scaffold）。
///
/// 组合 [PomodoroController] 与 [PomodoroTimerCard]；处理「本轮结束」弹窗、
/// 桌面端独立设置窗口与 [Navigator] 等需要稳定 [BuildContext] 的逻辑。
class PomodoroHomePage extends StatefulWidget {
  const PomodoroHomePage({super.key});

  @override
  State<PomodoroHomePage> createState() => _PomodoroHomePageState();
}

class _PomodoroHomePageState extends State<PomodoroHomePage> {
  late final PomodoroController _controller;
  final GlobalKey _frameKey = GlobalKey();

  DesktopWindowResizeCoordinator? _resizeCoordinator;

  /// 避免在结束对话框仍打开时重复弹出或响应 controller 的多次 notify。
  bool _sessionEndedDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = PomodoroController();
    _controller.addListener(_onControllerChanged);
    if (tomatoIsDesktop) {
      _resizeCoordinator = DesktopWindowResizeCoordinator();
    }
  }

  void _onControllerChanged() {
    if (_sessionEndedDialogOpen) return;
    final s = _controller.state;
    if (s == PomodoroState.ended) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showSessionEndedDialog());
    }
  }

  Future<void> _showSessionEndedDialog() async {
    if (!mounted || _sessionEndedDialogOpen) return;
    _sessionEndedDialogOpen = true;
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('本轮结束'),
          content: const Text('占位：后续步骤将在此收集备注并写入飞书番茄记录。'),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _controller.acknowledgeAndReset();
              },
              child: const Text('知道了'),
            ),
          ],
        ),
      );
    } finally {
      _sessionEndedDialogOpen = false;
    }
  }

  void _closeWindow() {
    if (tomatoIsDesktop) {
      unawaited(windowManager.close());
    } else {
      SystemNavigator.pop();
    }
  }

  void _showHistoryPlaceholder() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('历史记录'),
        content: const Text('占位：后续在此展示历史番茄记录。'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('关闭')),
        ],
      ),
    );
  }

  void _openSettingsAfterMenuFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (tomatoIsDesktop) {
        unawaited(openSettingsWindowOrFocusExisting());
      } else {
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => const SettingsPage(),
          ),
        );
      }
    });
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: '番茄钟',
      applicationVersion: '1.0.0',
      children: const [
        Text('桌面番茄钟 MVP'),
      ],
    );
  }

  void _measureAndResizeWindow() {
    if (!tomatoIsDesktop || _resizeCoordinator == null) return;
    final box = _frameKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    unawaited(_resizeCoordinator!.requestSize(box.size));
  }

  EdgeInsets _desktopFramePadding() {
    if (!tomatoIsDesktop) return EdgeInsets.zero;
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
        // 无边框主窗无交通灯占位，对称留白即可。
        return const EdgeInsets.fromLTRB(14, 0, 14, 16);
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return const EdgeInsets.fromLTRB(12, 0, 12, 16);
      default:
        return EdgeInsets.zero;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _resizeCoordinator?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureAndResizeWindow());

    final framed = KeyedSubtree(
      key: _frameKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (tomatoIsDesktop)
            DragToMoveArea(
              child: const SizedBox(
                height: 28,
                width: double.infinity,
                child: ColoredBox(color: Colors.transparent),
              ),
            ),
          Padding(
            padding: _desktopFramePadding(),
            child: Center(
              child: PomodoroTimerCard(
                controller: _controller,
                onCloseWindow: _closeWindow,
                onShowHistoryPlaceholder: _showHistoryPlaceholder,
                onShowAbout: _showAboutDialog,
                onRequestOpenSettings: _openSettingsAfterMenuFrame,
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: TomatoColors.scaffoldBackground,
      body: Align(
        alignment: Alignment.topCenter,
        child: framed,
      ),
    );
  }
}

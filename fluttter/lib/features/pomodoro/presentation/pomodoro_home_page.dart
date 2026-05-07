import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../settings/presentation/settings_page.dart';
import '../domain/pomodoro_controller.dart';
import '../domain/pomodoro_state.dart';
import 'widgets/pomodoro_timer_card.dart';

/// 番茄钟主界面（单页 Scaffold）。
///
/// 组合 [PomodoroController] 与 [PomodoroTimerCard]；处理「本轮结束」弹窗、
/// [Navigator] 去设置页等需要稳定 [BuildContext] 的逻辑。
class PomodoroHomePage extends StatefulWidget {
  const PomodoroHomePage({super.key});

  @override
  State<PomodoroHomePage> createState() => _PomodoroHomePageState();
}

class _PomodoroHomePageState extends State<PomodoroHomePage> {
  late final PomodoroController _controller;

  /// 避免在结束对话框仍打开时重复弹出或响应 controller 的多次 notify。
  bool _sessionEndedDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = PomodoroController();
    _controller.addListener(_onControllerChanged);
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
    SystemNavigator.pop();
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
    // PopupMenu 关闭与路由 push 同一帧时，用子组件 context 可能推不进去；
    // 延后到下一帧并用本 State 持有的 context。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => const SettingsPage(),
        ),
      );
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

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: PomodoroTimerCard(
          controller: _controller,
          onCloseWindow: _closeWindow,
          onShowHistoryPlaceholder: _showHistoryPlaceholder,
          onShowAbout: _showAboutDialog,
          onRequestOpenSettings: _openSettingsAfterMenuFrame,
        ),
      ),
    );
  }
}

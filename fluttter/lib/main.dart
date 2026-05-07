import 'package:flutter/material.dart';

import 'pomodoro/pomodoro_controller.dart';
import 'pomodoro/pomodoro_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TomatoApp());
}

class TomatoApp extends StatelessWidget {
  const TomatoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final seed = const Color(0xFFE05D44);
    return MaterialApp(
      title: '番茄钟',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light),
        useMaterial3: true,
      ),
      home: const PomodoroHomePage(),
    );
  }
}

class PomodoroHomePage extends StatefulWidget {
  const PomodoroHomePage({super.key});

  @override
  State<PomodoroHomePage> createState() => _PomodoroHomePageState();
}

class _PomodoroHomePageState extends State<PomodoroHomePage> {
  late final PomodoroController _controller;
  bool _sessionDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = PomodoroController();
    _controller.addListener(_onControllerTick);
  }

  void _onControllerTick() {
    if (_sessionDialogOpen) return;
    final s = _controller.state;
    if (s == PomodoroState.ended) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showEndedPlaceholder());
    } else if (s == PomodoroState.aborted) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showAbortedPlaceholder());
    }
  }

  Future<void> _showEndedPlaceholder() async {
    if (!mounted || _sessionDialogOpen) return;
    _sessionDialogOpen = true;
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
      _sessionDialogOpen = false;
    }
  }

  Future<void> _showAbortedPlaceholder() async {
    if (!mounted || _sessionDialogOpen) return;
    _sessionDialogOpen = true;
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('已放弃'),
          content: const Text('本次番茄已停止（MVP 不写 aborted 记录）。'),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _controller.acknowledgeAndReset();
              },
              child: const Text('好的'),
            ),
          ],
        ),
      );
    } finally {
      _sessionDialogOpen = false;
    }
  }

  Future<void> _confirmAbort() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认放弃？'),
        content: const Text('放弃后本轮计时会立即停止。'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('取消')),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.red.shade700),
            child: const Text('放弃'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      _controller.abort();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerTick);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('番茄钟'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            final running = _controller.state == PomodoroState.running;
            final idle = _controller.state == PomodoroState.idle;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Text(
                  _controller.formattedTime,
                  textAlign: TextAlign.center,
                  style: textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _subtitle(_controller.state),
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.outline),
                ),
                const SizedBox(height: 28),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    minHeight: 10,
                    value: _controller.progress.clamp(0.0, 1.0),
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonal(
                        onPressed: running ? _confirmAbort : null,
                        child: const Text('放弃'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton(
                        onPressed: idle ? _controller.start : null,
                        child: Text(idle ? '开始' : '进行中…'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            );
          },
        ),
      ),
    );
  }

  String _subtitle(PomodoroState s) {
    switch (s) {
      case PomodoroState.idle:
        return '准备开始一段专注时间';
      case PomodoroState.running:
        return '保持专注';
      case PomodoroState.ended:
      case PomodoroState.aborted:
        return '';
    }
  }
}

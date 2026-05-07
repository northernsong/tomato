import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'pomodoro/pomodoro_controller.dart';
import 'pomodoro/pomodoro_state.dart';
import 'settings/settings_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TomatoApp());
}

/// 参考 Flow 风：米白底、灰绿强调。
const Color _kSage = Color(0xFF7D8F75);
const Color _kScaffoldBg = Color(0xFFE8E7E3);
const Color _kCardBg = Color(0xFFF6F5F1);
const Color _kChromeIconBg = Color(0xFFEBEAE6);

class TomatoApp extends StatelessWidget {
  const TomatoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final seed = _kSage;
    return MaterialApp(
      title: '番茄钟',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light),
        useMaterial3: true,
        scaffoldBackgroundColor: _kScaffoldBg,
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
  bool _cardHovered = false;

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
      body: Center(
        child: MouseRegion(
          onEnter: (_) => setState(() => _cardHovered = true),
          onExit: (_) => setState(() => _cardHovered = false),
          child: Material(
            key: const ValueKey('tomato-pomodoro-card'),
            elevation: 2,
            shadowColor: Colors.black26,
            color: _kCardBg,
            borderRadius: BorderRadius.circular(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                child: ListenableBuilder(
                  listenable: _controller,
                  builder: (context, _) {
                    final s = _controller.state;
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
                            height: _cardHovered ? 36 : 0,
                            child: _cardHovered
                                ? Row(
                                    children: [
                                      _ChromeIconButton(
                                        icon: Icons.close,
                                        tooltip: '关闭',
                                        onPressed: _closeWindow,
                                      ),
                                      const Spacer(),
                                      _ChromeIconButton(
                                        icon: Icons.refresh,
                                        tooltip: '刷新',
                                        onPressed: _controller.refresh,
                                      ),
                                      const SizedBox(width: 6),
                                      _ChromeIconButton(
                                        icon: Icons.bar_chart_outlined,
                                        tooltip: '历史记录',
                                        onPressed: _showHistoryPlaceholder,
                                      ),
                                      const SizedBox(width: 2),
                                      _MoreMenu(
                                        onAbout: () {
                                          showAboutDialog(
                                            context: context,
                                            applicationName: '番茄钟',
                                            applicationVersion: '1.0.0',
                                            children: const [
                                              Text('桌面番茄钟 MVP'),
                                            ],
                                          );
                                        },
                                        onOpenSettings: () {
                                          // PopupMenu 关闭与路由 push 同一帧时，用子组件 context 可能推不进去；延后到下一帧并用主页 State 的 context。
                                          WidgetsBinding.instance.addPostFrameCallback((_) {
                                            if (!mounted) return;
                                            Navigator.of(context).push<void>(
                                              MaterialPageRoute<void>(
                                                builder: (_) => const SettingsPage(),
                                              ),
                                            );
                                          });
                                        },
                                      ),
                                    ],
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _controller.formattedTime,
                          textAlign: TextAlign.center,
                          style: textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 44,
                            height: 1.05,
                            letterSpacing: 1,
                            color: const Color(0xFF2C2C2C),
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          alignment: Alignment.topCenter,
                          child: _cardHovered
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    _subtitle(s),
                                    textAlign: TextAlign.center,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: const Color(0xFF6B6B6B),
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
                            value: _controller.progress.clamp(0.0, 1.0),
                            backgroundColor: _kSage.withValues(alpha: 0.15),
                            color: _kSage,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _MainRoundButton(
                          running: running,
                          idle: idle,
                          paused: paused,
                          onPressed: () {
                            if (idle) {
                              _controller.start();
                            } else if (running) {
                              _controller.pause();
                            } else if (paused) {
                              _controller.resume();
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
        ),
      ),
    );
  }

  String _subtitle(PomodoroState s) {
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
}

class _ChromeIconButton extends StatelessWidget {
  const _ChromeIconButton({
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
        color: _kChromeIconBg,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            width: 32,
            height: 32,
            child: Icon(icon, size: 18, color: const Color(0xFF4A4A4A)),
          ),
        ),
      ),
    );
  }
}

class _MoreMenu extends StatelessWidget {
  const _MoreMenu({
    required this.onAbout,
    required this.onOpenSettings,
  });

  final VoidCallback onAbout;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: '更多操作',
      padding: EdgeInsets.zero,
      icon: Material(
        color: _kChromeIconBg,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: const SizedBox(
          width: 32,
          height: 32,
          child: Icon(Icons.more_vert, size: 18, color: Color(0xFF4A4A4A)),
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
      },
    );
  }
}

class _MainRoundButton extends StatelessWidget {
  const _MainRoundButton({
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
        color: enabled ? _kSage : _kSage.withValues(alpha: 0.35),
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

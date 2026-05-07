import 'dart:async';

import 'package:flutter/foundation.dart';

import 'pomodoro_state.dart';

/// 控制倒计时与状态迁移；UI 通过 [ListenableBuilder] 订阅。
class PomodoroController extends ChangeNotifier {
  PomodoroController({int? totalSeconds})
      : _totalSeconds = totalSeconds ?? defaultTotalSeconds(),
        _remainingSeconds = totalSeconds ?? defaultTotalSeconds();

  PomodoroState _state = PomodoroState.idle;
  int _remainingSeconds;
  final int _totalSeconds;
  Timer? _timer;

  PomodoroState get state => _state;
  int get remainingSeconds => _remainingSeconds;
  int get totalSeconds => _totalSeconds;

  double get progress {
    if (_totalSeconds <= 0) return 0;
    return 1 - (_remainingSeconds / _totalSeconds);
  }

  /// `mm:ss`，用于主界面大字号旁辅助展示或托盘。
  String get formattedTime {
    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// 优先 `--dart-define=TOMATO_POMO_SECONDS=秒数`；否则 debug 下 30 秒便于联调，release 下 25 分钟。
  static int defaultTotalSeconds() {
    const fromEnv = int.fromEnvironment('TOMATO_POMO_SECONDS', defaultValue: 0);
    if (fromEnv > 0) return fromEnv;
    return kDebugMode ? 30 : 25 * 60;
  }

  void start() {
    if (_state == PomodoroState.running) return;
    _timer?.cancel();
    _remainingSeconds = _totalSeconds;
    _state = PomodoroState.running;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    notifyListeners();
  }

  void _tick() {
    if (_state != PomodoroState.running) return;
    if (_remainingSeconds <= 1) {
      _timer?.cancel();
      _timer = null;
      _remainingSeconds = 0;
      _state = PomodoroState.ended;
      notifyListeners();
      return;
    }
    _remainingSeconds -= 1;
    notifyListeners();
  }

  /// 用户确认放弃后调用：停止计时并进入 [PomodoroState.aborted]。
  void abort() {
    if (_state != PomodoroState.running) return;
    _timer?.cancel();
    _timer = null;
    _state = PomodoroState.aborted;
    notifyListeners();
  }

  /// 在 [PomodoroState.ended] / [PomodoroState.aborted] 占位提示关闭后回到 idle。
  void acknowledgeAndReset() {
    if (_state != PomodoroState.ended && _state != PomodoroState.aborted) {
      return;
    }
    _state = PomodoroState.idle;
    _remainingSeconds = _totalSeconds;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

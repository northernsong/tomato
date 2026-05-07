import 'dart:async';

import 'package:flutter/foundation.dart';

import 'pomodoro_state.dart';

/// 番茄钟倒计时与状态迁移（领域逻辑）。
///
/// 继承 [ChangeNotifier]，UI 通过 [ListenableBuilder] 或 [AnimatedBuilder] 订阅。
/// 不依赖 Flutter 控件层，便于单测。
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

  /// 0~1，用于线性进度条：`1 - remaining/total`。
  double get progress {
    if (_totalSeconds <= 0) return 0;
    return 1 - (_remainingSeconds / _totalSeconds);
  }

  /// `mm:ss`，等宽数字特性便于 UI 不跳动。
  String get formattedTime {
    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// 默认一轮总秒数。
  ///
  /// 优先 `--dart-define=TOMATO_POMO_SECONDS=秒数`；否则 debug 下 30 秒便于联调，release 下 25 分钟。
  static int defaultTotalSeconds() {
    const fromEnv = int.fromEnvironment('TOMATO_POMO_SECONDS', defaultValue: 0);
    if (fromEnv > 0) return fromEnv;
    return kDebugMode ? 30 : 25 * 60;
  }

  /// 从 [PomodoroState.idle] 开始新一轮（剩余时间重置为总时长）。
  void start() {
    if (_state != PomodoroState.idle) return;
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

  /// 运行中 → 暂停（停表，保留剩余秒数）。
  void pause() {
    if (_state != PomodoroState.running) return;
    _timer?.cancel();
    _timer = null;
    _state = PomodoroState.paused;
    notifyListeners();
  }

  /// 暂停 → 继续。
  void resume() {
    if (_state != PomodoroState.paused) return;
    _state = PomodoroState.running;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    notifyListeners();
  }

  /// 刷新：运行中或暂停时立即停表，剩余时间恢复为满格并回到 [PomodoroState.idle]；闲置时幂等。
  ///
  /// [PomodoroState.ended] 时不处理（等待用户确认结束对话框）。
  void refresh() {
    if (_state == PomodoroState.ended) return;
    _timer?.cancel();
    _timer = null;
    _remainingSeconds = _totalSeconds;
    _state = PomodoroState.idle;
    notifyListeners();
  }

  /// 在 [PomodoroState.ended] 占位提示关闭后回到 idle。
  void acknowledgeAndReset() {
    if (_state != PomodoroState.ended) {
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

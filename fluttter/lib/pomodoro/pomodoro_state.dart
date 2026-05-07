/// 番茄会话生命周期。
enum PomodoroState {
  /// 未开始或已复位，可点「开始」。
  idle,

  /// 倒计时进行中。
  running,

  /// 已暂停，可继续或刷新回闲置。
  paused,

  /// 正常倒计时到 0。
  ended,
}

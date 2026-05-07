/// 番茄会话生命周期（MVP：无暂停）。
enum PomodoroState {
  /// 未开始或已复位，可点「开始」。
  idle,

  /// 倒计时进行中。
  running,

  /// 正常倒计时到 0。
  ended,

  /// 用户确认放弃后。
  aborted,
}

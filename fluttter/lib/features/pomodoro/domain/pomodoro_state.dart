/// 番茄会话生命周期（状态机枚举）。
///
/// 与 [PomodoroController] 搭配使用：UI 根据当前状态展示文案与主按钮图标。
enum PomodoroState {
  /// 未开始或已复位，可点「开始」。
  idle,

  /// 倒计时进行中。
  running,

  /// 已暂停，可继续或刷新回闲置。
  paused,

  /// 正常倒计时到 0；等待用户确认「本轮结束」对话框后再回到 [idle]。
  ended,
}

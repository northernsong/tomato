package com.tomato.app;

/** 番茄会话状态（第一步：本地假计时闭环）。 */
public enum PomodoroState {
    IDLE,
    RUNNING,
    ENDED,
    ABORTED
}

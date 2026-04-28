package com.tomato.model;

/** 番茄会话状态（本地计时闭环）。 */
public enum PomodoroState {
    IDLE,
    RUNNING,
    PAUSED,
    ENDED,
    ABORTED
}

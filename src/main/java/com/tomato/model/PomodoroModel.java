package com.tomato.model;

import javafx.animation.KeyFrame;
import javafx.animation.Timeline;
import javafx.beans.binding.Bindings;
import javafx.beans.property.IntegerProperty;
import javafx.beans.property.ObjectProperty;
import javafx.beans.property.ReadOnlyDoubleProperty;
import javafx.beans.property.ReadOnlyDoubleWrapper;
import javafx.beans.property.ReadOnlyStringProperty;
import javafx.beans.property.ReadOnlyStringWrapper;
import javafx.beans.property.SimpleIntegerProperty;
import javafx.beans.property.SimpleObjectProperty;
import javafx.util.Duration;

/**
 * 番茄钟领域模型：状态、剩余时间、计时规则。不包含任何 UI 控件。
 */
public final class PomodoroModel {

    public static final int DEFAULT_PLANNED_SECONDS = 60;
    public static final int SESSION_TOTAL = 4;

    private final ObjectProperty<PomodoroState> state = new SimpleObjectProperty<>(PomodoroState.IDLE);
    private final IntegerProperty plannedSeconds = new SimpleIntegerProperty(DEFAULT_PLANNED_SECONDS);
    private final IntegerProperty remainingSeconds = new SimpleIntegerProperty(DEFAULT_PLANNED_SECONDS);
    private final ReadOnlyDoubleWrapper sessionProgress = new ReadOnlyDoubleWrapper(0);
    private final ReadOnlyStringWrapper timeDisplay = new ReadOnlyStringWrapper(formatTime(DEFAULT_PLANNED_SECONDS));

    private final Timeline tickTimeline =
            new Timeline(new KeyFrame(Duration.seconds(1), e -> tickOneSecond()));

    private Runnable onSessionEnded;
    private Runnable onSessionAborted;

    public PomodoroModel() {
        tickTimeline.setCycleCount(Timeline.INDEFINITE);
        state.addListener((o, oldV, newV) -> recalcDerived());
        remainingSeconds.addListener((o, oldV, newV) -> recalcDerived());
        plannedSeconds.addListener((o, oldV, newV) -> recalcDerived());
        sessionProgress.bind(
                Bindings.createDoubleBinding(
                        this::computeSessionProgress, state, remainingSeconds, plannedSeconds));
    }

    public ObjectProperty<PomodoroState> stateProperty() {
        return state;
    }

    public PomodoroState getState() {
        return state.get();
    }

    public ReadOnlyDoubleProperty sessionProgressProperty() {
        return sessionProgress.getReadOnlyProperty();
    }

    public ReadOnlyStringProperty timeDisplayProperty() {
        return timeDisplay.getReadOnlyProperty();
    }

    public int getRemainingSeconds() {
        return remainingSeconds.get();
    }

    public void setOnSessionEnded(Runnable onSessionEnded) {
        this.onSessionEnded = onSessionEnded;
    }

    public void setOnSessionAborted(Runnable onSessionAborted) {
        this.onSessionAborted = onSessionAborted;
    }

    /** 主圆形按钮：开始 / 暂停 / 继续。 */
    public void toggleRunPause() {
        if (state.get() == PomodoroState.RUNNING) {
            tickTimeline.stop();
            state.set(PomodoroState.PAUSED);
            return;
        }
        if (state.get() == PomodoroState.PAUSED) {
            state.set(PomodoroState.RUNNING);
            tickTimeline.play();
            return;
        }
        if (state.get() == PomodoroState.ENDED || state.get() == PomodoroState.ABORTED) {
            remainingSeconds.set(plannedSeconds.get());
        }
        state.set(PomodoroState.RUNNING);
        tickTimeline.play();
    }

    public void reset() {
        tickTimeline.stop();
        remainingSeconds.set(plannedSeconds.get());
        state.set(PomodoroState.IDLE);
    }

    /** 用户确认放弃后调用。 */
    public void abort() {
        tickTimeline.stop();
        state.set(PomodoroState.ABORTED);
        if (onSessionAborted != null) {
            onSessionAborted.run();
        }
    }

    public boolean canAbort() {
        return state.get() == PomodoroState.RUNNING || state.get() == PomodoroState.PAUSED;
    }

    private void tickOneSecond() {
        if (state.get() != PomodoroState.RUNNING) {
            return;
        }
        int next = remainingSeconds.get() - 1;
        if (next <= 0) {
            remainingSeconds.set(0);
            tickTimeline.stop();
            state.set(PomodoroState.ENDED);
            if (onSessionEnded != null) {
                onSessionEnded.run();
            }
        } else {
            remainingSeconds.set(next);
        }
    }

    private void recalcDerived() {
        timeDisplay.set(formatTime(remainingSeconds.get()));
    }

    private double computeSessionProgress() {
        var s = state.get();
        if (s == PomodoroState.IDLE) {
            return 0;
        }
        if (s == PomodoroState.ENDED) {
            return 1;
        }
        int planned = plannedSeconds.get();
        if (planned <= 0) {
            return 0;
        }
        return 1.0 - remainingSeconds.get() / (double) planned;
    }

    private static String formatTime(int totalSeconds) {
        int m = totalSeconds / 60;
        int s = totalSeconds % 60;
        return String.format("%02d:%02d", m, s);
    }
}

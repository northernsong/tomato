package com.tomato.view;

import com.tomato.model.PomodoroModel;
import com.tomato.model.PomodoroState;
import javafx.beans.property.DoubleProperty;
import javafx.beans.property.ObjectProperty;
import javafx.beans.property.SimpleDoubleProperty;
import javafx.beans.property.SimpleObjectProperty;
import javafx.scene.canvas.Canvas;
import javafx.scene.canvas.GraphicsContext;
import javafx.scene.layout.Region;

/** 四枚圆角胶囊：首段映射当前计时进度，其余为未激活态。 */
public final class SessionStripPane extends Region {

    private static final int SEGMENTS = PomodoroModel.SESSION_TOTAL;

    private final Canvas canvas = new Canvas();
    private final DoubleProperty progress = new SimpleDoubleProperty(0);
    private final ObjectProperty<PomodoroState> state = new SimpleObjectProperty<>(PomodoroState.IDLE);

    public SessionStripPane() {
        getChildren().add(canvas);
        setPrefSize(220, 22);
        setMinSize(80, 18);
        progress.addListener((o, a, b) -> requestLayout());
        state.addListener((o, a, b) -> requestLayout());
        widthProperty().addListener((o, a, b) -> draw());
        heightProperty().addListener((o, a, b) -> draw());
    }

    public DoubleProperty progressProperty() {
        return progress;
    }

    public ObjectProperty<PomodoroState> stateProperty() {
        return state;
    }

    @Override
    protected void layoutChildren() {
        super.layoutChildren();
        canvas.setWidth(getWidth());
        canvas.setHeight(getHeight());
        draw();
    }

    private void draw() {
        GraphicsContext g = canvas.getGraphicsContext2D();
        g.clearRect(0, 0, canvas.getWidth(), canvas.getHeight());

        double w = canvas.getWidth();
        double h = canvas.getHeight();
        if (w <= 0 || h <= 0) {
            return;
        }

        double gap = Math.min(10, w * 0.04);
        double pillW = (w - gap * (SEGMENTS - 1)) / SEGMENTS;
        double pillH = Math.min(9, h * 0.38);
        double pillY = (h - pillH) / 2;
        double arc = pillH / 2;

        PomodoroState st = state.get();
        double p = Math.max(0, Math.min(1, progress.get()));

        double x = 0;
        for (int i = 0; i < SEGMENTS; i++) {
            if (i == 0) {
                drawFirstSegment(g, x, pillY, pillW, pillH, arc, st, p);
            } else {
                g.setFill(AppTheme.PILL_INACTIVE);
                g.fillRoundRect(x, pillY, pillW, pillH, arc, arc);
            }
            x += pillW + gap;
        }
    }

    private static void drawFirstSegment(
            GraphicsContext g,
            double x,
            double pillY,
            double pillW,
            double pillH,
            double arc,
            PomodoroState st,
            double p) {
        g.setFill(AppTheme.PILL_INACTIVE);
        g.fillRoundRect(x, pillY, pillW, pillH, arc, arc);

        double filled;
        if (st == PomodoroState.ENDED) {
            filled = pillW;
        } else if (st == PomodoroState.IDLE || st == PomodoroState.ABORTED) {
            filled = 0;
        } else {
            filled = pillW * p;
            if (st == PomodoroState.RUNNING || st == PomodoroState.PAUSED) {
                filled = Math.max(pillH * 0.55, filled);
            }
        }

        if (filled <= 0) {
            return;
        }

        double drawW = Math.min(filled, pillW);
        g.setFill(AppTheme.ACCENT_TEAL);
        g.fillRoundRect(x, pillY, drawW, pillH, arc, arc);
    }
}

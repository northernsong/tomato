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
import javafx.scene.paint.Color;

/** 一条圆角「当前段」+ 若干空心圆，进度映射到首段宽度。 */
final class SessionStripPane extends Region {

    private final Canvas canvas = new Canvas();
    private final DoubleProperty progress = new SimpleDoubleProperty(0);
    private final ObjectProperty<PomodoroState> state = new SimpleObjectProperty<>(PomodoroState.IDLE);

    SessionStripPane() {
        getChildren().add(canvas);
        prefWidthProperty().set(200);
        prefHeightProperty().set(28);
        minHeightProperty().set(28);
        progress.addListener((o, a, b) -> requestLayout());
        state.addListener((o, a, b) -> requestLayout());
        widthProperty().addListener((o, a, b) -> draw());
        heightProperty().addListener((o, a, b) -> draw());
    }

    DoubleProperty progressProperty() {
        return progress;
    }

    ObjectProperty<PomodoroState> stateProperty() {
        return state;
    }

    @Override
    protected void layoutChildren() {
        super.layoutChildren();
        double w = getWidth();
        double h = getHeight();
        canvas.setWidth(w);
        canvas.setHeight(h);
        draw();
    }

    private void draw() {
        GraphicsContext g = canvas.getGraphicsContext2D();
        g.clearRect(0, 0, canvas.getWidth(), canvas.getHeight());
        g.setLineWidth(1.5);

        double w = canvas.getWidth();
        double h = canvas.getHeight();
        double barH = 8;
        double barY = (h - barH) / 2;
        double barMaxW = w * 0.42;
        double barX = 0;
        double p = Math.max(0, Math.min(1, progress.get()));
        double filledW = Math.round(barMaxW * p);
        PomodoroState st = state.get();
        if (st == PomodoroState.RUNNING || st == PomodoroState.PAUSED) {
            filledW = Math.max(6, filledW);
        }

        g.setFill(AppTheme.MINT);
        g.fillRoundRect(barX, barY, filledW, barH, barH, barH);

        g.setStroke(AppTheme.MINT);
        g.strokeRoundRect(barX, barY, barMaxW, barH, barH, barH);

        double dotR = 7;
        double gap = 10;
        double cx = barX + barMaxW + gap + dotR;

        for (int i = 1; i < PomodoroModel.SESSION_TOTAL; i++) {
            g.setFill(Color.TRANSPARENT);
            g.setStroke(AppTheme.MINT);
            g.strokeOval(cx - dotR, h / 2 - dotR, dotR * 2, dotR * 2);
            cx += dotR * 2 + gap;
        }
    }
}

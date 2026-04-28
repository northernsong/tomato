package com.tomato.view;

import javafx.scene.canvas.Canvas;
import javafx.scene.canvas.GraphicsContext;
import javafx.scene.paint.Color;
import javafx.scene.shape.ArcType;

/** 工具栏与主按钮的矢量图标绘制（Canvas）。 */
final class PomodoroGraphics {

    private PomodoroGraphics() {}

    static Canvas closeIcon(int size, Color fg) {
        int s = size + 10;
        Canvas c = new Canvas(s, s);
        GraphicsContext g = c.getGraphicsContext2D();
        g.setFill(AppTheme.CLOSE_CIRCLE_BG);
        g.fillOval(0, 0, s, s);
        g.setStroke(fg);
        g.setLineWidth(1.8);
        g.setLineCap(javafx.scene.shape.StrokeLineCap.ROUND);
        double inset = 4.5;
        g.strokeLine(inset, inset, s - inset, s - inset);
        g.strokeLine(s - inset, inset, inset, s - inset);
        return c;
    }

    static Canvas resetIcon(int size, Color fg) {
        Canvas c = new Canvas(size, size);
        GraphicsContext g = c.getGraphicsContext2D();
        double cx = size / 2.0;
        double cy = size / 2.0;
        double r = size * 0.32;
        g.setStroke(fg);
        g.setLineWidth(1.6);
        g.setLineCap(javafx.scene.shape.StrokeLineCap.ROUND);
        g.strokeArc(cx - r, cy - r, 2 * r, 2 * r, 45, 270, ArcType.OPEN);
        int ax = (int) (cx + r * 0.55);
        int ay = (int) (cy - r * 0.75);
        g.strokeLine(ax, ay, ax + 4, ay - 2);
        g.strokeLine(ax, ay, ax + 1, ay + 4);
        return c;
    }

    static Canvas statsIcon(int size, Color fg) {
        Canvas c = new Canvas(size, size);
        GraphicsContext g = c.getGraphicsContext2D();
        g.setStroke(fg);
        g.setLineWidth(1.8);
        g.setLineCap(javafx.scene.shape.StrokeLineCap.ROUND);
        int base = size - 2;
        g.strokeLine(2, base - 8, 2, base);
        g.strokeLine(size / 2, base - 12, size / 2, base);
        g.strokeLine(size - 3, base - 5, size - 3, base);
        return c;
    }

    static Canvas moreIcon(int size, Color fg) {
        Canvas c = new Canvas(size, size);
        GraphicsContext g = c.getGraphicsContext2D();
        g.setFill(fg);
        double cx = size / 2.0;
        double cy = size / 2.0;
        double r = 1.4;
        for (int i = -1; i <= 1; i++) {
            g.fillOval(cx - r, cy + i * 4.5 - r, 2 * r, 2 * r);
        }
        return c;
    }

    static Canvas roundPlayPause(int size, Color stroke, boolean pause) {
        Canvas c = new Canvas(size, size);
        GraphicsContext g = c.getGraphicsContext2D();
        g.setFill(AppTheme.CARD_WHITE);
        g.fillOval(0, 0, size, size);
        g.setStroke(stroke);
        g.setLineWidth(2.2);
        g.setLineCap(javafx.scene.shape.StrokeLineCap.ROUND);
        g.strokeOval(1.5, 1.5, size - 3, size - 3);

        double cx = size / 2.0;
        double cy = size / 2.0;
        g.setLineWidth(3);
        if (pause) {
            double h = 18;
            g.strokeLine(cx - 5, cy - h / 2, cx - 5, cy + h / 2);
            g.strokeLine(cx + 5, cy - h / 2, cx + 5, cy + h / 2);
        } else {
            double r = 10;
            double x1 = cx - r * 0.35;
            double x2 = cx + r * 0.85;
            g.setFill(stroke);
            g.fillPolygon(
                    new double[] {x1, x1, x2},
                    new double[] {cy - r, cy + r, cy},
                    3);
        }
        return c;
    }
}

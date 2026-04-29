package com.tomato.controller;

import com.tomato.model.PomodoroModel;
import com.tomato.model.PomodoroState;
import com.tomato.view.AppTheme;
import com.tomato.view.PomodoroGraphics;
import com.tomato.view.SessionStripPane;
import javafx.beans.binding.Bindings;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Node;
import javafx.scene.input.MouseEvent;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.effect.DropShadow;
import javafx.scene.layout.StackPane;
import javafx.scene.paint.Color;
import javafx.stage.Stage;

import java.io.IOException;
import java.io.UncheckedIOException;
import java.util.Objects;

/** 加载 {@code pomodoro.fxml}，注入控件并完成与 {@link PomodoroModel} 的绑定。 */
public final class PomodoroFxController {

    @FXML
    private StackPane rootPane;

    @FXML
    private StackPane windowCard;

    @FXML
    private Button closeButton;

    @FXML
    private Button resetButton;

    @FXML
    private Button statsButton;

    @FXML
    private Button moreButton;

    @FXML
    private Button mainActionButton;

    @FXML
    private Label titleLabel;

    @FXML
    private Label timeLabel;

    @FXML
    private SessionStripPane sessionStrip;

    private double dragStartX;
    private double dragStartY;

    public static PomodoroFxController load() {
        var url = Objects.requireNonNull(
                PomodoroFxController.class.getResource("/com/tomato/app/pomodoro.fxml"),
                "pomodoro.fxml");
        var loader = new FXMLLoader(url);
        try {
            loader.load();
        } catch (IOException e) {
            throw new UncheckedIOException(e);
        }
        return loader.getController();
    }

    public Parent getRoot() {
        return rootPane;
    }

    public void applyChrome(Stage stage) {
        var shadow = new DropShadow();
        shadow.setRadius(14);
        shadow.setOffsetY(4);
        shadow.setColor(Color.color(0, 0, 0, 0.14));
        windowCard.setEffect(shadow);

        windowCard.addEventFilter(
                MouseEvent.MOUSE_PRESSED,
                e -> {
                    if (isDescendantButton(e.getTarget())) {
                        return;
                    }
                    dragStartX = e.getScreenX() - stage.getX();
                    dragStartY = e.getScreenY() - stage.getY();
                });
        windowCard.addEventFilter(
                MouseEvent.MOUSE_DRAGGED,
                e -> {
                    if (isDescendantButton(e.getTarget())) {
                        return;
                    }
                    stage.setX(e.getScreenX() - dragStartX);
                    stage.setY(e.getScreenY() - dragStartY);
                });
    }

    private static boolean isDescendantButton(Object target) {
        if (!(target instanceof Node n)) {
            return false;
        }
        while (n != null) {
            if (n instanceof Button) {
                return true;
            }
            n = n.getParent();
        }
        return false;
    }

    public void bindModel(PomodoroModel model) {
        closeButton.setTooltip(new javafx.scene.control.Tooltip("关闭"));
        resetButton.setTooltip(new javafx.scene.control.Tooltip("重置"));
        statsButton.setTooltip(new javafx.scene.control.Tooltip("统计"));
        moreButton.setTooltip(new javafx.scene.control.Tooltip("更多"));

        closeButton.setGraphic(PomodoroGraphics.closeIcon(12, AppTheme.TEXT_MUTED));
        resetButton.setGraphic(PomodoroGraphics.resetIcon(16, AppTheme.TEXT_MUTED));
        statsButton.setGraphic(PomodoroGraphics.statsIcon(16, AppTheme.TEXT_MUTED));
        moreButton.setGraphic(PomodoroGraphics.moreIcon(16, AppTheme.TEXT_MUTED));

        timeLabel.textProperty().bind(model.timeDisplayProperty());
        sessionStrip.progressProperty().bind(model.sessionProgressProperty());
        sessionStrip.stateProperty().bind(model.stateProperty());

        mainActionButton.setPrefSize(72, 72);
        mainActionButton.setMinSize(72, 72);
        mainActionButton.setMaxSize(72, 72);
        mainActionButton.setFocusTraversable(false);
        mainActionButton.setTooltip(new javafx.scene.control.Tooltip("开始 / 暂停"));
        mainActionButton
                .graphicProperty()
                .bind(
                        Bindings.createObjectBinding(
                                () ->
                                        PomodoroGraphics.roundPlayPause(
                                                72,
                                                AppTheme.ACCENT_TEAL,
                                                model.getState() == PomodoroState.RUNNING),
                                model.stateProperty()));

        closeButton.setPickOnBounds(false);
        closeButton.setPrefSize(32, 32);
        closeButton.setMinSize(32, 32);
        closeButton.setMaxSize(32, 32);

        for (var b : new Button[] {resetButton, statsButton, moreButton}) {
            b.setPrefSize(36, 36);
            b.setMinSize(36, 36);
            b.setMaxSize(36, 36);
        }
    }

    public Button getCloseButton() {
        return closeButton;
    }

    public Button getResetButton() {
        return resetButton;
    }

    public Button getStatsButton() {
        return statsButton;
    }

    public Button getMoreButton() {
        return moreButton;
    }

    public Button getMainActionButton() {
        return mainActionButton;
    }
}

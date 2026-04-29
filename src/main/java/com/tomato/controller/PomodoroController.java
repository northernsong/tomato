package com.tomato.controller;

import com.tomato.model.PomodoroModel;
import javafx.application.Platform;
import javafx.scene.control.Alert;
import javafx.scene.control.ButtonType;
import javafx.scene.control.ContextMenu;
import javafx.scene.control.MenuItem;
import javafx.stage.Stage;
import javafx.stage.WindowEvent;

/**
 * 将用户操作转发给 {@link PomodoroModel}，并在需要确认或提示时弹出对话框。
 */
public final class PomodoroController {

    private final Stage stage;
    private final PomodoroModel model;
    private final PomodoroFxController ui;

    public PomodoroController(Stage stage, PomodoroModel model, PomodoroFxController ui) {
        this.stage = stage;
        this.model = model;
        this.ui = ui;
        wire();
    }

    private void wire() {
        model.setOnSessionEnded(
                () -> Platform.runLater(
                        () -> {
                            Alert a = new Alert(Alert.AlertType.INFORMATION);
                            a.setTitle("计时结束");
                            a.setHeaderText(null);
                            a.setContentText("本轮结束（第一步占位：后续接系统通知与结束卡片）。");
                            a.initOwner(stage);
                            a.showAndWait();
                        }));

        model.setOnSessionAborted(
                () -> Platform.runLater(
                        () -> {
                            Alert a = new Alert(Alert.AlertType.INFORMATION);
                            a.setTitle("已放弃");
                            a.setHeaderText(null);
                            a.setContentText("已放弃（第一步占位：后续不写入飞书记录）。");
                            a.initOwner(stage);
                            a.showAndWait();
                        }));

        ui.getCloseButton()
                .setOnAction(
                        e -> stage.fireEvent(new WindowEvent(stage, WindowEvent.WINDOW_CLOSE_REQUEST)));

        ui.getResetButton().setOnAction(e -> model.reset());

        ui.getStatsButton()
                .setOnAction(
                        e -> {
                            Alert a = new Alert(Alert.AlertType.INFORMATION);
                            a.setTitle("统计");
                            a.setHeaderText(null);
                            a.setContentText("统计功能占位。");
                            a.initOwner(stage);
                            a.showAndWait();
                        });

        MenuItem abortItem = new MenuItem("放弃本轮");
        abortItem.setOnAction(
                e -> {
                    if (!model.canAbort()) {
                        return;
                    }
                    Alert confirm = new Alert(Alert.AlertType.CONFIRMATION);
                    confirm.setTitle("确认放弃");
                    confirm.setHeaderText(null);
                    confirm.setContentText("确定要放弃当前番茄吗？");
                    confirm.initOwner(stage);
                    var result = confirm.showAndWait();
                    if (result.isPresent() && result.get() == ButtonType.OK) {
                        model.abort();
                    }
                });
        ContextMenu moreMenu = new ContextMenu(abortItem);
        ui.getMoreButton()
                .setOnAction(
                        e -> moreMenu.show(ui.getMoreButton(), javafx.geometry.Side.BOTTOM, 0, 0));

        ui.getMainActionButton().setOnAction(e -> model.toggleRunPause());
    }
}

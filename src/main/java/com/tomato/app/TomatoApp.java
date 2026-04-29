package com.tomato.app;

import com.tomato.controller.PomodoroController;
import com.tomato.controller.PomodoroFxController;
import com.tomato.model.PomodoroModel;
import javafx.application.Application;
import javafx.scene.Scene;
import javafx.scene.paint.Color;
import javafx.stage.Stage;
import javafx.stage.StageStyle;

public final class TomatoApp extends Application {

    @Override
    public void start(Stage stage) {
        stage.initStyle(StageStyle.TRANSPARENT);
        stage.setTitle("番茄钟");

        var ui = PomodoroFxController.load();
        var model = new PomodoroModel();
        ui.bindModel(model);
        new PomodoroController(stage, model, ui);
        ui.applyChrome(stage);

        var scene = new Scene(ui.getRoot(), 320, 380);
        scene.setFill(Color.TRANSPARENT);
        stage.setScene(scene);
        stage.setResizable(false);
        stage.centerOnScreen();
        stage.show();
    }

    public static void main(String[] args) {
        launch(args);
    }
}

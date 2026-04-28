package com.tomato.app;

import com.tomato.controller.PomodoroController;
import com.tomato.model.PomodoroModel;
import com.tomato.view.PomodoroView;
import javafx.application.Application;
import javafx.scene.Scene;
import javafx.stage.Stage;

public final class TomatoApp extends Application {

    @Override
    public void start(Stage stage) {
        stage.setTitle("番茄钟");

        var model = new PomodoroModel();
        var view = new PomodoroView(model);
        new PomodoroController(stage, model, view);

        var scene = new Scene(view.getRoot(), 340, 400);
        stage.setScene(scene);
        stage.setResizable(true);
        stage.setMinWidth(320);
        stage.setMinHeight(360);
        stage.centerOnScreen();
        stage.show();
    }

    public static void main(String[] args) {
        launch(args);
    }
}

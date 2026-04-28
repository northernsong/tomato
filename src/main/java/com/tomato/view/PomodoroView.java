package com.tomato.view;

import com.tomato.model.PomodoroModel;
import com.tomato.model.PomodoroState;
import javafx.beans.binding.Bindings;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.Parent;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.effect.DropShadow;
import javafx.scene.layout.Background;
import javafx.scene.layout.BackgroundFill;
import javafx.scene.layout.BorderPane;
import javafx.scene.layout.CornerRadii;
import javafx.scene.layout.HBox;
import javafx.scene.layout.StackPane;
import javafx.scene.layout.VBox;
import javafx.scene.paint.Color;
import javafx.scene.text.Font;

/**
 * 番茄钟主界面：只负责布局与外观，通过 {@link PomodoroModel} 的可观察属性做数据绑定，不包含业务决策。
 */
public final class PomodoroView {

    private final Button closeButton = ghostIconButton(PomodoroGraphics.closeIcon(12, AppTheme.TEXT_MUTED), 32);
    private final Button resetButton = ghostIconButton(PomodoroGraphics.resetIcon(16, AppTheme.TEXT_MUTED), 36);
    private final Button statsButton = ghostIconButton(PomodoroGraphics.statsIcon(16, AppTheme.TEXT_MUTED), 36);
    private final Button moreButton = ghostIconButton(PomodoroGraphics.moreIcon(16, AppTheme.TEXT_MUTED), 36);
    private final Button mainActionButton = new Button();
    private final Label titleLabel = new Label("Flow");
    private final Label timeLabel = new Label();
    private final SessionStripPane sessionStrip = new SessionStripPane();

    private final BorderPane root = new BorderPane();

    public PomodoroView(PomodoroModel model) {
        closeButton.setTooltip(new javafx.scene.control.Tooltip("关闭"));
        resetButton.setTooltip(new javafx.scene.control.Tooltip("重置"));
        statsButton.setTooltip(new javafx.scene.control.Tooltip("统计"));
        moreButton.setTooltip(new javafx.scene.control.Tooltip("更多"));

        titleLabel.setFont(Font.font(15));
        titleLabel.setTextFill(AppTheme.TEXT_MUTED);
        titleLabel.setMaxWidth(Double.MAX_VALUE);
        titleLabel.setAlignment(Pos.CENTER);

        timeLabel.setFont(Font.font(null, javafx.scene.text.FontWeight.BOLD, 52));
        timeLabel.setTextFill(AppTheme.TEXT_PRIMARY);
        timeLabel.setMaxWidth(Double.MAX_VALUE);
        timeLabel.setAlignment(Pos.CENTER);

        timeLabel.textProperty().bind(model.timeDisplayProperty());
        sessionStrip.progressProperty().bind(model.sessionProgressProperty());
        sessionStrip.stateProperty().bind(model.stateProperty());

        styleMainActionButton(model);

        HBox headerWest = new HBox(closeButton);
        headerWest.setAlignment(Pos.CENTER_LEFT);
        HBox headerEast = new HBox(4, resetButton, statsButton, moreButton);
        headerEast.setAlignment(Pos.CENTER_RIGHT);
        BorderPane header = new BorderPane();
        header.setLeft(headerWest);
        header.setRight(headerEast);

        VBox centerStack = new VBox(8, titleLabel, timeLabel, sessionStrip);
        centerStack.setAlignment(Pos.TOP_CENTER);
        VBox.setMargin(titleLabel, new Insets(8, 0, 4, 0));
        VBox.setMargin(timeLabel, new Insets(12, 0, 8, 0));
        VBox.setMargin(sessionStrip, new Insets(16, 0, 8, 0));

        HBox footer = new HBox(mainActionButton);
        footer.setAlignment(Pos.CENTER);
        footer.setPadding(new Insets(0, 0, 8, 0));

        VBox cardInner = new VBox(header, centerStack, footer);
        cardInner.setPadding(new Insets(10, 18, 22, 18));

        StackPane card = new StackPane(cardInner);
        card.setPadding(new Insets(20, 20, 24, 20));
        card.setBackground(
                new Background(new BackgroundFill(AppTheme.CARD_WHITE, new CornerRadii(22), Insets.EMPTY)));
        DropShadow shadow = new DropShadow();
        shadow.setRadius(12);
        shadow.setOffsetY(3);
        shadow.setColor(Color.rgb(0, 0, 0, 0.12));
        card.setEffect(shadow);

        root.setCenter(card);
        root.setBackground(
                new Background(new BackgroundFill(AppTheme.BG_OUTER, CornerRadii.EMPTY, Insets.EMPTY)));
    }

    public Parent getRoot() {
        return root;
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

    private void styleMainActionButton(PomodoroModel model) {
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
                                                AppTheme.MINT_STROKE,
                                                model.getState() == PomodoroState.RUNNING),
                                model.stateProperty()));
        mainActionButton.setStyle(
                "-fx-background-color: transparent; -fx-border-color: transparent; -fx-padding: 0;");
    }

    private static Button ghostIconButton(javafx.scene.Node graphic, int size) {
        Button b = new Button();
        b.setGraphic(graphic);
        b.setPrefSize(size, size);
        b.setMinSize(size, size);
        b.setMaxSize(size, size);
        b.setFocusTraversable(false);
        b.setStyle("-fx-background-color: transparent; -fx-border-color: transparent; -fx-padding: 0;");
        return b;
    }
}

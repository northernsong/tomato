package com.tomato.app;

import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JProgressBar;
import javax.swing.SwingUtilities;
import javax.swing.Timer;
import java.awt.BorderLayout;
import java.awt.Font;
import java.awt.GridLayout;

/**
 * 主窗：剩余时间、进度条、「开始」「放弃」。第一步使用短假时长验证 UI 与计时。
 */
public final class MainFrame extends JFrame {

    /** 假计时总秒数（验收时可改为更短便于演示）。 */
    private static final int FAKE_TOTAL_SECONDS = 60;

    private final JLabel timeLabel = new JLabel(formatTime(FAKE_TOTAL_SECONDS), JLabel.CENTER);
    private final JProgressBar progressBar = new JProgressBar(0, FAKE_TOTAL_SECONDS);
    private final JButton startButton = new JButton("开始");
    private final JButton abortButton = new JButton("放弃");

    private PomodoroState state = PomodoroState.IDLE;
    private int remainingSeconds = FAKE_TOTAL_SECONDS;
    private int plannedSeconds = FAKE_TOTAL_SECONDS;

    private final Timer tickTimer = new Timer(1000, e -> onTick());

    public MainFrame() {
        super("番茄钟");
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setSize(360, 220);
        setLocationByPlatform(true);

        timeLabel.setFont(timeLabel.getFont().deriveFont(Font.BOLD, 42f));
        progressBar.setStringPainted(true);
        progressBar.setString("进度");

        var center = new JPanel(new BorderLayout(8, 8));
        center.setBorder(BorderFactory.createEmptyBorder(16, 20, 8, 20));
        center.add(timeLabel, BorderLayout.NORTH);
        center.add(progressBar, BorderLayout.CENTER);

        var buttons = new JPanel(new GridLayout(1, 2, 12, 0));
        buttons.setBorder(BorderFactory.createEmptyBorder(0, 20, 16, 20));
        buttons.add(startButton);
        buttons.add(abortButton);

        setLayout(new BorderLayout());
        add(center, BorderLayout.CENTER);
        add(buttons, BorderLayout.SOUTH);

        abortButton.setEnabled(false);
        startButton.addActionListener(e -> onStart());
        abortButton.addActionListener(e -> onAbortClicked());

        refreshUi();
    }

    private void onStart() {
        if (state == PomodoroState.RUNNING) {
            return;
        }
        if (state == PomodoroState.ENDED || state == PomodoroState.ABORTED) {
            remainingSeconds = plannedSeconds;
        }
        state = PomodoroState.RUNNING;
        startButton.setEnabled(false);
        abortButton.setEnabled(true);
        tickTimer.start();
        refreshUi();
    }

    private void onAbortClicked() {
        if (state != PomodoroState.RUNNING) {
            return;
        }
        int choice = JOptionPane.showConfirmDialog(
                this,
                "确定要放弃当前番茄吗？",
                "确认放弃",
                JOptionPane.YES_NO_OPTION,
                JOptionPane.WARNING_MESSAGE
        );
        if (choice != JOptionPane.YES_OPTION) {
            return;
        }
        tickTimer.stop();
        state = PomodoroState.ABORTED;
        startButton.setEnabled(true);
        abortButton.setEnabled(false);
        refreshUi();
        SwingUtilities.invokeLater(() ->
                JOptionPane.showMessageDialog(
                        this,
                        "已放弃（第一步占位：后续不写入飞书记录）。",
                        "已放弃",
                        JOptionPane.INFORMATION_MESSAGE
                )
        );
    }

    private void onTick() {
        if (state != PomodoroState.RUNNING) {
            return;
        }
        remainingSeconds--;
        if (remainingSeconds <= 0) {
            remainingSeconds = 0;
            tickTimer.stop();
            state = PomodoroState.ENDED;
            startButton.setEnabled(true);
            abortButton.setEnabled(false);
        }
        refreshUi();
        if (state == PomodoroState.ENDED) {
            SwingUtilities.invokeLater(() ->
                    JOptionPane.showMessageDialog(
                            this,
                            "本轮结束（第一步占位：后续接系统通知与结束卡片）。",
                            "计时结束",
                            JOptionPane.INFORMATION_MESSAGE
                    )
            );
        }
    }

    private void refreshUi() {
        timeLabel.setText(formatTime(remainingSeconds));
        int max = Math.max(1, plannedSeconds);
        progressBar.setMaximum(max);
        progressBar.setValue(Math.min(max, plannedSeconds - remainingSeconds + (state == PomodoroState.RUNNING || state == PomodoroState.IDLE ? 0 : 0)));
        // 进度：已消耗 = planned - remaining（ENDED 时满格）
        int consumed = plannedSeconds - remainingSeconds;
        if (state == PomodoroState.ENDED) {
            progressBar.setValue(max);
        } else {
            progressBar.setValue(Math.min(max, Math.max(0, consumed)));
        }
        progressBar.setString(switch (state) {
            case IDLE -> "就绪";
            case RUNNING -> "进行中";
            case ENDED -> "已完成";
            case ABORTED -> "已放弃";
        });
        if (state == PomodoroState.IDLE) {
            progressBar.setValue(0);
        }
    }

    private static String formatTime(int totalSeconds) {
        int m = totalSeconds / 60;
        int s = totalSeconds % 60;
        return String.format("%02d:%02d", m, s);
    }
}

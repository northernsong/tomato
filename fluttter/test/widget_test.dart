import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fluttter/app/tomato_app.dart';
import 'package:fluttter/features/pomodoro/domain/pomodoro_controller.dart';
import 'package:fluttter/features/pomodoro/domain/pomodoro_state.dart';
import 'package:fluttter/features/settings/presentation/settings_page.dart';

void main() {
  testWidgets('主界面展示番茄卡片与开始按钮', (WidgetTester tester) async {
    await tester.pumpWidget(const TomatoApp());

    expect(find.byKey(const ValueKey('tomato-pomodoro-card')), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
  });

  testWidgets('PomodoroController 短时长可正常结束', (WidgetTester tester) async {
    final c = PomodoroController(totalSeconds: 2);
    addTearDown(c.dispose);

    c.start();
    await tester.pump();
    expect(c.remainingSeconds, 2);

    await tester.pump(const Duration(seconds: 1));
    expect(c.remainingSeconds, 1);
    expect(c.state, PomodoroState.running);

    await tester.pump(const Duration(seconds: 1));
    expect(c.state, PomodoroState.ended);
    expect(c.remainingSeconds, 0);
  });

  testWidgets('刷新从运行中回到闲置并满格', (WidgetTester tester) async {
    final c = PomodoroController(totalSeconds: 60);
    addTearDown(c.dispose);

    c.start();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(c.state, PomodoroState.running);
    expect(c.remainingSeconds, lessThan(60));

    c.refresh();
    expect(c.state, PomodoroState.idle);
    expect(c.remainingSeconds, 60);
  });

  testWidgets('设置页展示飞书与自定义键值区域', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      const MaterialApp(home: SettingsPage()),
    );
    await tester.pumpAndSettle();
    expect(find.text('飞书文档'), findsOneWidget);
    expect(find.text('请求密钥'), findsOneWidget);
    expect(find.text('文档 ID'), findsOneWidget);
    expect(find.text('Table ID'), findsOneWidget);
    expect(find.text('自定义键值'), findsOneWidget);
  });

  testWidgets('暂停与继续', (WidgetTester tester) async {
    final c = PomodoroController(totalSeconds: 10);
    try {
      c.start();
      await tester.pump();
      c.pause();
      expect(c.state, PomodoroState.paused);
      final left = c.remainingSeconds;

      await tester.pump(const Duration(seconds: 2));
      expect(c.remainingSeconds, left);

      c.resume();
      expect(c.state, PomodoroState.running);
      await tester.pump(const Duration(seconds: 1));
      expect(c.remainingSeconds, left - 1);
    } finally {
      c.dispose();
    }
  });
}

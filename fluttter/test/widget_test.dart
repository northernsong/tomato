import 'package:flutter_test/flutter_test.dart';

import 'package:fluttter/main.dart';
import 'package:fluttter/pomodoro/pomodoro_controller.dart';
import 'package:fluttter/pomodoro/pomodoro_state.dart';

void main() {
  testWidgets('主界面展示番茄钟标题与开始按钮', (WidgetTester tester) async {
    await tester.pumpWidget(const TomatoApp());

    expect(find.text('番茄钟'), findsWidgets);
    expect(find.text('开始'), findsOneWidget);
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
}

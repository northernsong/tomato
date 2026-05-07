import 'package:flutter/material.dart';

import '../features/pomodoro/presentation/pomodoro_home_page.dart';
import 'theme/tomato_theme.dart';

/// 应用根 [MaterialApp]。
///
/// 职责：应用标题、全局主题、首页（番茄主界面）。不包含具体业务状态机逻辑。
class TomatoApp extends StatelessWidget {
  const TomatoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '番茄钟',
      debugShowCheckedModeBanner: false,
      theme: buildTomatoLightTheme(),
      home: const PomodoroHomePage(),
    );
  }
}

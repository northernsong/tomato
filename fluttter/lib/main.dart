import 'package:flutter/material.dart';

import 'app/tomato_app.dart';

/// 程序入口。
///
/// 只做两件事：[WidgetsFlutterBinding.ensureInitialized] 保证插件与原生通道就绪；
/// [runApp] 挂载根组件。具体主题、路由首页在 [TomatoApp] 中配置。
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TomatoApp());
}

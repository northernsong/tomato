# Flutter 番茄钟项目 — 新手上手指南

面向刚接触 Flutter、需要接手本仓库的同学。读完应能：**知道仓库在做什么、代码放哪、常见名词含义、如何运行与改动**。

---

## 1. 这个仓库是什么

- **仓库名 `tomato`**：产品侧是「番茄钟桌面应用」——个人专注计时，规划上与飞书多维表格打通，把专注记录写回自己的表（详见 `docs/prd/prd-4-28.md`）。
- **Flutter 工程不在仓库根目录**：实际应用在子目录 **`fluttter/`**（包名也是 `fluttter`，多了一个 `t`，属于历史命名；日常命令都在该目录下执行）。
- **当前实现阶段**：MVP 骨架已具备——主界面倒计时、设置页（本地持久化飞书相关配置等）、结束/历史等对话框多为**占位文案**，与 PRD 中的完整闭环（写飞书、离线队列等）尚未全部对齐。

根目录 `README.md` 目前为空；Flutter 默认说明在 `fluttter/README.md`，可忽略其中「A new Flutter project」套话，以本文与 PRD 为准。

---

## 2. 技术栈一览

| 项 | 说明 |
|----|------|
| 语言 | Dart 3（`pubspec.yaml` 里 `sdk: ^3.11.5`） |
| UI 框架 | Flutter，Material 3（`useMaterial3: true`） |
| 状态 | 页面内 `StatefulWidget` + 领域层 `ChangeNotifier`（如 `PomodoroController`），未引入 Riverpod/BLoC 等第三方状态库 |
| 本地存储 | `shared_preferences`（设置里的 token、文档/表格 ID 等） |
| 目标平台 | 以 **macOS** 为主（仓库含 `macos/`）；另有 `web/`、`windows/` 脚手架，可按需启用 |

---

## 3. 仓库顶层结构（先认门）

```
tomato/
├── docs/                    # 产品/计划文档（PRD、BRD、开发计划）
├── fluttter/                # ★ Flutter 应用根目录（日常开发都在这里）
│   ├── lib/                 # Dart 源码
│   ├── macos/ web/ windows/ # 各平台原生壳与构建配置
│   ├── pubspec.yaml         # 依赖与资源声明
│   ├── analysis_options.yaml# 静态分析 / Lint 规则
│   └── test/                # 测试
├── .idea/                   # JetBrains IDE 工程文件（可不入脑）
└── README.md
```

**习惯**：终端先 `cd fluttter`，再执行 `flutter pub get`、`flutter run` 等。

---

## 4. `fluttter/lib` 源码怎么分层

当前**真正被引用**的是 **`lib/features/`** 与 **`lib/app/`**。  
另外 **`lib/pomodoro/`、`lib/settings/`** 下有一套名字相近的文件，**与 `features` 重复且未被 `main` / `TomatoApp` 引用**，可视为遗留或迁移未完成；改功能时请改 **`features`** 里的版本，避免改错文件。

### 4.1 `lib/main.dart`

- 程序入口：`main()` → `WidgetsFlutterBinding.ensureInitialized()` → `runApp(const TomatoApp())`。
- 不写业务，只负责启动。

### 4.2 `lib/app/`

| 文件 | 作用 |
|------|------|
| `tomato_app.dart` | 根组件：创建 `MaterialApp`（标题、主题、`home` 指向番茄主页） |
| `theme/tomato_theme.dart` | 浅色主题组装 |
| `theme/tomato_colors.dart` | 品牌/背景色常量 |

### 4.3 `lib/features/pomodoro/`（番茄计时）

| 路径 | 作用 |
|------|------|
| `domain/pomodoro_state.dart` | 状态枚举：idle / running / paused / ended |
| `domain/pomodoro_controller.dart` | 倒计时与状态机；`ChangeNotifier`，与 UI 解耦 |
| `presentation/pomodoro_home_page.dart` | 主界面 Scaffold、对话框、跳转设置 |
| `presentation/widgets/` | 如 `pomodoro_timer_card.dart` 等具体控件 |

**默认时长**：Debug 约 **30 秒**便于调试，Release 为 **25×60 秒**；也可用编译参数 `--dart-define=TOMATO_POMO_SECONDS=秒数` 覆盖（见 `PomodoroController.defaultTotalSeconds`）。

### 4.4 `lib/features/settings/`（设置）

| 路径 | 作用 |
|------|------|
| `domain/app_settings.dart` | 设置数据模型 |
| `data/settings_repository.dart` | 读写 `SharedPreferences` |
| `presentation/settings_page.dart` | 设置表单页 |
| `presentation/widgets/` | 表单项小组件 |

---

## 5. Flutter / Dart 常见名词（新手词典）

| 名词 | 一句话 |
|------|--------|
| **Widget** | 一切皆组件；界面由 Widget 树描述，分为无状态 `StatelessWidget` 与有状态 `StatefulWidget`。 |
| **BuildContext** | 组件在树中的位置上下文，用于找主题、`Navigator` 弹路由、`MediaQuery` 等。 |
| **State / setState** | `StatefulWidget` 的可变状态；`setState` 触发当前组件 `build` 重绘。 |
| **MaterialApp** | Material 风格应用的根，提供主题、路由、文字方向等。 |
| **Scaffold** | 页面架子：抽屉、AppBar、FAB、`body` 等。 |
| **ChangeNotifier** | 轻量「可监听模型」；`notifyListeners()` 后，用 `ListenableBuilder` / `AnimatedBuilder` / `addListener` 更新 UI。 |
| **pubspec.yaml** | 项目清单：包名、SDK 版本、依赖 `dependencies`、开发依赖 `dev_dependencies`、资源路径。 |
| **flutter pub get** | 根据 `pubspec.yaml` 拉取依赖并生成锁文件。 |
| **analysis_options.yaml** | 分析器与 Lint 配置（本仓库继承 `flutter_lints`）。 |
| **Platform 目录（macos/ 等）** | 各平台原生工程与 Flutter 引擎嵌入配置；打包、权限、图标等多在这里改。 |

更多系统学习见官方：[Flutter 文档](https://docs.flutter.dev/)。

---

## 6. 环境与本机运行

1. 安装 [Flutter SDK](https://docs.flutter.dev/get-started/install)（稳定版即可），并保证 `flutter doctor` 无阻塞项（至少装好对应平台的 toolchain）。
2. 进入应用目录并拉依赖：

```bash
cd /Users/song_y/IdeaProjects/tomato/fluttter
flutter pub get
```

3. 运行（示例：macOS 桌面）：

```bash
flutter run -d macos
```

4. IDE：Android Studio / IntelliJ / VS Code 均可；打开 **`fluttter` 文件夹**作为工程根，分析器才能正确解析 `package:flutter/...`。

---

## 7. 接手后「怎么改」——常见任务地图

| 你想… | 建议先看/改 |
|--------|-------------|
| 改应用名、默认首页、全局主题 | `lib/app/tomato_app.dart`、`lib/app/theme/` |
| 改计时规则、默认时长、结束逻辑 | `lib/features/pomodoro/domain/pomodoro_controller.dart` |
| 改主界面布局、按钮、菜单 | `lib/features/pomodoro/presentation/` 与 `widgets/` |
| 改设置项、持久化字段 | `lib/features/settings/domain/app_settings.dart`、`data/settings_repository.dart`、对应 `presentation` |
| 加依赖包 | `pubspec.yaml` 的 `dependencies:`，然后 `flutter pub get` |
| 对齐产品范围与验收 | `docs/prd/prd-4-28.md`、开发计划 `docs/plan/dev-plan-flutter-5-7.md` |

加新页面时：通常新建 `presentation/xxx_page.dart`，在现有 `Navigator.push` 或日后 `routes` 里挂上即可（当前设置页已是 `MaterialPageRoute` 范例）。

---

## 8. 测试与质量

- 示例测试：`fluttter/test/widget_test.dart`。
- 静态检查：`cd fluttter && flutter analyze`。

---

## 9. 接手检查清单（建议自己做一遍）

- [ ] `cd fluttter && flutter pub get` 成功  
- [ ] `flutter analyze` 无 error  
- [ ] `flutter run -d macos`（或你本机可用设备）能打开主界面  
- [ ] 从菜单进入设置页，保存后重启应用，配置仍在  
- [ ] 读过 PRD 里「MVP 成功标准」与当前代码占位差异，方便排期  

---

## 10. 备注

- **包名 `fluttter`**：若将来要发布或引用，可考虑重命名整个包（涉及 `pubspec.yaml` 的 `name:`、`import` 路径与 IDE 工程名），工作量中等，非必须立刻做。  
- **`lib/` 下重复目录**：优先以 **`features`** 为准；删除重复目录前建议全仓库搜索引用并跑一遍分析/测试。

若你后续希望把「名词」扩展成「Dart 语法速查」或「与飞书 API 对接的模块说明」，可以在有具体接口/表结构定稿后再补一节到本文或单独技术设计文档。

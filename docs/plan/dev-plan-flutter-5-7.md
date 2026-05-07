# 番茄钟桌面应用 — Flutter 开发计划

**依据**：`docs/prd/prd-4-28.md`（PRD v0.1）  
**UI**：Flutter（桌面目标：macOS / Windows；必要时 Linux）  
**说明**：Flutter 单套 UI 可覆盖多桌面平台；动画与主题成本低。系统托盘、钥匙串、休眠语义等需平台通道或成熟插件，各步注明技术选型。

---

## 实现前锁定（影响第 2～6 步）

与 Swing 版一致：

1. **放弃番茄**：是否写入「番茄记录」且 `结果 = aborted`（PRD 推荐写入）。  
2. **暂停**：MVP **不支持暂停**。  
3. **飞书鉴权**：PAT 自用 vs OAuth（在第四步前确定）。

下文假设：**放弃写入 `aborted`**、**无暂停**、第四步前确定 PAT 或 OAuth。

---

## 第一步：工程骨架 + Flutter 主窗 +「假计时」闭环

**目标**：可运行桌面壳；不连飞书；用短时长验证布局与计时。

**内容**

- `flutter create` 工程；Dart 3.x；启用 `macos`/`windows`（及按需 `linux`）。  
- 主界面：剩余时间大字号、`LinearProgressIndicator` 或自绘圆角进度、「开始」「放弃」（放弃二次 `showDialog` 确认）。  
- 计时：`Timer.periodic(const Duration(seconds: 1))`，在 `dispose` 中 `cancel`；状态更新经 `ChangeNotifier` + `ListenableBuilder`（或 `AnimatedBuilder`），避免在 build 里创建 Timer。  
- 状态机：`idle` → `running` → `ended` / `aborted`；正常结束与放弃均可用占位对话框。

**验收标准**

- 启动后主窗稳定，无未捕获异常。  
- 「开始」后倒计时正确走到 0；UI 持续刷新。  
- 「放弃」经确认后停止计时。  
- 帧调度正常，长时间运行无明显卡顿（Timer 频率低，主线程压力小）。

---

## 第二步：真实时长策略 + 系统通知 + 托盘

**目标**：对齐 PRD 4.1 计时、通知、托盘。

**内容**

- 默认 25 分钟；时长存本地：`shared_preferences` 或 `flutter_secure_storage`（仅密钥类，时长用前者即可）。  
- 系统通知：`flutter_local_notifications` 或各平台插件；macOS 需在 `Info.plist` 声明用途。  
- 可选短提示音 + 开关：`audioplayers` 或系统音效 API。  
- 托盘：`tray_manager` / `system_tray`：显示主窗、退出；菜单或 tooltip 展示剩余时间或状态。  
- 可选：`window_manager` 隐藏 Dock 图标（macOS 能力因版本与签名策略而异，非硬性）。

**验收标准**

- 完整流程结束能收到系统级通知（开发可用 1 分钟等调试时长）。  
- 关主窗后可通过托盘恢复；退出后进程结束。  
- 声音开关生效。

---

## 第三步：休眠/合盖语义

**目标**：PRD 6.5 — 休眠期间不静默消耗番茄时间。

**内容**

- 使用 `WidgetsBindingObserver` 的 `didChangeAppLifecycleState` 检测 `paused`/`detached`（覆盖部分场景）；合盖/深度休眠可辅以 **时间差**（`DateTime` 对比预期结束时刻）或 **平台通道** 读取电源状态（局限写入技术方案）。  
- 休眠中暂停倒计时；唤醒后提示「休眠已暂停计时」+「继续」/「放弃」。

**验收标准**

- 休眠/合盖后剩余时间不再减少；唤醒后需用户确认才继续。  
- 无「休眠期间番茄偷偷跑完」。

---

## 第四步：飞书集成（只读）— 鉴权、配置、任务列表

**目标**：PRD 4.3 F-01～F-03、5.2 只读。

**内容**

- 配置：Base ID、表 ID、字段映射；首启向导（`Navigator` + 多页 `PageView` 或 `Wizard` 式 `Stepper`）。  
- HTTP：`dio` + 拦截器实现限流、指数退避、可读错误文案。  
- 启动拉取 +「刷新任务」；客户端过滤非已完成 + 标题搜索。  
- Token：macOS 用 `flutter_secure_storage`（Keychain）；不明文写入用户可读配置文件。

**验收标准**

- 有效 Token 下列表与飞书抽样一致。  
- 断网/错误 Token 有提示、不崩溃。  
- 用户可读配置中无明文密钥。

---

## 第五步：结束卡片 + 写「番茄记录」+ 更新任务状态

**目标**：PRD 3.2、4.2、5.1、5.2。

**内容**

- 正常结束弹出模态结束卡片：`showDialog` + `Dialog`/`AlertDialog` 自定义内容；备注（≤2000 字）、任务单选（可空）、有关联时可改状态。  
- 保存：调用飞书多维表格 API；字段含起止时间、计划时长、`completed`/`aborted`、备注、关联、`client_uuid`。  
- 关联且状态变更时更新任务表。  
- 保存成功：`SnackBar` 或轻量 overlay。

**验收标准**

- 与 PRD §11 前三条一致：通知、番茄表新增正确、任务表状态可更新。  
- 未关联任务时状态控件不可用且不写任务表。

---

## 第六步：离线队列 + 幂等 + 重试

**目标**：PRD 6.3、5.4、§11 断网验收。

**内容**

- `sqflite` / `drift` 持久化待同步队列；项含 `client_uuid` 与 payload。  
- 断网入队；联网后 `connectivity_plus` 或定时轮询触发后台重试；**同一 UUID 不重复插入**（应用层去重）。  
- 极简「重试」或失败列表入口（设置页或抽屉）。

**验收标准**

- 断网保存 → 入队；联网后自动同步，飞书仅一行、内容正确。  
- 重复提交同一 UUID 不产生重复业务行（按既定去重策略验证）。

---

## 第七步：设置/关于 + 桌面分发 + 清单收尾

**目标**：PRD 4.4、6.2、§11 安装与密钥项。

**内容**

- 设置：飞书配置、默认时长、通知/声音；关于：版本、协议（`package_info_plus`）。  
- 分发：`flutter build macos` / `flutter build windows`；macOS 可用第三方打 DMG/notarize 流程（文档说明无 Dart/Flutter SDK 的安装步骤指 **Release 产物**）。  
- 日志脱敏；主要路径焦点顺序合理（完整键盘导航可 P1）。

**验收标准**

- 无开发环境依赖的机器可安装并启动 Release 构建。  
- PRD §11 MVP 验收清单全部满足。  
- 用户文档写明：放弃策略、休眠行为、Token 轮换（若 PAT）。

---

## 步骤依赖

```mermaid
flowchart LR
  S1[1 骨架与假计时] --> S2[2 通知与托盘]
  S2 --> S3[3 休眠语义]
  S3 --> S4[4 飞书只读]
  S4 --> S5[5 结束卡片与双写]
  S5 --> S6[6 离线队列]
  S6 --> S7[7 设置与分发]
```

---

## Flutter 观感简要建议

- `ThemeData` 统一 `colorScheme`；卡片用 `Card` + `RoundedRectangleBorder`。  
- 大字号倒计时 `Text` + `LinearProgressIndicator`（`BorderRadius` 外包 `ClipRRect`）。  
- 结束卡片固定 `ConstrainedBox` 最大宽高，模态 `barrierDismissible: false`。

---

## 与 Swing 版差异摘要

| 领域 | Swing | Flutter |
| ---- | ----- | ------- |
| UI 线程 | EDT | 单线程模型 + async |
| 计时 | `javax.swing.Timer` | `dart:async` `Timer` |
| 本地键值 | `Preferences` | `shared_preferences` |
| 托盘 | `TrayIcon` | `tray_manager` 等 |
| 打包 | `jpackage` | `flutter build` + 平台签名流程 |
| 安全存储 | 钥匙串 API | `flutter_secure_storage` |

---

## 文档修订

| 日期       | 说明                         |
| ---------- | ---------------------------- |
| 2026-04-28 | Swing 版初稿（见 sibling）   |
| 2026-05-07 | Flutter 版初稿、对齐 PRD 步 |

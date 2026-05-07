import 'package:flutter/material.dart';

/// 一行自定义键值在表单中的控制器封装。
///
/// [SettingsPage] 维护 [List] 本类实例；保存时从各 [TextEditingController] 汇总为 [Map]。
class CustomKeyValueEntry {
  CustomKeyValueEntry._(this.keyController, this.valueController);

  factory CustomKeyValueEntry.empty() {
    return CustomKeyValueEntry._(TextEditingController(), TextEditingController());
  }

  factory CustomKeyValueEntry.fromMapEntry(MapEntry<String, String> e) {
    return CustomKeyValueEntry._(
      TextEditingController(text: e.key),
      TextEditingController(text: e.value),
    );
  }

  final TextEditingController keyController;
  final TextEditingController valueController;
  VoidCallback? _dirtyListener;

  /// 键或值变化时通知页面标记未保存。
  void attachDirtyListener(VoidCallback onDirty) {
    _dirtyListener = onDirty;
    keyController.addListener(onDirty);
    valueController.addListener(onDirty);
  }

  void dispose() {
    if (_dirtyListener != null) {
      keyController.removeListener(_dirtyListener!);
      valueController.removeListener(_dirtyListener!);
    }
    keyController.dispose();
    valueController.dispose();
  }
}

/// 展示一行键值编辑区与删除按钮。
class KeyValueEntryRowCard extends StatelessWidget {
  const KeyValueEntryRowCard({
    super.key,
    required this.entry,
    required this.onRemove,
  });

  final CustomKeyValueEntry entry;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.65),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: entry.keyController,
                decoration: const InputDecoration(
                  labelText: '键',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 3,
              child: TextField(
                controller: entry.valueController,
                decoration: const InputDecoration(
                  labelText: '值',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            IconButton(
              tooltip: '删除',
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}

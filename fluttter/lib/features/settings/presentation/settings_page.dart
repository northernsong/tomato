import 'package:flutter/material.dart';

import '../data/settings_repository.dart';
import '../domain/app_settings.dart';
import 'widgets/custom_key_value_entry.dart';
import 'widgets/labeled_text_field.dart';

/// 应用设置界面：飞书固定字段 + 可扩展自定义键值对。
///
/// 通过 [SettingsRepository] 与本地持久化交互；保存成功后用 [SnackBar] 轻提示。
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _repo = SettingsRepository.instance;

  late final TextEditingController _secretCtrl;
  late final TextEditingController _docIdCtrl;
  late final TextEditingController _tableIdCtrl;

  final List<CustomKeyValueEntry> _customEntries = [];
  bool _loading = true;
  bool _obscureSecret = true;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _secretCtrl = TextEditingController();
    _docIdCtrl = TextEditingController();
    _tableIdCtrl = TextEditingController();
    for (final c in [_secretCtrl, _docIdCtrl, _tableIdCtrl]) {
      c.addListener(_markDirty);
    }
    _loadFromDisk();
  }

  void _markDirty() {
    if (!_dirty) setState(() => _dirty = true);
  }

  Future<void> _loadFromDisk() async {
    final s = await _repo.load();
    if (!mounted) return;
    _secretCtrl.removeListener(_markDirty);
    _docIdCtrl.removeListener(_markDirty);
    _tableIdCtrl.removeListener(_markDirty);
    _secretCtrl.text = s.feishuRequestSecret;
    _docIdCtrl.text = s.feishuDocumentId;
    _tableIdCtrl.text = s.feishuTableId;
    for (final c in [_secretCtrl, _docIdCtrl, _tableIdCtrl]) {
      c.addListener(_markDirty);
    }
    for (final r in _customEntries) {
      r.dispose();
    }
    _customEntries.clear();
    final entries = s.customEntries.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    for (final e in entries) {
      final row = CustomKeyValueEntry.fromMapEntry(e);
      row.attachDirtyListener(_markDirty);
      _customEntries.add(row);
    }
    setState(() {
      _loading = false;
      _dirty = false;
    });
  }

  Future<void> _save() async {
    final built = _buildCustomMapFromRows();
    if (built == null) {
      return;
    }
    final next = AppSettings(
      feishuRequestSecret: _secretCtrl.text.trim(),
      feishuDocumentId: _docIdCtrl.text.trim(),
      feishuTableId: _tableIdCtrl.text.trim(),
      customEntries: built,
    );
    await _repo.save(next);
    if (!mounted) return;
    setState(() => _dirty = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已保存')),
    );
  }

  /// 返回 null 表示校验失败（重复键等）。
  Map<String, String>? _buildCustomMapFromRows() {
    final map = <String, String>{};
    for (final r in _customEntries) {
      final k = r.keyController.text.trim();
      final v = r.valueController.text;
      if (k.isEmpty) continue;
      if (map.containsKey(k)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('自定义键重复：$k')),
        );
        return null;
      }
      map[k] = v;
    }
    return map;
  }

  void _addCustomRow() {
    setState(() {
      final row = CustomKeyValueEntry.empty();
      row.attachDirtyListener(_markDirty);
      _customEntries.add(row);
      _dirty = true;
    });
  }

  void _removeCustomRowAt(int index) {
    setState(() {
      _customEntries[index].dispose();
      _customEntries.removeAt(index);
      _dirty = true;
    });
  }

  @override
  void dispose() {
    for (final c in [_secretCtrl, _docIdCtrl, _tableIdCtrl]) {
      c.dispose();
    }
    for (final r in _customEntries) {
      r.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        actions: [
          TextButton(
            onPressed: _loading || !_dirty ? null : _save,
            child: const Text('保存'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                Text(
                  '飞书文档',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '以下为对接飞书文档 / 多维表时的固定配置；密钥请妥善保管。',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 16),
                LabeledTextField(
                  label: '请求密钥',
                  controller: _secretCtrl,
                  obscureText: _obscureSecret,
                  suffix: IconButton(
                    tooltip: _obscureSecret ? '显示' : '隐藏',
                    onPressed: () => setState(() => _obscureSecret = !_obscureSecret),
                    icon: Icon(_obscureSecret ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                LabeledTextField(
                  label: '文档 ID',
                  controller: _docIdCtrl,
                  hint: '如 docx token 或 wiki 节点 token',
                ),
                const SizedBox(height: 12),
                LabeledTextField(
                  label: 'Table ID',
                  controller: _tableIdCtrl,
                  hint: '多维表 table=tbl…',
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Text(
                      '自定义键值',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const Spacer(),
                    FilledButton.tonalIcon(
                      onPressed: _addCustomRow,
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('添加'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '按需添加任意键名与取值，后续扩展功能时可直接读取，无需再改本页布局。',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 12),
                if (_customEntries.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        '暂无条目，点击「添加」增加键值对。',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                  )
                else
                  ...List.generate(_customEntries.length, (i) {
                    final r = _customEntries[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: KeyValueEntryRowCard(
                        entry: r,
                        onRemove: () => _removeCustomRowAt(i),
                      ),
                    );
                  }),
              ],
            ),
    );
  }
}

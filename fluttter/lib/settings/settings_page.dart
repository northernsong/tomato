import 'package:flutter/material.dart';

import 'app_settings.dart';
import 'settings_repository.dart';

/// 应用设置：飞书固定项 + 自定义键值对，持久化于本机。
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

  final List<_KvRow> _kvRows = [];
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
    _load();
  }

  void _markDirty() {
    if (!_dirty) setState(() => _dirty = true);
  }

  Future<void> _load() async {
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
    for (final r in _kvRows) {
      r.dispose();
    }
    _kvRows.clear();
    final entries = s.customEntries.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    for (final e in entries) {
      _kvRows.add(_KvRow.fromEntry(e)..addListener(_markDirty));
    }
    setState(() {
      _loading = false;
      _dirty = false;
    });
  }

  Future<void> _save() async {
    final built = _buildCustomMap();
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
  Map<String, String>? _buildCustomMap() {
    final map = <String, String>{};
    for (final r in _kvRows) {
      final k = r.keyCtrl.text.trim();
      final v = r.valueCtrl.text;
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

  void _addKvRow() {
    setState(() {
      _kvRows.add(_KvRow.empty()..addListener(_markDirty));
      _dirty = true;
    });
  }

  void _removeKvRow(int index) {
    setState(() {
      _kvRows[index].dispose();
      _kvRows.removeAt(index);
      _dirty = true;
    });
  }

  @override
  void dispose() {
    for (final c in [_secretCtrl, _docIdCtrl, _tableIdCtrl]) {
      c.dispose();
    }
    for (final r in _kvRows) {
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
                _LabeledField(
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
                _LabeledField(
                  label: '文档 ID',
                  controller: _docIdCtrl,
                  hint: '如 docx token 或 wiki 节点 token',
                ),
                const SizedBox(height: 12),
                _LabeledField(
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
                      onPressed: _addKvRow,
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
                if (_kvRows.isEmpty)
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
                  ...List.generate(_kvRows.length, (i) {
                    final r = _kvRows[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _KvRowCard(
                        row: r,
                        onRemove: () => _removeKvRow(i),
                      ),
                    );
                  }),
              ],
            ),
    );
  }
}

class _KvRow {
  _KvRow._(this.keyCtrl, this.valueCtrl);

  factory _KvRow.empty() {
    return _KvRow._(TextEditingController(), TextEditingController());
  }

  factory _KvRow.fromEntry(MapEntry<String, String> e) {
    return _KvRow._(
      TextEditingController(text: e.key),
      TextEditingController(text: e.value),
    );
  }

  final TextEditingController keyCtrl;
  final TextEditingController valueCtrl;
  VoidCallback? _listener;

  void addListener(VoidCallback l) {
    _listener = l;
    keyCtrl.addListener(l);
    valueCtrl.addListener(l);
  }

  void dispose() {
    if (_listener != null) {
      keyCtrl.removeListener(_listener!);
      valueCtrl.removeListener(_listener!);
    }
    keyCtrl.dispose();
    valueCtrl.dispose();
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    this.hint,
    this.obscureText = false,
    this.suffix,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool obscureText;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          maxLines: obscureText ? 1 : null,
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            border: const OutlineInputBorder(),
            suffixIcon: suffix,
            suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ),
      ],
    );
  }
}

class _KvRowCard extends StatelessWidget {
  const _KvRowCard({
    required this.row,
    required this.onRemove,
  });

  final _KvRow row;
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
                controller: row.keyCtrl,
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
                controller: row.valueCtrl,
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

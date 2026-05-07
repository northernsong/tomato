import 'dart:convert';

/// 应用持久化配置模型：飞书对接固定项 + 用户自定义键值对。
///
/// 序列化格式由 [encode] / [AppSettings.decode] 定义，存储键见 [SettingsRepository]。
class AppSettings {
  const AppSettings({
    this.feishuRequestSecret = '',
    this.feishuDocumentId = '',
    this.feishuTableId = '',
    Map<String, String>? customEntries,
  }) : customEntries = customEntries ?? const {};

  /// 调用飞书 / 文档接口时使用的密钥（具体语义由对接方式决定）。
  final String feishuRequestSecret;

  /// 飞书文档或 Wiki 节点对应的文档标识（如 docx / wiki token）。
  final String feishuDocumentId;

  /// 多维表（Bitable）数据表 ID（`table=tblXXX`）。
  final String feishuTableId;

  /// 其它业务用到的任意字符串配置；键名由用户自行约定。
  final Map<String, String> customEntries;

  AppSettings copyWith({
    String? feishuRequestSecret,
    String? feishuDocumentId,
    String? feishuTableId,
    Map<String, String>? customEntries,
  }) {
    return AppSettings(
      feishuRequestSecret: feishuRequestSecret ?? this.feishuRequestSecret,
      feishuDocumentId: feishuDocumentId ?? this.feishuDocumentId,
      feishuTableId: feishuTableId ?? this.feishuTableId,
      customEntries: customEntries ?? this.customEntries,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'feishuRequestSecret': feishuRequestSecret,
      'feishuDocumentId': feishuDocumentId,
      'feishuTableId': feishuTableId,
      'customEntries': customEntries,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final raw = json['customEntries'];
    final Map<String, String> custom = {};
    if (raw is Map) {
      raw.forEach((k, v) {
        if (k is String && v != null) {
          custom[k] = v.toString();
        }
      });
    }
    return AppSettings(
      feishuRequestSecret: json['feishuRequestSecret'] as String? ?? '',
      feishuDocumentId: json['feishuDocumentId'] as String? ?? '',
      feishuTableId: json['feishuTableId'] as String? ?? '',
      customEntries: custom,
    );
  }

  String encode() => jsonEncode(toJson());

  factory AppSettings.decode(String? raw) {
    if (raw == null || raw.isEmpty) {
      return const AppSettings();
    }
    try {
      final map = jsonDecode(raw);
      if (map is Map<String, dynamic>) {
        return AppSettings.fromJson(map);
      }
      if (map is Map) {
        return AppSettings.fromJson(Map<String, dynamic>.from(map));
      }
    } catch (_) {
      /* 损坏或未知格式时回退默认空配置 */
    }
    return const AppSettings();
  }
}

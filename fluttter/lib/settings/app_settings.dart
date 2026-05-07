import 'dart:convert';

/// 应用持久化配置：飞书相关固定项 + 用户自定义键值对。
class AppSettings {
  const AppSettings({
    this.feishuRequestSecret = '',
    this.feishuDocumentId = '',
    this.feishuTableId = '',
    Map<String, String>? customEntries,
  }) : customEntries = customEntries ?? const {};

  /// 调用飞书 / 文档接口时使用的密钥（如 user_access_token、tenant token 等，由你方对接方式决定）。
  final String feishuRequestSecret;

  /// 飞书文档或 Wiki 节点对应的文档标识（如 docx / wiki token）。
  final String feishuDocumentId;

  /// 多维表（Bitable）数据表 ID（table=tblXXX）。
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
      /* ignore */
    }
    return const AppSettings();
  }
}

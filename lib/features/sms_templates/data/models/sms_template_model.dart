class SmsTemplateModel {
  final String type;
  final String body;
  final String defaultBody;
  final List<String> placeholders;
  final bool customized;
  final DateTime? updatedAt;

  const SmsTemplateModel({
    required this.type,
    required this.body,
    required this.defaultBody,
    required this.placeholders,
    required this.customized,
    this.updatedAt,
  });

  factory SmsTemplateModel.fromJson(Map<String, dynamic> json) =>
      SmsTemplateModel(
        type: json['type'] as String,
        body: json['body'] as String,
        defaultBody: json['defaultBody'] as String,
        placeholders: (json['placeholders'] as List<dynamic>? ?? [])
            .map((e) => e as String)
            .toList(),
        customized: json['customized'] as bool? ?? false,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        'body': body,
        'defaultBody': defaultBody,
        'placeholders': placeholders,
        'customized': customized,
        'updatedAt': updatedAt?.toIso8601String(),
      };
}

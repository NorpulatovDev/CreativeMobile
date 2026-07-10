/// A single entry in the device-local SMS log. Written by [SmsQueueProcessor]
/// after every send attempt. Stored on-device only (Hive) — never sent to the
/// backend — so the admin has a private record of what this SIM actually sent.
class SmsLogModel {
  final int? messageId; // backend sms_messages id, if known
  final String studentName;
  final String recipientPhone;
  final String body;
  final bool sent; // true = delivered to the SMS layer, false = failed
  final String? error; // failure reason when !sent
  final DateTime timestamp;

  const SmsLogModel({
    this.messageId,
    required this.studentName,
    required this.recipientPhone,
    required this.body,
    required this.sent,
    this.error,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'messageId': messageId,
        'studentName': studentName,
        'recipientPhone': recipientPhone,
        'body': body,
        'sent': sent,
        'error': error,
        'timestamp': timestamp.toIso8601String(),
      };

  factory SmsLogModel.fromJson(Map<String, dynamic> json) => SmsLogModel(
        messageId: (json['messageId'] as num?)?.toInt(),
        studentName: json['studentName'] as String? ?? '',
        recipientPhone: json['recipientPhone'] as String? ?? '',
        body: json['body'] as String? ?? '',
        sent: json['sent'] as bool? ?? false,
        error: json['error'] as String?,
        timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
      );
}

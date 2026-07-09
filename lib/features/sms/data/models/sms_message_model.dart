import 'package:json_annotation/json_annotation.dart';

part 'sms_message_model.g.dart';

enum SmsStatus { QUEUED, SENDING, SENT, FAILED }

@JsonSerializable()
class SmsMessageModel {
  final int id;
  final int studentId;
  final String studentName;
  final String recipientPhone;
  final String body;
  final SmsStatus status;
  final int attempts;
  final String? error;

  const SmsMessageModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.recipientPhone,
    required this.body,
    required this.status,
    required this.attempts,
    this.error,
  });

  factory SmsMessageModel.fromJson(Map<String, dynamic> json) =>
      _$SmsMessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$SmsMessageModelToJson(this);
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sms_message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SmsMessageModel _$SmsMessageModelFromJson(Map<String, dynamic> json) =>
    SmsMessageModel(
      id: (json['id'] as num).toInt(),
      studentId: (json['studentId'] as num).toInt(),
      studentName: json['studentName'] as String,
      recipientPhone: json['recipientPhone'] as String,
      body: json['body'] as String,
      status: $enumDecode(_$SmsStatusEnumMap, json['status']),
      attempts: (json['attempts'] as num).toInt(),
      error: json['error'] as String?,
    );

Map<String, dynamic> _$SmsMessageModelToJson(SmsMessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'studentId': instance.studentId,
      'studentName': instance.studentName,
      'recipientPhone': instance.recipientPhone,
      'body': instance.body,
      'status': _$SmsStatusEnumMap[instance.status]!,
      'attempts': instance.attempts,
      'error': instance.error,
    };

const _$SmsStatusEnumMap = {
  SmsStatus.QUEUED: 'QUEUED',
  SmsStatus.SENDING: 'SENDING',
  SmsStatus.SENT: 'SENT',
  SmsStatus.FAILED: 'FAILED',
};

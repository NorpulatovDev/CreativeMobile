// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentModel _$PaymentModelFromJson(Map<String, dynamic> json) => PaymentModel(
  id: (json['id'] as num).toInt(),
  studentId: (json['studentId'] as num).toInt(),
  studentName: json['studentName'] as String,
  groupId: (json['groupId'] as num).toInt(),
  groupName: json['groupName'] as String,
  amount: (json['amount'] as num).toDouble(),
  paidForMonth: json['paidForMonth'] as String,
  paidAt: DateTime.parse(json['paidAt'] as String),
);

Map<String, dynamic> _$PaymentModelToJson(PaymentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'studentId': instance.studentId,
      'studentName': instance.studentName,
      'groupId': instance.groupId,
      'groupName': instance.groupName,
      'amount': instance.amount,
      'paidForMonth': instance.paidForMonth,
      'paidAt': instance.paidAt.toIso8601String(),
    };

PaymentRequest _$PaymentRequestFromJson(Map<String, dynamic> json) =>
    PaymentRequest(
      studentId: (json['studentId'] as num).toInt(),
      groupId: (json['groupId'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      paidForMonth: json['paidForMonth'] as String,
    );

Map<String, dynamic> _$PaymentRequestToJson(PaymentRequest instance) =>
    <String, dynamic>{
      'studentId': instance.studentId,
      'groupId': instance.groupId,
      'amount': instance.amount,
      'paidForMonth': instance.paidForMonth,
    };

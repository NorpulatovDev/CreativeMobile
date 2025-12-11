// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaymentRequestImpl _$$PaymentRequestImplFromJson(Map<String, dynamic> json) =>
    _$PaymentRequestImpl(
      studentId: (json['studentId'] as num).toInt(),
      groupId: (json['groupId'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      paidForMonth: json['paidForMonth'] as String,
    );

Map<String, dynamic> _$$PaymentRequestImplToJson(
  _$PaymentRequestImpl instance,
) => <String, dynamic>{
  'studentId': instance.studentId,
  'groupId': instance.groupId,
  'amount': instance.amount,
  'paidForMonth': instance.paidForMonth,
};

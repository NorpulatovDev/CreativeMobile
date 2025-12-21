// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sms_link_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SmsLinkResponse _$SmsLinkResponseFromJson(Map<String, dynamic> json) =>
    SmsLinkResponse(
      id: (json['id'] as num).toInt(),
      fullName: json['fullName'] as String,
      smsLinkCode: json['smsLinkCode'] as String?,
      smsLinked: json['smsLinked'] as bool,
      parentPhoneNumber: json['parentPhoneNumber'] as String,
    );

Map<String, dynamic> _$SmsLinkResponseToJson(SmsLinkResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'smsLinkCode': instance.smsLinkCode,
      'smsLinked': instance.smsLinked,
      'parentPhoneNumber': instance.parentPhoneNumber,
    };

SmsLinkByPhoneRequest _$SmsLinkByPhoneRequestFromJson(
  Map<String, dynamic> json,
) => SmsLinkByPhoneRequest(phoneNumber: json['phoneNumber'] as String);

Map<String, dynamic> _$SmsLinkByPhoneRequestToJson(
  SmsLinkByPhoneRequest instance,
) => <String, dynamic>{'phoneNumber': instance.phoneNumber};

SmsLinkByCodeRequest _$SmsLinkByCodeRequestFromJson(
  Map<String, dynamic> json,
) => SmsLinkByCodeRequest(
  code: json['code'] as String,
  phoneNumber: json['phoneNumber'] as String,
);

Map<String, dynamic> _$SmsLinkByCodeRequestToJson(
  SmsLinkByCodeRequest instance,
) => <String, dynamic>{
  'code': instance.code,
  'phoneNumber': instance.phoneNumber,
};

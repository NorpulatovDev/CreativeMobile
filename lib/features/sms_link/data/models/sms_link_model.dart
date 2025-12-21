import 'package:json_annotation/json_annotation.dart';

part 'sms_link_model.g.dart';

@JsonSerializable()
class SmsLinkResponse {
  final int id;
  final String fullName;
  final String? smsLinkCode;
  final bool smsLinked;
  final String parentPhoneNumber;

  const SmsLinkResponse({
    required this.id,
    required this.fullName,
    this.smsLinkCode,
    required this.smsLinked,
    required this.parentPhoneNumber,
  });

  factory SmsLinkResponse.fromJson(Map<String, dynamic> json) =>
      _$SmsLinkResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SmsLinkResponseToJson(this);
}

@JsonSerializable()
class SmsLinkByPhoneRequest {
  final String phoneNumber;

  const SmsLinkByPhoneRequest({required this.phoneNumber});

  factory SmsLinkByPhoneRequest.fromJson(Map<String, dynamic> json) =>
      _$SmsLinkByPhoneRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SmsLinkByPhoneRequestToJson(this);
}

@JsonSerializable()
class SmsLinkByCodeRequest {
  final String code;
  final String phoneNumber;

  const SmsLinkByCodeRequest({
    required this.code,
    required this.phoneNumber,
  });

  factory SmsLinkByCodeRequest.fromJson(Map<String, dynamic> json) =>
      _$SmsLinkByCodeRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SmsLinkByCodeRequestToJson(this);
}
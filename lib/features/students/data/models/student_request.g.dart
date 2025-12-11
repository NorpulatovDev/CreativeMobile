// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StudentRequestImpl _$$StudentRequestImplFromJson(Map<String, dynamic> json) =>
    _$StudentRequestImpl(
      fullName: json['fullName'] as String,
      parentName: json['parentName'] as String,
      parentPhoneNumber: json['parentPhoneNumber'] as String,
      activeGroupId: (json['activeGroupId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$StudentRequestImplToJson(
  _$StudentRequestImpl instance,
) => <String, dynamic>{
  'fullName': instance.fullName,
  'parentName': instance.parentName,
  'parentPhoneNumber': instance.parentPhoneNumber,
  'activeGroupId': instance.activeGroupId,
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StudentImpl _$$StudentImplFromJson(Map<String, dynamic> json) =>
    _$StudentImpl(
      id: (json['id'] as num).toInt(),
      fullName: json['fullName'] as String,
      parentName: json['parentName'] as String,
      parentPhoneNumber: json['parentPhoneNumber'] as String,
      smsLinked: json['smsLinked'] as bool,
      smsLinkCode: json['smsLinkCode'] as String,
      totalPaid: (json['totalPaid'] as num).toDouble(),
      activeGroupId: (json['activeGroupId'] as num?)?.toInt(),
      activeGroupName: json['activeGroupName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$StudentImplToJson(_$StudentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'parentName': instance.parentName,
      'parentPhoneNumber': instance.parentPhoneNumber,
      'smsLinked': instance.smsLinked,
      'smsLinkCode': instance.smsLinkCode,
      'totalPaid': instance.totalPaid,
      'activeGroupId': instance.activeGroupId,
      'activeGroupName': instance.activeGroupName,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

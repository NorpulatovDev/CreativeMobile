// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GroupRequestImpl _$$GroupRequestImplFromJson(Map<String, dynamic> json) =>
    _$GroupRequestImpl(
      name: json['name'] as String,
      teacherId: (json['teacherId'] as num).toInt(),
      monthlyFee: (json['monthlyFee'] as num).toDouble(),
    );

Map<String, dynamic> _$$GroupRequestImplToJson(_$GroupRequestImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'teacherId': instance.teacherId,
      'monthlyFee': instance.monthlyFee,
    };

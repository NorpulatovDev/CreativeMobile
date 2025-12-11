// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GroupImpl _$$GroupImplFromJson(Map<String, dynamic> json) => _$GroupImpl(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  teacherId: (json['teacherId'] as num).toInt(),
  teacherName: json['teacherName'] as String,
  monthlyFee: (json['monthlyFee'] as num).toDouble(),
  studentsCount: (json['studentsCount'] as num).toInt(),
  totalAmountToPay: (json['totalAmountToPay'] as num).toDouble(),
  totalPaid: (json['totalPaid'] as num).toDouble(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$GroupImplToJson(_$GroupImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'teacherId': instance.teacherId,
      'teacherName': instance.teacherName,
      'monthlyFee': instance.monthlyFee,
      'studentsCount': instance.studentsCount,
      'totalAmountToPay': instance.totalAmountToPay,
      'totalPaid': instance.totalPaid,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

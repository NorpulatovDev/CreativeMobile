// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TeacherModel _$TeacherModelFromJson(Map<String, dynamic> json) => TeacherModel(
  id: (json['id'] as num).toInt(),
  fullName: json['fullName'] as String,
  phoneNumber: json['phoneNumber'] as String,
  totalIncome: (json['totalIncome'] as num).toDouble(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$TeacherModelToJson(TeacherModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'phoneNumber': instance.phoneNumber,
      'totalIncome': instance.totalIncome,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

TeacherRequest _$TeacherRequestFromJson(Map<String, dynamic> json) =>
    TeacherRequest(
      fullName: json['fullName'] as String,
      phoneNumber: json['phoneNumber'] as String,
    );

Map<String, dynamic> _$TeacherRequestToJson(TeacherRequest instance) =>
    <String, dynamic>{
      'fullName': instance.fullName,
      'phoneNumber': instance.phoneNumber,
    };

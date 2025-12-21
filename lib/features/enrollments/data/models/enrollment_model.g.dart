// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enrollment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EnrollmentModel _$EnrollmentModelFromJson(Map<String, dynamic> json) =>
    EnrollmentModel(
      id: (json['id'] as num).toInt(),
      studentId: (json['studentId'] as num).toInt(),
      studentName: json['studentName'] as String,
      groupId: (json['groupId'] as num).toInt(),
      groupName: json['groupName'] as String,
      teacherName: json['teacherName'] as String,
      monthlyFee: (json['monthlyFee'] as num).toDouble(),
      active: json['active'] as bool,
      enrolledAt: DateTime.parse(json['enrolledAt'] as String),
      leftAt: json['leftAt'] == null
          ? null
          : DateTime.parse(json['leftAt'] as String),
    );

Map<String, dynamic> _$EnrollmentModelToJson(EnrollmentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'studentId': instance.studentId,
      'studentName': instance.studentName,
      'groupId': instance.groupId,
      'groupName': instance.groupName,
      'teacherName': instance.teacherName,
      'monthlyFee': instance.monthlyFee,
      'active': instance.active,
      'enrolledAt': instance.enrolledAt.toIso8601String(),
      'leftAt': instance.leftAt?.toIso8601String(),
    };

EnrollmentRequest _$EnrollmentRequestFromJson(Map<String, dynamic> json) =>
    EnrollmentRequest(
      studentId: (json['studentId'] as num).toInt(),
      groupId: (json['groupId'] as num).toInt(),
    );

Map<String, dynamic> _$EnrollmentRequestToJson(EnrollmentRequest instance) =>
    <String, dynamic>{
      'studentId': instance.studentId,
      'groupId': instance.groupId,
    };

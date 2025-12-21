// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceModel _$AttendanceModelFromJson(Map<String, dynamic> json) =>
    AttendanceModel(
      id: (json['id'] as num).toInt(),
      date: DateTime.parse(json['date'] as String),
      studentId: (json['studentId'] as num).toInt(),
      studentName: json['studentName'] as String,
      groupId: (json['groupId'] as num).toInt(),
      groupName: json['groupName'] as String,
      status: $enumDecode(_$AttendanceStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AttendanceModelToJson(AttendanceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'studentId': instance.studentId,
      'studentName': instance.studentName,
      'groupId': instance.groupId,
      'groupName': instance.groupName,
      'status': _$AttendanceStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$AttendanceStatusEnumMap = {
  AttendanceStatus.PRESENT: 'PRESENT',
  AttendanceStatus.ABSENT: 'ABSENT',
};

AttendanceRequest _$AttendanceRequestFromJson(Map<String, dynamic> json) =>
    AttendanceRequest(
      groupId: (json['groupId'] as num).toInt(),
      date: DateTime.parse(json['date'] as String),
      absentStudentIds: (json['absentStudentIds'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$AttendanceRequestToJson(AttendanceRequest instance) =>
    <String, dynamic>{
      'groupId': instance.groupId,
      'date': instance.date.toIso8601String(),
      'absentStudentIds': instance.absentStudentIds,
    };

AttendanceUpdateRequest _$AttendanceUpdateRequestFromJson(
  Map<String, dynamic> json,
) => AttendanceUpdateRequest(
  status: $enumDecode(_$AttendanceStatusEnumMap, json['status']),
);

Map<String, dynamic> _$AttendanceUpdateRequestToJson(
  AttendanceUpdateRequest instance,
) => <String, dynamic>{'status': _$AttendanceStatusEnumMap[instance.status]!};

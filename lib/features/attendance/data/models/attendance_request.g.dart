// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AttendanceRequestImpl _$$AttendanceRequestImplFromJson(
  Map<String, dynamic> json,
) => _$AttendanceRequestImpl(
  groupId: (json['groupId'] as num).toInt(),
  date: DateTime.parse(json['date'] as String),
  absentStudentIds: (json['absentStudentIds'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
);

Map<String, dynamic> _$$AttendanceRequestImplToJson(
  _$AttendanceRequestImpl instance,
) => <String, dynamic>{
  'groupId': instance.groupId,
  'date': instance.date.toIso8601String(),
  'absentStudentIds': instance.absentStudentIds,
};

_$AttendanceUpdateRequestImpl _$$AttendanceUpdateRequestImplFromJson(
  Map<String, dynamic> json,
) => _$AttendanceUpdateRequestImpl(status: json['status'] as String);

Map<String, dynamic> _$$AttendanceUpdateRequestImplToJson(
  _$AttendanceUpdateRequestImpl instance,
) => <String, dynamic>{'status': instance.status};

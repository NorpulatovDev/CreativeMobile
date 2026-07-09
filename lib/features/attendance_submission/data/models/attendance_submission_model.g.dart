// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_submission_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceSubmissionModel _$AttendanceSubmissionModelFromJson(
  Map<String, dynamic> json,
) => AttendanceSubmissionModel(
  id: (json['id'] as num).toInt(),
  date: DateTime.parse(json['date'] as String),
  groupId: (json['groupId'] as num).toInt(),
  groupName: json['groupName'] as String,
  teacherId: (json['teacherId'] as num).toInt(),
  teacherName: json['teacherName'] as String,
  status: $enumDecode(_$SubmissionStatusEnumMap, json['status']),
  note: json['note'] as String?,
  totalCount: (json['totalCount'] as num).toInt(),
  absentCount: (json['absentCount'] as num).toInt(),
  items: (json['items'] as List<dynamic>)
      .map((e) => SubmissionItemModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  submittedAt: json['submittedAt'] == null
      ? null
      : DateTime.parse(json['submittedAt'] as String),
  reviewedAt: json['reviewedAt'] == null
      ? null
      : DateTime.parse(json['reviewedAt'] as String),
);

Map<String, dynamic> _$AttendanceSubmissionModelToJson(
  AttendanceSubmissionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'date': instance.date.toIso8601String(),
  'groupId': instance.groupId,
  'groupName': instance.groupName,
  'teacherId': instance.teacherId,
  'teacherName': instance.teacherName,
  'status': _$SubmissionStatusEnumMap[instance.status]!,
  'note': instance.note,
  'totalCount': instance.totalCount,
  'absentCount': instance.absentCount,
  'items': instance.items,
  'submittedAt': instance.submittedAt?.toIso8601String(),
  'reviewedAt': instance.reviewedAt?.toIso8601String(),
};

const _$SubmissionStatusEnumMap = {
  SubmissionStatus.PENDING: 'PENDING',
  SubmissionStatus.APPROVED: 'APPROVED',
  SubmissionStatus.REJECTED: 'REJECTED',
};

SubmissionItemModel _$SubmissionItemModelFromJson(Map<String, dynamic> json) =>
    SubmissionItemModel(
      studentId: (json['studentId'] as num).toInt(),
      studentName: json['studentName'] as String,
      status: $enumDecode(_$AttendanceStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$SubmissionItemModelToJson(
  SubmissionItemModel instance,
) => <String, dynamic>{
  'studentId': instance.studentId,
  'studentName': instance.studentName,
  'status': _$AttendanceStatusEnumMap[instance.status]!,
};

const _$AttendanceStatusEnumMap = {
  AttendanceStatus.PRESENT: 'PRESENT',
  AttendanceStatus.ABSENT: 'ABSENT',
};

AttendanceSubmissionRequest _$AttendanceSubmissionRequestFromJson(
  Map<String, dynamic> json,
) => AttendanceSubmissionRequest(
  groupId: (json['groupId'] as num).toInt(),
  date: DateTime.parse(json['date'] as String),
  items: (json['items'] as List<dynamic>)
      .map((e) => SubmissionItemRequest.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$AttendanceSubmissionRequestToJson(
  AttendanceSubmissionRequest instance,
) => <String, dynamic>{
  'groupId': instance.groupId,
  'date': instance.date.toIso8601String(),
  'items': instance.items,
};

SubmissionItemRequest _$SubmissionItemRequestFromJson(
  Map<String, dynamic> json,
) => SubmissionItemRequest(
  studentId: (json['studentId'] as num).toInt(),
  status: $enumDecode(_$AttendanceStatusEnumMap, json['status']),
);

Map<String, dynamic> _$SubmissionItemRequestToJson(
  SubmissionItemRequest instance,
) => <String, dynamic>{
  'studentId': instance.studentId,
  'status': _$AttendanceStatusEnumMap[instance.status]!,
};

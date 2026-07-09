import 'package:json_annotation/json_annotation.dart';

import '../../../attendance/data/models/attendance_model.dart' show AttendanceStatus;

part 'attendance_submission_model.g.dart';

enum SubmissionStatus { PENDING, APPROVED, REJECTED }

@JsonSerializable()
class AttendanceSubmissionModel {
  final int id;
  final DateTime date;
  final int groupId;
  final String groupName;
  final int teacherId;
  final String teacherName;
  final SubmissionStatus status;
  final String? note;
  final int totalCount;
  final int absentCount;
  final List<SubmissionItemModel> items;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;

  const AttendanceSubmissionModel({
    required this.id,
    required this.date,
    required this.groupId,
    required this.groupName,
    required this.teacherId,
    required this.teacherName,
    required this.status,
    this.note,
    required this.totalCount,
    required this.absentCount,
    required this.items,
    this.submittedAt,
    this.reviewedAt,
  });

  factory AttendanceSubmissionModel.fromJson(Map<String, dynamic> json) =>
      _$AttendanceSubmissionModelFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceSubmissionModelToJson(this);
}

@JsonSerializable()
class SubmissionItemModel {
  final int studentId;
  final String studentName;
  final AttendanceStatus status;

  const SubmissionItemModel({
    required this.studentId,
    required this.studentName,
    required this.status,
  });

  factory SubmissionItemModel.fromJson(Map<String, dynamic> json) =>
      _$SubmissionItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubmissionItemModelToJson(this);
}

/// Teacher submit payload. Mirrors backend AttendanceSubmissionRequest.
@JsonSerializable()
class AttendanceSubmissionRequest {
  final int groupId;
  final DateTime date;
  final List<SubmissionItemRequest> items;

  const AttendanceSubmissionRequest({
    required this.groupId,
    required this.date,
    required this.items,
  });

  factory AttendanceSubmissionRequest.fromJson(Map<String, dynamic> json) =>
      _$AttendanceSubmissionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceSubmissionRequestToJson(this);
}

@JsonSerializable()
class SubmissionItemRequest {
  final int studentId;
  final AttendanceStatus status;

  const SubmissionItemRequest({
    required this.studentId,
    required this.status,
  });

  factory SubmissionItemRequest.fromJson(Map<String, dynamic> json) =>
      _$SubmissionItemRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SubmissionItemRequestToJson(this);
}

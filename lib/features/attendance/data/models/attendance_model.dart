import 'package:json_annotation/json_annotation.dart';

part 'attendance_model.g.dart';

enum AttendanceStatus { PRESENT, ABSENT }

@JsonSerializable()
class AttendanceModel {
  final int id;
  final DateTime date;
  final int studentId;
  final String studentName;
  final int groupId;
  final String groupName;
  final AttendanceStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AttendanceModel({
    required this.id,
    required this.date,
    required this.studentId,
    required this.studentName,
    required this.groupId,
    required this.groupName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) =>
      _$AttendanceModelFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceModelToJson(this);
}

@JsonSerializable()
class AttendanceRequest {
  final int groupId;
  final DateTime date;
  final List<int>? absentStudentIds;

  const AttendanceRequest({
    required this.groupId,
    required this.date,
    this.absentStudentIds,
  });

  factory AttendanceRequest.fromJson(Map<String, dynamic> json) =>
      _$AttendanceRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceRequestToJson(this);
}

@JsonSerializable()
class AttendanceUpdateRequest {
  final AttendanceStatus status;

  const AttendanceUpdateRequest({required this.status});

  factory AttendanceUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$AttendanceUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceUpdateRequestToJson(this);
}
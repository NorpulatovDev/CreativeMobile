import 'package:freezed_annotation/freezed_annotation.dart';

part 'attendance_request.freezed.dart';
part 'attendance_request.g.dart';

@freezed
class AttendanceRequest with _$AttendanceRequest {
  const factory AttendanceRequest({
    required int groupId,
    required DateTime date,
    List<int>? absentStudentIds,
  }) = _AttendanceRequest;

  factory AttendanceRequest.fromJson(Map<String, dynamic> json) =>
      _$AttendanceRequestFromJson(json);
}

@freezed
class AttendanceUpdateRequest with _$AttendanceUpdateRequest {
  const factory AttendanceUpdateRequest({
    required String status,
  }) = _AttendanceUpdateRequest;

  factory AttendanceUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$AttendanceUpdateRequestFromJson(json);
}
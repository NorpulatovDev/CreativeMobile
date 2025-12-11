import 'package:freezed_annotation/freezed_annotation.dart';

part 'attendance.freezed.dart';
part 'attendance.g.dart';

enum AttendanceStatus { PRESENT, ABSENT }

@freezed
class Attendance with _$Attendance {
  const factory Attendance({
    required int id,
    required DateTime date,
    required int studentId,
    required String studentName,
    required int groupId,
    required String groupName,
    required AttendanceStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Attendance;

  factory Attendance.fromJson(Map<String, dynamic> json) =>
      _$AttendanceFromJson(json);
}
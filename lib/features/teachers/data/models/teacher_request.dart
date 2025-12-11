import 'package:freezed_annotation/freezed_annotation.dart';

part 'teacher_request.freezed.dart';
part 'teacher_request.g.dart';

@freezed
class TeacherRequest with _$TeacherRequest {
  const factory TeacherRequest({
    required String fullName,
    required String phoneNumber,
  }) = _TeacherRequest;

  factory TeacherRequest.fromJson(Map<String, dynamic> json) =>
      _$TeacherRequestFromJson(json);
}
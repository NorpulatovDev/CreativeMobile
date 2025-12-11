import 'package:freezed_annotation/freezed_annotation.dart';

part 'student_request.freezed.dart';
part 'student_request.g.dart';

@freezed
class StudentRequest with _$StudentRequest {
  const factory StudentRequest({
    required String fullName,
    required String parentName,
    required String parentPhoneNumber,
    int? activeGroupId,
  }) = _StudentRequest;

  factory StudentRequest.fromJson(Map<String, dynamic> json) =>
      _$StudentRequestFromJson(json);
}
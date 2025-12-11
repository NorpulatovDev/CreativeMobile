import 'package:freezed_annotation/freezed_annotation.dart';

part 'student.freezed.dart';
part 'student.g.dart';

@freezed
class Student with _$Student {
  const factory Student({
    required int id,
    required String fullName,
    required String parentName,
    required String parentPhoneNumber,
    required bool smsLinked,
    required String smsLinkCode,
    required double totalPaid,
    int? activeGroupId,
    String? activeGroupName,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Student;

  factory Student.fromJson(Map<String, dynamic> json) =>
      _$StudentFromJson(json);
}
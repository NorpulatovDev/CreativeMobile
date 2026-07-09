import 'package:json_annotation/json_annotation.dart';

part 'teacher_model.g.dart';

@JsonSerializable()
class TeacherModel {
  final int id;
  final String fullName;
  final String phoneNumber;
  final double totalIncome;
  @JsonKey(defaultValue: false)
  final bool hasLogin;
  final String? username;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TeacherModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.totalIncome,
    this.hasLogin = false,
    this.username,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) =>
      _$TeacherModelFromJson(json);

  Map<String, dynamic> toJson() => _$TeacherModelToJson(this);
}

@JsonSerializable()
class TeacherRequest {
  final String fullName;
  final String phoneNumber;
  // Optional login provisioning (admin-only). Blank password on update keeps
  // the existing credential.
  final String? username;
  final String? password;

  const TeacherRequest({
    required this.fullName,
    required this.phoneNumber,
    this.username,
    this.password,
  });

  factory TeacherRequest.fromJson(Map<String, dynamic> json) =>
      _$TeacherRequestFromJson(json);

  Map<String, dynamic> toJson() => _$TeacherRequestToJson(this);
}
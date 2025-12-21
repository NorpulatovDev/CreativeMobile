import 'package:json_annotation/json_annotation.dart';

part 'teacher_model.g.dart';

@JsonSerializable()
class TeacherModel {
  final int id;
  final String fullName;
  final String phoneNumber;
  final double totalIncome;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TeacherModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.totalIncome,
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

  const TeacherRequest({
    required this.fullName,
    required this.phoneNumber,
  });

  factory TeacherRequest.fromJson(Map<String, dynamic> json) =>
      _$TeacherRequestFromJson(json);

  Map<String, dynamic> toJson() => _$TeacherRequestToJson(this);
}
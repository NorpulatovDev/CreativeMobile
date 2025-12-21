import 'package:json_annotation/json_annotation.dart';

part 'group_model.g.dart';

@JsonSerializable()
class GroupModel {
  final int id;
  final String name;
  final int teacherId;
  final String teacherName;
  final double monthlyFee;
  final int studentsCount;
  final double totalAmountToPay;
  final double totalPaid;
  final DateTime createdAt;
  final DateTime updatedAt;

  const GroupModel({
    required this.id,
    required this.name,
    required this.teacherId,
    required this.teacherName,
    required this.monthlyFee,
    required this.studentsCount,
    required this.totalAmountToPay,
    required this.totalPaid,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) =>
      _$GroupModelFromJson(json);

  Map<String, dynamic> toJson() => _$GroupModelToJson(this);
}

@JsonSerializable()
class GroupRequest {
  final String name;
  final int teacherId;
  final double monthlyFee;

  const GroupRequest({
    required this.name,
    required this.teacherId,
    required this.monthlyFee,
  });

  factory GroupRequest.fromJson(Map<String, dynamic> json) =>
      _$GroupRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GroupRequestToJson(this);
}
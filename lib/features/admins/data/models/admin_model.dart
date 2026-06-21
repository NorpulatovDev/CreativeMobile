import 'package:json_annotation/json_annotation.dart';

part 'admin_model.g.dart';

@JsonSerializable()
class AdminModel {
  final int id;
  final String username;
  final String role;
  final int? branchId;
  final String? branchName;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AdminModel({
    required this.id,
    required this.username,
    required this.role,
    this.branchId,
    this.branchName,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isSuperAdmin => role == 'SUPER_ADMIN';

  factory AdminModel.fromJson(Map<String, dynamic> json) =>
      _$AdminModelFromJson(json);

  Map<String, dynamic> toJson() => _$AdminModelToJson(this);
}

@JsonSerializable()
class AdminRequest {
  final String username;
  final String password;
  final String role;
  final int? branchId;

  const AdminRequest({
    required this.username,
    required this.password,
    required this.role,
    this.branchId,
  });

  factory AdminRequest.fromJson(Map<String, dynamic> json) =>
      _$AdminRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AdminRequestToJson(this);
}

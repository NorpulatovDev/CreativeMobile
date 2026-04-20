import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends Equatable {
  final int adminId;
  final String username;
  final String role;
  final String accessToken;
  final int? branchId;
  final String? branchName;

  const UserModel({
    required this.adminId,
    required this.username,
    required this.role,
    required this.accessToken,
    this.branchId,
    this.branchName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  @override
  List<Object?> get props => [adminId, username, role, accessToken, branchId, branchName];
}

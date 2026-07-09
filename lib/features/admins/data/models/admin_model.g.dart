// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminModel _$AdminModelFromJson(Map<String, dynamic> json) => AdminModel(
  id: (json['id'] as num).toInt(),
  username: json['username'] as String,
  role: json['role'] as String,
  branchId: (json['branchId'] as num?)?.toInt(),
  branchName: json['branchName'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$AdminModelToJson(AdminModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'role': instance.role,
      'branchId': instance.branchId,
      'branchName': instance.branchName,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

AdminRequest _$AdminRequestFromJson(Map<String, dynamic> json) => AdminRequest(
  username: json['username'] as String,
  password: json['password'] as String,
  role: json['role'] as String,
  branchId: (json['branchId'] as num?)?.toInt(),
);

Map<String, dynamic> _$AdminRequestToJson(AdminRequest instance) =>
    <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
      'role': instance.role,
      'branchId': instance.branchId,
    };

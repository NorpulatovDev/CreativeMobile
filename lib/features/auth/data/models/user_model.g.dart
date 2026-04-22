// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  adminId: (json['adminId'] as num).toInt(),
  username: json['username'] as String,
  role: json['role'] as String,
  accessToken: json['accessToken'] as String,
  branchId: (json['branchId'] as num?)?.toInt(),
  branchName: json['branchName'] as String?,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'adminId': instance.adminId,
  'username': instance.username,
  'role': instance.role,
  'accessToken': instance.accessToken,
  'branchId': instance.branchId,
  'branchName': instance.branchName,
};

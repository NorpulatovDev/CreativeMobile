// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    LoginResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      tokenType: json['tokenType'] as String,
      expiresIn: (json['expiresIn'] as num).toInt(),
      adminId: (json['adminId'] as num).toInt(),
      username: json['username'] as String,
      role: json['role'] as String,
      branchId: (json['branchId'] as num?)?.toInt(),
      branchName: json['branchName'] as String?,
    );

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'tokenType': instance.tokenType,
      'expiresIn': instance.expiresIn,
      'adminId': instance.adminId,
      'username': instance.username,
      'role': instance.role,
      'branchId': instance.branchId,
      'branchName': instance.branchName,
    };

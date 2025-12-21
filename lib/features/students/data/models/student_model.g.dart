// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentModel _$StudentModelFromJson(Map<String, dynamic> json) => StudentModel(
  id: (json['id'] as num).toInt(),
  fullName: json['fullName'] as String,
  parentName: json['parentName'] as String,
  parentPhoneNumber: json['parentPhoneNumber'] as String,
  smsLinkCode: json['smsLinkCode'] as String?,
  totalPaid: (json['totalPaid'] as num).toDouble(),
  activeGroups: (json['activeGroups'] as List<dynamic>)
      .map((e) => GroupInfo.fromJson(e as Map<String, dynamic>))
      .toList(),
  activeGroupsCount: (json['activeGroupsCount'] as num).toInt(),
  paidForCurrentMonth: json['paidForCurrentMonth'] as bool,
  groupsPaidCount: (json['groupsPaidCount'] as num).toInt(),
  groupsUnpaidCount: (json['groupsUnpaidCount'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$StudentModelToJson(StudentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'parentName': instance.parentName,
      'parentPhoneNumber': instance.parentPhoneNumber,
      'smsLinkCode': instance.smsLinkCode,
      'totalPaid': instance.totalPaid,
      'activeGroups': instance.activeGroups,
      'activeGroupsCount': instance.activeGroupsCount,
      'paidForCurrentMonth': instance.paidForCurrentMonth,
      'groupsPaidCount': instance.groupsPaidCount,
      'groupsUnpaidCount': instance.groupsUnpaidCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

GroupInfo _$GroupInfoFromJson(Map<String, dynamic> json) => GroupInfo(
  groupId: (json['groupId'] as num).toInt(),
  groupName: json['groupName'] as String,
  teacherName: json['teacherName'] as String,
  monthlyFee: (json['monthlyFee'] as num).toDouble(),
  paidForCurrentMonth: json['paidForCurrentMonth'] as bool,
  currentMonth: json['currentMonth'] as String?,
  amountPaidThisMonth: (json['amountPaidThisMonth'] as num?)?.toDouble(),
);

Map<String, dynamic> _$GroupInfoToJson(GroupInfo instance) => <String, dynamic>{
  'groupId': instance.groupId,
  'groupName': instance.groupName,
  'teacherName': instance.teacherName,
  'monthlyFee': instance.monthlyFee,
  'paidForCurrentMonth': instance.paidForCurrentMonth,
  'currentMonth': instance.currentMonth,
  'amountPaidThisMonth': instance.amountPaidThisMonth,
};

StudentRequest _$StudentRequestFromJson(Map<String, dynamic> json) =>
    StudentRequest(
      fullName: json['fullName'] as String,
      parentName: json['parentName'] as String,
      parentPhoneNumber: json['parentPhoneNumber'] as String,
    );

Map<String, dynamic> _$StudentRequestToJson(StudentRequest instance) =>
    <String, dynamic>{
      'fullName': instance.fullName,
      'parentName': instance.parentName,
      'parentPhoneNumber': instance.parentPhoneNumber,
    };

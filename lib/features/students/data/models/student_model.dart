import 'package:json_annotation/json_annotation.dart';

part 'student_model.g.dart';

@JsonSerializable()
class StudentModel {
  final int id;
  final String fullName;
  final String parentName;
  final String parentPhoneNumber;
  final String? smsLinkCode;
  final double totalPaid;
  final List<GroupInfo> activeGroups;
  final int activeGroupsCount;
  final bool paidForCurrentMonth;
  final int groupsPaidCount;
  final int groupsUnpaidCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StudentModel({
    required this.id,
    required this.fullName,
    required this.parentName,
    required this.parentPhoneNumber,
    this.smsLinkCode,
    required this.totalPaid,
    required this.activeGroups,
    required this.activeGroupsCount,
    required this.paidForCurrentMonth,
    required this.groupsPaidCount,
    required this.groupsUnpaidCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) =>
      _$StudentModelFromJson(json);

  Map<String, dynamic> toJson() => _$StudentModelToJson(this);
}

@JsonSerializable()
class GroupInfo {
  final int groupId;
  final String groupName;
  final String teacherName;
  final double monthlyFee;
  final bool paidForCurrentMonth;
  final String? currentMonth;
  final double? amountPaidThisMonth;

  const GroupInfo({
    required this.groupId,
    required this.groupName,
    required this.teacherName,
    required this.monthlyFee,
    required this.paidForCurrentMonth,
    this.currentMonth,
    this.amountPaidThisMonth,
  });

  factory GroupInfo.fromJson(Map<String, dynamic> json) =>
      _$GroupInfoFromJson(json);

  Map<String, dynamic> toJson() => _$GroupInfoToJson(this);
}

@JsonSerializable()
class StudentRequest {
  final String fullName;
  final String parentName;
  final String parentPhoneNumber;

  const StudentRequest({
    required this.fullName,
    required this.parentName,
    required this.parentPhoneNumber,
  });

  factory StudentRequest.fromJson(Map<String, dynamic> json) =>
      _$StudentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$StudentRequestToJson(this);
}
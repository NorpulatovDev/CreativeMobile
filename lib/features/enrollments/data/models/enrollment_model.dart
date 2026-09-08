import 'package:json_annotation/json_annotation.dart';

part 'enrollment_model.g.dart';

@JsonSerializable()
class EnrollmentModel {
  final int id;
  final int studentId;
  final String studentName;
  final int groupId;
  final String groupName;
  final String teacherName;
  final double monthlyFee;
  final bool active;
  final DateTime enrolledAt;
  final DateTime? leftAt;

  const EnrollmentModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.groupId,
    required this.groupName,
    required this.teacherName,
    required this.monthlyFee,
    required this.active,
    required this.enrolledAt,
    this.leftAt,
  });

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) =>
      _$EnrollmentModelFromJson(json);

  Map<String, dynamic> toJson() => _$EnrollmentModelToJson(this);
}

@JsonSerializable()
class EnrollmentRequest {
  final int studentId;
  final int groupId;

  const EnrollmentRequest({
    required this.studentId,
    required this.groupId,
  });

  factory EnrollmentRequest.fromJson(Map<String, dynamic> json) =>
      _$EnrollmentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$EnrollmentRequestToJson(this);
}

class TransferRequest {
  final List<int> studentIds;
  final int fromGroupId;
  final int toGroupId;
  final bool transferAllPayments;

  const TransferRequest({
    required this.studentIds,
    required this.fromGroupId,
    required this.toGroupId,
    this.transferAllPayments = false,
  });

  Map<String, dynamic> toJson() => {
        'studentIds': studentIds,
        'fromGroupId': fromGroupId,
        'toGroupId': toGroupId,
        'transferAllPayments': transferAllPayments,
      };
}

class TransferBranchRequest {
  final List<int> studentIds;
  final int fromBranchId;
  final int toBranchId;
  final int targetGroupId;
  final bool transferAllPayments;

  const TransferBranchRequest({
    required this.studentIds,
    required this.fromBranchId,
    required this.toBranchId,
    required this.targetGroupId,
    this.transferAllPayments = false,
  });

  Map<String, dynamic> toJson() => {
        'studentIds': studentIds,
        'fromBranchId': fromBranchId,
        'toBranchId': toBranchId,
        'targetGroupId': targetGroupId,
        'transferAllPayments': transferAllPayments,
      };
}
class InquiryGroupModel {
  final int id;
  final String name;
  final int? branchId;
  final String? branchName;
  final int inquiryCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const InquiryGroupModel({
    required this.id,
    required this.name,
    this.branchId,
    this.branchName,
    required this.inquiryCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InquiryGroupModel.fromJson(Map<String, dynamic> json) =>
      InquiryGroupModel(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String,
        branchId: (json['branchId'] as num?)?.toInt(),
        branchName: json['branchName'] as String?,
        inquiryCount: (json['inquiryCount'] as num?)?.toInt() ?? 0,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'branchId': branchId,
        'branchName': branchName,
        'inquiryCount': inquiryCount,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

class InquiryGroupRequest {
  final String name;

  const InquiryGroupRequest({required this.name});

  Map<String, dynamic> toJson() => {'name': name};
}

class MigrateToGroupRequest {
  final int inquiryGroupId;
  final int groupId;

  const MigrateToGroupRequest({
    required this.inquiryGroupId,
    required this.groupId,
  });

  Map<String, dynamic> toJson() => {
        'inquiryGroupId': inquiryGroupId,
        'groupId': groupId,
      };
}

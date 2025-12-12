class GroupInfo {
  final int groupId;
  final String groupName;
  final String teacherName;
  final double monthlyFee;

  GroupInfo({
    required this.groupId,
    required this.groupName,
    required this.teacherName,
    required this.monthlyFee,
  });

  factory GroupInfo.fromJson(Map<String, dynamic> json) {
    return GroupInfo(
      groupId: json['groupId'] as int,
      groupName: json['groupName'] as String,
      teacherName: json['teacherName'] as String,
      monthlyFee: (json['monthlyFee'] as num).toDouble(),
    );
  }
}

class Student {
  final int id;
  final String fullName;
  final String parentName;
  final String parentPhoneNumber;
  final bool smsLinked;
  final String? smsLinkCode;
  final double totalPaid;
  final List<GroupInfo> activeGroups;
  final int activeGroupsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Student({
    required this.id,
    required this.fullName,
    required this.parentName,
    required this.parentPhoneNumber,
    required this.smsLinked,
    this.smsLinkCode,
    required this.totalPaid,
    required this.activeGroups,
    required this.activeGroupsCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as int,
      fullName: json['fullName'] as String,
      parentName: json['parentName'] as String,
      parentPhoneNumber: json['parentPhoneNumber'] as String,
      smsLinked: json['smsLinked'] as bool? ?? false,
      smsLinkCode: json['smsLinkCode'] as String?,
      totalPaid: (json['totalPaid'] as num?)?.toDouble() ?? 0.0,
      activeGroups: (json['activeGroups'] as List<dynamic>?)
              ?.map((e) => GroupInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      activeGroupsCount: json['activeGroupsCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class StudentRequest {
  final String fullName;
  final String parentName;
  final String parentPhoneNumber;
  final List<int>? groupIds;

  StudentRequest({
    required this.fullName,
    required this.parentName,
    required this.parentPhoneNumber,
    this.groupIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'parentName': parentName,
      'parentPhoneNumber': parentPhoneNumber,
      if (groupIds != null) 'groupIds': groupIds,
    };
  }
}
class StudentGroup {
  final int id;
  final int studentId;
  final String studentName;
  final int groupId;
  final String groupName;
  final String teacherName;
  final double monthlyFee;
  final bool active;
  final String enrolledAt;
  final String? leftAt;

  StudentGroup({
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

  factory StudentGroup.fromJson(Map<String, dynamic> json) {
    return StudentGroup(
      id: json['id'] as int,
      studentId: json['studentId'] as int,
      studentName: json['studentName'] as String,
      groupId: json['groupId'] as int,
      groupName: json['groupName'] as String,
      teacherName: json['teacherName'] as String,
      monthlyFee: (json['monthlyFee'] as num).toDouble(),
      active: json['active'] as bool,
      enrolledAt: json['enrolledAt'] as String,
      leftAt: json['leftAt'] as String?,
    );
  }
}

class StudentGroupRequest {
  final int studentId;
  final int groupId;

  StudentGroupRequest({
    required this.studentId,
    required this.groupId,
  });

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'groupId': groupId,
    };
  }
}
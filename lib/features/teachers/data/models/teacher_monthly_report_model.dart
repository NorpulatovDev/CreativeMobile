class TeacherMonthlyReport {
  final int teacherId;
  final String teacherName;
  final String phoneNumber;
  final int year;
  final int month;
  final String monthName;
  final int totalPaymentsCount;
  final double totalAmount;
  final List<TeacherGroupMonthlyStats> groups;
  final List<TeacherPaymentItem> payments;

  const TeacherMonthlyReport({
    required this.teacherId,
    required this.teacherName,
    required this.phoneNumber,
    required this.year,
    required this.month,
    required this.monthName,
    required this.totalPaymentsCount,
    required this.totalAmount,
    required this.groups,
    required this.payments,
  });

  factory TeacherMonthlyReport.fromJson(Map<String, dynamic> json) =>
      TeacherMonthlyReport(
        teacherId: json['teacherId'] as int,
        teacherName: json['teacherName'] as String,
        phoneNumber: json['phoneNumber'] as String,
        year: json['year'] as int,
        month: json['month'] as int,
        monthName: json['monthName'] as String,
        totalPaymentsCount: json['totalPaymentsCount'] as int,
        totalAmount: (json['totalAmount'] as num).toDouble(),
        groups: (json['groups'] as List<dynamic>)
            .map((e) => TeacherGroupMonthlyStats.fromJson(e as Map<String, dynamic>))
            .toList(),
        payments: (json['payments'] as List<dynamic>)
            .map((e) => TeacherPaymentItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class TeacherGroupMonthlyStats {
  final int groupId;
  final String groupName;
  final int activeStudents;
  final double expectedRevenue;
  final double actualRevenue;
  final double collectionRate;
  final int paidStudents;
  final int unpaidStudents;
  final List<TeacherUnpaidStudent> unpaidStudentList;

  const TeacherGroupMonthlyStats({
    required this.groupId,
    required this.groupName,
    required this.activeStudents,
    required this.expectedRevenue,
    required this.actualRevenue,
    required this.collectionRate,
    required this.paidStudents,
    required this.unpaidStudents,
    required this.unpaidStudentList,
  });

  factory TeacherGroupMonthlyStats.fromJson(Map<String, dynamic> json) =>
      TeacherGroupMonthlyStats(
        groupId: json['groupId'] as int,
        groupName: json['groupName'] as String,
        activeStudents: json['activeStudents'] as int,
        expectedRevenue: (json['expectedRevenue'] as num).toDouble(),
        actualRevenue: (json['actualRevenue'] as num).toDouble(),
        collectionRate: (json['collectionRate'] as num).toDouble(),
        paidStudents: json['paidStudents'] as int,
        unpaidStudents: json['unpaidStudents'] as int,
        unpaidStudentList: (json['unpaidStudentList'] as List<dynamic>? ?? [])
            .map((e) => TeacherUnpaidStudent.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class TeacherUnpaidStudent {
  final String studentName;
  final double amountPaid;
  final double amountDue;

  const TeacherUnpaidStudent({
    required this.studentName,
    required this.amountPaid,
    required this.amountDue,
  });

  factory TeacherUnpaidStudent.fromJson(Map<String, dynamic> json) =>
      TeacherUnpaidStudent(
        studentName: json['studentName'] as String,
        amountPaid: (json['amountPaid'] as num).toDouble(),
        amountDue: (json['amountDue'] as num).toDouble(),
      );
}

class TeacherPaymentItem {
  final int paymentId;
  final String studentName;
  final String groupName;
  final double amount;
  final String paidForMonth;
  final DateTime paidAt;

  const TeacherPaymentItem({
    required this.paymentId,
    required this.studentName,
    required this.groupName,
    required this.amount,
    required this.paidForMonth,
    required this.paidAt,
  });

  factory TeacherPaymentItem.fromJson(Map<String, dynamic> json) =>
      TeacherPaymentItem(
        paymentId: json['paymentId'] as int,
        studentName: json['studentName'] as String,
        groupName: json['groupName'] as String,
        amount: (json['amount'] as num).toDouble(),
        paidForMonth: json['paidForMonth'] as String,
        paidAt: DateTime.parse(json['paidAt'] as String),
      );
}

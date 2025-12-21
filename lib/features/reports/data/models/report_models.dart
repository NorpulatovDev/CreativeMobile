// lib/features/reports/data/models/report_models.dart

import 'package:json_annotation/json_annotation.dart';

part 'report_models.g.dart';

// ==================== DAILY REPORT ====================

@JsonSerializable()
class DailyReport {
  final DateTime date;
  final int totalStudentsPresent;
  final int totalStudentsAbsent;
  final double totalPaymentsReceived;
  final int paymentCount;
  final List<GroupAttendanceSummary> groupAttendances;
  final List<PaymentSummary> payments;

  const DailyReport({
    required this.date,
    required this.totalStudentsPresent,
    required this.totalStudentsAbsent,
    required this.totalPaymentsReceived,
    required this.paymentCount,
    required this.groupAttendances,
    required this.payments,
  });

  factory DailyReport.fromJson(Map<String, dynamic> json) =>
      _$DailyReportFromJson(json);

  Map<String, dynamic> toJson() => _$DailyReportToJson(this);
}

@JsonSerializable()
class GroupAttendanceSummary {
  final int groupId;
  final String groupName;
  final String teacherName;
  final int presentCount;
  final int absentCount;
  final int totalStudents;

  const GroupAttendanceSummary({
    required this.groupId,
    required this.groupName,
    required this.teacherName,
    required this.presentCount,
    required this.absentCount,
    required this.totalStudents,
  });

  factory GroupAttendanceSummary.fromJson(Map<String, dynamic> json) =>
      _$GroupAttendanceSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$GroupAttendanceSummaryToJson(this);
}

@JsonSerializable()
class PaymentSummary {
  final int paymentId;
  final String studentName;
  final String groupName;
  final double amount;
  final String paidForMonth;

  const PaymentSummary({
    required this.paymentId,
    required this.studentName,
    required this.groupName,
    required this.amount,
    required this.paidForMonth,
  });

  factory PaymentSummary.fromJson(Map<String, dynamic> json) =>
      _$PaymentSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentSummaryToJson(this);
}

// ==================== MONTHLY REPORT ====================

@JsonSerializable()
class MonthlyReport {
  final int year;
  final int month;
  final String monthName;
  final int totalActiveStudents;
  final int totalGroups;
  final double expectedRevenue;
  final double actualRevenue;
  final double collectionRate;
  final int totalPayments;
  final int studentsWhoPaid;
  final int studentsWhoDidNotPay;
  final List<GroupMonthlyStats> groupStats;
  final List<StudentPaymentStatus> unpaidStudents;
  final AttendanceStats attendanceStats;

  const MonthlyReport({
    required this.year,
    required this.month,
    required this.monthName,
    required this.totalActiveStudents,
    required this.totalGroups,
    required this.expectedRevenue,
    required this.actualRevenue,
    required this.collectionRate,
    required this.totalPayments,
    required this.studentsWhoPaid,
    required this.studentsWhoDidNotPay,
    required this.groupStats,
    required this.unpaidStudents,
    required this.attendanceStats,
  });

  factory MonthlyReport.fromJson(Map<String, dynamic> json) =>
      _$MonthlyReportFromJson(json);

  Map<String, dynamic> toJson() => _$MonthlyReportToJson(this);
}

@JsonSerializable()
class GroupMonthlyStats {
  final int groupId;
  final String groupName;
  final String teacherName;
  final int activeStudents;
  final double expectedRevenue;
  final double actualRevenue;
  final int paidStudents;
  final int unpaidStudents;
  final double collectionRate;

  const GroupMonthlyStats({
    required this.groupId,
    required this.groupName,
    required this.teacherName,
    required this.activeStudents,
    required this.expectedRevenue,
    required this.actualRevenue,
    required this.paidStudents,
    required this.unpaidStudents,
    required this.collectionRate,
  });

  factory GroupMonthlyStats.fromJson(Map<String, dynamic> json) =>
      _$GroupMonthlyStatsFromJson(json);

  Map<String, dynamic> toJson() => _$GroupMonthlyStatsToJson(this);
}

@JsonSerializable()
class StudentPaymentStatus {
  final int studentId;
  final String studentName;
  final String parentName;
  final String parentPhoneNumber;
  final int groupId;
  final String groupName;
  final double amountDue;
  final bool hasPaid;

  const StudentPaymentStatus({
    required this.studentId,
    required this.studentName,
    required this.parentName,
    required this.parentPhoneNumber,
    required this.groupId,
    required this.groupName,
    required this.amountDue,
    required this.hasPaid,
  });

  factory StudentPaymentStatus.fromJson(Map<String, dynamic> json) =>
      _$StudentPaymentStatusFromJson(json);

  Map<String, dynamic> toJson() => _$StudentPaymentStatusToJson(this);
}

// ==================== YEARLY REPORT ====================

@JsonSerializable()
class YearlyReport {
  final int year;
  final double totalRevenue;
  final int totalPayments;
  final List<MonthlyRevenueSummary> monthlyBreakdown;
  final List<TeacherYearlyStats> teacherStats;
  final List<GroupYearlyStats> topGroups;
  final AttendanceStats attendanceStats;

  const YearlyReport({
    required this.year,
    required this.totalRevenue,
    required this.totalPayments,
    required this.monthlyBreakdown,
    required this.teacherStats,
    required this.topGroups,
    required this.attendanceStats,
  });

  factory YearlyReport.fromJson(Map<String, dynamic> json) =>
      _$YearlyReportFromJson(json);

  Map<String, dynamic> toJson() => _$YearlyReportToJson(this);
}

@JsonSerializable()
class MonthlyRevenueSummary {
  final int month;
  final String monthName;
  final double revenue;
  final int paymentCount;

  const MonthlyRevenueSummary({
    required this.month,
    required this.monthName,
    required this.revenue,
    required this.paymentCount,
  });

  factory MonthlyRevenueSummary.fromJson(Map<String, dynamic> json) =>
      _$MonthlyRevenueSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$MonthlyRevenueSummaryToJson(this);
}

@JsonSerializable()
class TeacherYearlyStats {
  final int teacherId;
  final String teacherName;
  final int groupCount;
  final int totalStudents;
  final double totalRevenue;

  const TeacherYearlyStats({
    required this.teacherId,
    required this.teacherName,
    required this.groupCount,
    required this.totalStudents,
    required this.totalRevenue,
  });

  factory TeacherYearlyStats.fromJson(Map<String, dynamic> json) =>
      _$TeacherYearlyStatsFromJson(json);

  Map<String, dynamic> toJson() => _$TeacherYearlyStatsToJson(this);
}

@JsonSerializable()
class GroupYearlyStats {
  final int groupId;
  final String groupName;
  final String teacherName;
  final double totalRevenue;
  final int totalPayments;

  const GroupYearlyStats({
    required this.groupId,
    required this.groupName,
    required this.teacherName,
    required this.totalRevenue,
    required this.totalPayments,
  });

  factory GroupYearlyStats.fromJson(Map<String, dynamic> json) =>
      _$GroupYearlyStatsFromJson(json);

  Map<String, dynamic> toJson() => _$GroupYearlyStatsToJson(this);
}

// ==================== SHARED MODELS ====================

@JsonSerializable()
class AttendanceStats {
  final int totalPresent;
  final int totalAbsent;
  final double attendanceRate;

  const AttendanceStats({
    required this.totalPresent,
    required this.totalAbsent,
    required this.attendanceRate,
  });

  factory AttendanceStats.fromJson(Map<String, dynamic> json) =>
      _$AttendanceStatsFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceStatsToJson(this);
}
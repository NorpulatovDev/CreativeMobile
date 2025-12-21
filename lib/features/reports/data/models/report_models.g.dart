// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyReport _$DailyReportFromJson(Map<String, dynamic> json) => DailyReport(
  date: DateTime.parse(json['date'] as String),
  totalStudentsPresent: (json['totalStudentsPresent'] as num).toInt(),
  totalStudentsAbsent: (json['totalStudentsAbsent'] as num).toInt(),
  totalPaymentsReceived: (json['totalPaymentsReceived'] as num).toDouble(),
  paymentCount: (json['paymentCount'] as num).toInt(),
  groupAttendances: (json['groupAttendances'] as List<dynamic>)
      .map((e) => GroupAttendanceSummary.fromJson(e as Map<String, dynamic>))
      .toList(),
  payments: (json['payments'] as List<dynamic>)
      .map((e) => PaymentSummary.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$DailyReportToJson(DailyReport instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'totalStudentsPresent': instance.totalStudentsPresent,
      'totalStudentsAbsent': instance.totalStudentsAbsent,
      'totalPaymentsReceived': instance.totalPaymentsReceived,
      'paymentCount': instance.paymentCount,
      'groupAttendances': instance.groupAttendances,
      'payments': instance.payments,
    };

GroupAttendanceSummary _$GroupAttendanceSummaryFromJson(
  Map<String, dynamic> json,
) => GroupAttendanceSummary(
  groupId: (json['groupId'] as num).toInt(),
  groupName: json['groupName'] as String,
  teacherName: json['teacherName'] as String,
  presentCount: (json['presentCount'] as num).toInt(),
  absentCount: (json['absentCount'] as num).toInt(),
  totalStudents: (json['totalStudents'] as num).toInt(),
);

Map<String, dynamic> _$GroupAttendanceSummaryToJson(
  GroupAttendanceSummary instance,
) => <String, dynamic>{
  'groupId': instance.groupId,
  'groupName': instance.groupName,
  'teacherName': instance.teacherName,
  'presentCount': instance.presentCount,
  'absentCount': instance.absentCount,
  'totalStudents': instance.totalStudents,
};

PaymentSummary _$PaymentSummaryFromJson(Map<String, dynamic> json) =>
    PaymentSummary(
      paymentId: (json['paymentId'] as num).toInt(),
      studentName: json['studentName'] as String,
      groupName: json['groupName'] as String,
      amount: (json['amount'] as num).toDouble(),
      paidForMonth: json['paidForMonth'] as String,
    );

Map<String, dynamic> _$PaymentSummaryToJson(PaymentSummary instance) =>
    <String, dynamic>{
      'paymentId': instance.paymentId,
      'studentName': instance.studentName,
      'groupName': instance.groupName,
      'amount': instance.amount,
      'paidForMonth': instance.paidForMonth,
    };

MonthlyReport _$MonthlyReportFromJson(Map<String, dynamic> json) =>
    MonthlyReport(
      year: (json['year'] as num).toInt(),
      month: (json['month'] as num).toInt(),
      monthName: json['monthName'] as String,
      totalActiveStudents: (json['totalActiveStudents'] as num).toInt(),
      totalGroups: (json['totalGroups'] as num).toInt(),
      expectedRevenue: (json['expectedRevenue'] as num).toDouble(),
      actualRevenue: (json['actualRevenue'] as num).toDouble(),
      collectionRate: (json['collectionRate'] as num).toDouble(),
      totalPayments: (json['totalPayments'] as num).toInt(),
      studentsWhoPaid: (json['studentsWhoPaid'] as num).toInt(),
      studentsWhoDidNotPay: (json['studentsWhoDidNotPay'] as num).toInt(),
      groupStats: (json['groupStats'] as List<dynamic>)
          .map((e) => GroupMonthlyStats.fromJson(e as Map<String, dynamic>))
          .toList(),
      unpaidStudents: (json['unpaidStudents'] as List<dynamic>)
          .map((e) => StudentPaymentStatus.fromJson(e as Map<String, dynamic>))
          .toList(),
      attendanceStats: AttendanceStats.fromJson(
        json['attendanceStats'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$MonthlyReportToJson(MonthlyReport instance) =>
    <String, dynamic>{
      'year': instance.year,
      'month': instance.month,
      'monthName': instance.monthName,
      'totalActiveStudents': instance.totalActiveStudents,
      'totalGroups': instance.totalGroups,
      'expectedRevenue': instance.expectedRevenue,
      'actualRevenue': instance.actualRevenue,
      'collectionRate': instance.collectionRate,
      'totalPayments': instance.totalPayments,
      'studentsWhoPaid': instance.studentsWhoPaid,
      'studentsWhoDidNotPay': instance.studentsWhoDidNotPay,
      'groupStats': instance.groupStats,
      'unpaidStudents': instance.unpaidStudents,
      'attendanceStats': instance.attendanceStats,
    };

GroupMonthlyStats _$GroupMonthlyStatsFromJson(Map<String, dynamic> json) =>
    GroupMonthlyStats(
      groupId: (json['groupId'] as num).toInt(),
      groupName: json['groupName'] as String,
      teacherName: json['teacherName'] as String,
      activeStudents: (json['activeStudents'] as num).toInt(),
      expectedRevenue: (json['expectedRevenue'] as num).toDouble(),
      actualRevenue: (json['actualRevenue'] as num).toDouble(),
      paidStudents: (json['paidStudents'] as num).toInt(),
      unpaidStudents: (json['unpaidStudents'] as num).toInt(),
      collectionRate: (json['collectionRate'] as num).toDouble(),
    );

Map<String, dynamic> _$GroupMonthlyStatsToJson(GroupMonthlyStats instance) =>
    <String, dynamic>{
      'groupId': instance.groupId,
      'groupName': instance.groupName,
      'teacherName': instance.teacherName,
      'activeStudents': instance.activeStudents,
      'expectedRevenue': instance.expectedRevenue,
      'actualRevenue': instance.actualRevenue,
      'paidStudents': instance.paidStudents,
      'unpaidStudents': instance.unpaidStudents,
      'collectionRate': instance.collectionRate,
    };

StudentPaymentStatus _$StudentPaymentStatusFromJson(
  Map<String, dynamic> json,
) => StudentPaymentStatus(
  studentId: (json['studentId'] as num).toInt(),
  studentName: json['studentName'] as String,
  parentName: json['parentName'] as String,
  parentPhoneNumber: json['parentPhoneNumber'] as String,
  groupId: (json['groupId'] as num).toInt(),
  groupName: json['groupName'] as String,
  amountDue: (json['amountDue'] as num).toDouble(),
  hasPaid: json['hasPaid'] as bool,
);

Map<String, dynamic> _$StudentPaymentStatusToJson(
  StudentPaymentStatus instance,
) => <String, dynamic>{
  'studentId': instance.studentId,
  'studentName': instance.studentName,
  'parentName': instance.parentName,
  'parentPhoneNumber': instance.parentPhoneNumber,
  'groupId': instance.groupId,
  'groupName': instance.groupName,
  'amountDue': instance.amountDue,
  'hasPaid': instance.hasPaid,
};

YearlyReport _$YearlyReportFromJson(Map<String, dynamic> json) => YearlyReport(
  year: (json['year'] as num).toInt(),
  totalRevenue: (json['totalRevenue'] as num).toDouble(),
  totalPayments: (json['totalPayments'] as num).toInt(),
  monthlyBreakdown: (json['monthlyBreakdown'] as List<dynamic>)
      .map((e) => MonthlyRevenueSummary.fromJson(e as Map<String, dynamic>))
      .toList(),
  teacherStats: (json['teacherStats'] as List<dynamic>)
      .map((e) => TeacherYearlyStats.fromJson(e as Map<String, dynamic>))
      .toList(),
  topGroups: (json['topGroups'] as List<dynamic>)
      .map((e) => GroupYearlyStats.fromJson(e as Map<String, dynamic>))
      .toList(),
  attendanceStats: AttendanceStats.fromJson(
    json['attendanceStats'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$YearlyReportToJson(YearlyReport instance) =>
    <String, dynamic>{
      'year': instance.year,
      'totalRevenue': instance.totalRevenue,
      'totalPayments': instance.totalPayments,
      'monthlyBreakdown': instance.monthlyBreakdown,
      'teacherStats': instance.teacherStats,
      'topGroups': instance.topGroups,
      'attendanceStats': instance.attendanceStats,
    };

MonthlyRevenueSummary _$MonthlyRevenueSummaryFromJson(
  Map<String, dynamic> json,
) => MonthlyRevenueSummary(
  month: (json['month'] as num).toInt(),
  monthName: json['monthName'] as String,
  revenue: (json['revenue'] as num).toDouble(),
  paymentCount: (json['paymentCount'] as num).toInt(),
);

Map<String, dynamic> _$MonthlyRevenueSummaryToJson(
  MonthlyRevenueSummary instance,
) => <String, dynamic>{
  'month': instance.month,
  'monthName': instance.monthName,
  'revenue': instance.revenue,
  'paymentCount': instance.paymentCount,
};

TeacherYearlyStats _$TeacherYearlyStatsFromJson(Map<String, dynamic> json) =>
    TeacherYearlyStats(
      teacherId: (json['teacherId'] as num).toInt(),
      teacherName: json['teacherName'] as String,
      groupCount: (json['groupCount'] as num).toInt(),
      totalStudents: (json['totalStudents'] as num).toInt(),
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
    );

Map<String, dynamic> _$TeacherYearlyStatsToJson(TeacherYearlyStats instance) =>
    <String, dynamic>{
      'teacherId': instance.teacherId,
      'teacherName': instance.teacherName,
      'groupCount': instance.groupCount,
      'totalStudents': instance.totalStudents,
      'totalRevenue': instance.totalRevenue,
    };

GroupYearlyStats _$GroupYearlyStatsFromJson(Map<String, dynamic> json) =>
    GroupYearlyStats(
      groupId: (json['groupId'] as num).toInt(),
      groupName: json['groupName'] as String,
      teacherName: json['teacherName'] as String,
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      totalPayments: (json['totalPayments'] as num).toInt(),
    );

Map<String, dynamic> _$GroupYearlyStatsToJson(GroupYearlyStats instance) =>
    <String, dynamic>{
      'groupId': instance.groupId,
      'groupName': instance.groupName,
      'teacherName': instance.teacherName,
      'totalRevenue': instance.totalRevenue,
      'totalPayments': instance.totalPayments,
    };

AttendanceStats _$AttendanceStatsFromJson(Map<String, dynamic> json) =>
    AttendanceStats(
      totalPresent: (json['totalPresent'] as num).toInt(),
      totalAbsent: (json['totalAbsent'] as num).toInt(),
      attendanceRate: (json['attendanceRate'] as num).toDouble(),
    );

Map<String, dynamic> _$AttendanceStatsToJson(AttendanceStats instance) =>
    <String, dynamic>{
      'totalPresent': instance.totalPresent,
      'totalAbsent': instance.totalAbsent,
      'attendanceRate': instance.attendanceRate,
    };

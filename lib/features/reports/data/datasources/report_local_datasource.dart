import 'package:hive_ce/hive.dart';

import '../../../../core/offline/hive_helpers.dart';
import '../models/report_models.dart';

class ReportLocalDataSource {
  static const String _boxName = 'reports';
  late Box _box;

  Future<void> initialize() async {
    _box = await Hive.openBox(_boxName);
  }

  String _dailyKey(int year, int month, int day) => 'daily_${year}_${month}_$day';
  String _monthlyKey(int year, int month) => 'monthly_${year}_$month';
  String _yearlyKey(int year) => 'yearly_$year';

  Future<void> cacheDailyReport(int year, int month, int day, DailyReport report) async {
    await _box.put(_dailyKey(year, month, day), toHiveMap(report.toJson()));
  }

  DailyReport? getDailyReport(int year, int month, int day) {
    final data = _box.get(_dailyKey(year, month, day));
    if (data == null) return null;
    return DailyReport.fromJson(fromHiveMap(data));
  }

  Future<void> cacheMonthlyReport(int year, int month, MonthlyReport report) async {
    await _box.put(_monthlyKey(year, month), toHiveMap(report.toJson()));
  }

  MonthlyReport? getMonthlyReport(int year, int month) {
    final data = _box.get(_monthlyKey(year, month));
    if (data == null) return null;
    return MonthlyReport.fromJson(fromHiveMap(data));
  }

  Future<void> cacheYearlyReport(int year, YearlyReport report) async {
    await _box.put(_yearlyKey(year), toHiveMap(report.toJson()));
  }

  YearlyReport? getYearlyReport(int year) {
    final data = _box.get(_yearlyKey(year));
    if (data == null) return null;
    return YearlyReport.fromJson(fromHiveMap(data));
  }
}

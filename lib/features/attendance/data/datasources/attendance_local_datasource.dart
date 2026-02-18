import 'package:hive_ce/hive.dart';
import 'package:intl/intl.dart';

import '../../../../core/offline/hive_helpers.dart';
import '../models/attendance_model.dart';

class AttendanceLocalDataSource {
  static const String _boxName = 'attendance';
  late Box _box;
  final _dateFormat = DateFormat('yyyy-MM-dd');

  Future<void> initialize() async {
    _box = await Hive.openBox(_boxName);
  }

  Future<void> cacheAll(List<AttendanceModel> attendances) async {
    for (final attendance in attendances) {
      await _box.put(attendance.id.toString(), toHiveMap(attendance.toJson()));
    }
  }

  Future<void> cacheSingle(AttendanceModel attendance) async {
    await _box.put(attendance.id.toString(), toHiveMap(attendance.toJson()));
  }

  List<AttendanceModel> _allRecords() {
    return _box.values
        .map((v) => AttendanceModel.fromJson(fromHiveMap(v)))
        .toList();
  }

  AttendanceModel? getById(int id) {
    final data = _box.get(id.toString());
    if (data == null) return null;
    return AttendanceModel.fromJson(fromHiveMap(data));
  }

  List<AttendanceModel> getByGroupAndDate(int groupId, DateTime date) {
    final dateStr = _dateFormat.format(date);
    return _allRecords()
        .where((a) =>
            a.groupId == groupId && _dateFormat.format(a.date) == dateStr)
        .toList();
  }

  List<AttendanceModel> getByMonth(int year, int month) {
    return _allRecords()
        .where((a) => a.date.year == year && a.date.month == month)
        .toList();
  }

  List<AttendanceModel> getByGroupIdAndMonth(
      int groupId, int year, int month) {
    return _allRecords()
        .where((a) =>
            a.groupId == groupId &&
            a.date.year == year &&
            a.date.month == month)
        .toList();
  }

  List<AttendanceModel> getByStudentIdAndMonth(
      int studentId, int year, int month) {
    return _allRecords()
        .where((a) =>
            a.studentId == studentId &&
            a.date.year == year &&
            a.date.month == month)
        .toList();
  }

  List<AttendanceModel> getByStudentIdAndGroupIdAndMonth(
      int studentId, int groupId, int year, int month) {
    return _allRecords()
        .where((a) =>
            a.studentId == studentId &&
            a.groupId == groupId &&
            a.date.year == year &&
            a.date.month == month)
        .toList();
  }

  Future<void> remove(int id) async {
    await _box.delete(id.toString());
  }
}

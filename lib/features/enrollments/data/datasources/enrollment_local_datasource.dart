import 'package:hive_ce/hive.dart';

import '../../../../core/offline/hive_helpers.dart';
import '../models/enrollment_model.dart';

class EnrollmentLocalDataSource {
  static const String _boxName = 'enrollments';
  late Box _box;

  Future<void> initialize() async {
    _box = await Hive.openBox(_boxName);
  }

  Future<void> cacheAll(List<EnrollmentModel> enrollments) async {
    for (final enrollment in enrollments) {
      await _box.put(enrollment.id.toString(), toHiveMap(enrollment.toJson()));
    }
  }

  Future<void> cacheSingle(EnrollmentModel enrollment) async {
    await _box.put(enrollment.id.toString(), toHiveMap(enrollment.toJson()));
  }

  List<EnrollmentModel> getStudentGroups(int studentId) {
    return _box.values
        .map((v) => EnrollmentModel.fromJson(fromHiveMap(v)))
        .where((e) => e.studentId == studentId)
        .toList();
  }

  List<EnrollmentModel> getGroupStudents(int groupId) {
    return _box.values
        .map((v) => EnrollmentModel.fromJson(fromHiveMap(v)))
        .where((e) => e.groupId == groupId)
        .toList();
  }

  Future<void> remove(int id) async {
    await _box.delete(id.toString());
  }

  Future<void> removeByStudentAndGroup(int studentId, int groupId) async {
    final keysToRemove = <dynamic>[];
    for (final key in _box.keys) {
      final data = _box.get(key);
      if (data != null) {
        final map = fromHiveMap(data);
        if (map['studentId'] == studentId && map['groupId'] == groupId) {
          keysToRemove.add(key);
        }
      }
    }
    for (final key in keysToRemove) {
      await _box.delete(key);
    }
  }
}

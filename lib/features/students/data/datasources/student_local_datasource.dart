import 'package:hive_ce/hive.dart';

import '../../../../core/offline/hive_helpers.dart';
import '../models/student_model.dart';

class StudentLocalDataSource {
  static const String _boxName = 'students';
  late Box _box;

  Future<void> initialize() async {
    _box = await Hive.openBox(_boxName);
  }

  Future<void> cacheAll(List<StudentModel> students) async {
    await _box.clear();
    for (final student in students) {
      await _box.put(student.id.toString(), toHiveMap(student.toJson()));
    }
  }

  Future<void> cacheSingle(StudentModel student) async {
    await _box.put(student.id.toString(), toHiveMap(student.toJson()));
  }

  List<StudentModel> getAll() {
    return _box.values
        .map((v) => StudentModel.fromJson(fromHiveMap(v)))
        .toList();
  }

  StudentModel? getById(int id) {
    final data = _box.get(id.toString());
    if (data == null) return null;
    return StudentModel.fromJson(fromHiveMap(data));
  }

  List<StudentModel> getByGroupId(int groupId) {
    return getAll()
        .where((s) => s.activeGroups.any((g) => g.groupId == groupId))
        .toList();
  }

  Future<void> remove(int id) async {
    await _box.delete(id.toString());
  }
}

import 'package:hive_ce/hive.dart';

import '../../../../core/offline/hive_helpers.dart';
import '../models/teacher_model.dart';

class TeacherLocalDataSource {
  static const String _boxName = 'teachers';
  late Box _box;

  Future<void> initialize() async {
    _box = await Hive.openBox(_boxName);
  }

  Future<void> cacheAll(List<TeacherModel> teachers) async {
    await _box.clear();
    for (final teacher in teachers) {
      await _box.put(teacher.id.toString(), toHiveMap(teacher.toJson()));
    }
  }

  Future<void> cacheSingle(TeacherModel teacher) async {
    await _box.put(teacher.id.toString(), toHiveMap(teacher.toJson()));
  }

  List<TeacherModel> getAll() {
    return _box.values
        .map((v) => TeacherModel.fromJson(fromHiveMap(v)))
        .toList();
  }

  TeacherModel? getById(int id) {
    final data = _box.get(id.toString());
    if (data == null) return null;
    return TeacherModel.fromJson(fromHiveMap(data));
  }

  Future<void> remove(int id) async {
    await _box.delete(id.toString());
  }
}

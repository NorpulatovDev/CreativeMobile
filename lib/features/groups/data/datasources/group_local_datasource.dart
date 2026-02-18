import 'package:hive_ce/hive.dart';

import '../../../../core/offline/hive_helpers.dart';
import '../models/group_model.dart';

class GroupLocalDataSource {
  static const String _boxName = 'groups';
  late Box _box;

  Future<void> initialize() async {
    _box = await Hive.openBox(_boxName);
  }

  Future<void> cacheAll(List<GroupModel> groups) async {
    await _box.clear();
    for (final group in groups) {
      await _box.put(group.id.toString(), toHiveMap(group.toJson()));
    }
  }

  Future<void> cacheSingle(GroupModel group) async {
    await _box.put(group.id.toString(), toHiveMap(group.toJson()));
  }

  List<GroupModel> getAll() {
    return _box.values
        .map((v) => GroupModel.fromJson(fromHiveMap(v)))
        .toList();
  }

  GroupModel? getById(int id) {
    final data = _box.get(id.toString());
    if (data == null) return null;
    return GroupModel.fromJson(fromHiveMap(data));
  }

  List<GroupModel> getByTeacherId(int teacherId) {
    return getAll().where((g) => g.teacherId == teacherId).toList();
  }

  Future<void> remove(int id) async {
    await _box.delete(id.toString());
  }
}

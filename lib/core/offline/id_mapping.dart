import 'package:hive_ce/hive.dart';

class IdMappingService {
  static const String _boxName = 'id_mappings';
  late Box<int> _box;

  Future<void> initialize() async {
    _box = await Hive.openBox<int>(_boxName);
  }

  String _key(String entityType, int tempId) => '${entityType}_$tempId';

  Future<void> addMapping(String entityType, int tempId, int realId) async {
    await _box.put(_key(entityType, tempId), realId);
  }

  int? getRealId(String entityType, int tempId) {
    return _box.get(_key(entityType, tempId));
  }

  /// Resolves an ID: if it's a temp ID (negative), looks up the real ID.
  /// Returns the original ID if it's already a real ID (positive).
  int resolveId(String entityType, int id) {
    if (id >= 0) return id;
    return getRealId(entityType, id) ?? id;
  }

  Future<void> clear() async {
    await _box.clear();
  }
}

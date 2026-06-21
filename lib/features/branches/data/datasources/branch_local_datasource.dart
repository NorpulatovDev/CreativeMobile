import 'package:hive_ce/hive.dart';

import '../../../../core/offline/hive_helpers.dart';
import '../models/branch_model.dart';

class BranchLocalDataSource {
  static const String _boxName = 'branches';
  late Box _box;

  Future<void> initialize() async {
    _box = await Hive.openBox(_boxName);
  }

  Future<void> cacheAll(List<BranchModel> branches) async {
    await _box.clear();
    for (final branch in branches) {
      await _box.put(branch.id.toString(), toHiveMap(branch.toJson()));
    }
  }

  Future<void> cacheSingle(BranchModel branch) async {
    await _box.put(branch.id.toString(), toHiveMap(branch.toJson()));
  }

  List<BranchModel> getAll() {
    return _box.values
        .map((v) => BranchModel.fromJson(fromHiveMap(v)))
        .toList();
  }

  Future<void> remove(int id) async {
    await _box.delete(id.toString());
  }
}

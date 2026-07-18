import 'package:hive_ce/hive.dart';

import '../../../../core/offline/hive_helpers.dart';
import '../models/sms_log_model.dart';

/// On-device SMS history (Hive). Kept local only — the backend outbox is for
/// orchestration; this is the admin's own record of what the SIM sent.
class SmsLogLocalDataSource {
  static const String _boxName = 'sms_log';

  /// Cap so the log can't grow unbounded on the device; oldest are dropped.
  static const int _maxEntries = 1000;

  late Box _box;

  Future<void> initialize() async {
    _box = await Hive.openBox(_boxName);
  }

  Future<void> add(SmsLogModel entry) async {
    await _box.add(toHiveMap(entry.toJson()));
    while (_box.length > _maxEntries) {
      await _box.deleteAt(0); // drop the oldest
    }
  }

  /// All entries, newest first.
  List<SmsLogModel> getAll() {
    final list = _box.values
        .map((v) => SmsLogModel.fromJson(fromHiveMap(v)))
        .toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  int get count => _box.length;

  Future<void> clear() async {
    await _box.clear();
  }
}

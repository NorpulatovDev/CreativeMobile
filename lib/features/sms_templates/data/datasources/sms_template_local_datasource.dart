import 'package:hive_ce/hive.dart';

import '../../../../core/offline/hive_helpers.dart';
import '../models/sms_template_model.dart';

class SmsTemplateLocalDataSource {
  static const String _boxName = 'sms_templates';
  late Box _box;

  Future<void> initialize() async {
    _box = await Hive.openBox(_boxName);
  }

  Future<void> cacheAll(List<SmsTemplateModel> templates) async {
    await _box.clear();
    for (final t in templates) {
      await _box.put(t.type, toHiveMap(t.toJson()));
    }
  }

  Future<void> cacheSingle(SmsTemplateModel template) async {
    await _box.put(template.type, toHiveMap(template.toJson()));
  }

  SmsTemplateModel? get(String type) {
    final v = _box.get(type);
    return v == null ? null : SmsTemplateModel.fromJson(fromHiveMap(v));
  }
}

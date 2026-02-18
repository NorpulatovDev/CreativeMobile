import 'package:hive_ce/hive.dart';

import '../../../../core/offline/hive_helpers.dart';
import '../models/inquiry_model.dart';

class InquiryLocalDataSource {
  static const String _boxName = 'inquiries';
  late Box _box;

  Future<void> initialize() async {
    _box = await Hive.openBox(_boxName);
  }

  Future<void> cacheAll(List<InquiryModel> inquiries) async {
    await _box.clear();
    for (final inquiry in inquiries) {
      await _box.put(inquiry.id.toString(), toHiveMap(inquiry.toJson()));
    }
  }

  Future<void> cacheSingle(InquiryModel inquiry) async {
    await _box.put(inquiry.id.toString(), toHiveMap(inquiry.toJson()));
  }

  List<InquiryModel> getAll() {
    return _box.values
        .map((v) => InquiryModel.fromJson(fromHiveMap(v)))
        .toList();
  }

  List<InquiryModel> getByStatus(String status) {
    return getAll().where((i) =>
        _statusToString(i.status) == status).toList();
  }

  InquiryModel? getById(int id) {
    final data = _box.get(id.toString());
    if (data == null) return null;
    return InquiryModel.fromJson(fromHiveMap(data));
  }

  Future<void> remove(int id) async {
    await _box.delete(id.toString());
  }

  String _statusToString(InquiryStatus status) {
    switch (status) {
      case InquiryStatus.newInquiry:
        return 'NEW';
      case InquiryStatus.contacted:
        return 'CONTACTED';
      case InquiryStatus.enrolled:
        return 'ENROLLED';
      case InquiryStatus.rejected:
        return 'REJECTED';
    }
  }
}

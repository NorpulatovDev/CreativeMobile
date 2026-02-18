import 'package:hive_ce/hive.dart';

import '../../../../core/offline/hive_helpers.dart';
import '../models/payment_model.dart';

class PaymentLocalDataSource {
  static const String _boxName = 'payments';
  late Box _box;

  Future<void> initialize() async {
    _box = await Hive.openBox(_boxName);
  }

  Future<void> cacheAll(List<PaymentModel> payments) async {
    await _box.clear();
    for (final payment in payments) {
      await _box.put(payment.id.toString(), toHiveMap(payment.toJson()));
    }
  }

  Future<void> cacheSingle(PaymentModel payment) async {
    await _box.put(payment.id.toString(), toHiveMap(payment.toJson()));
  }

  List<PaymentModel> getAll() {
    return _box.values
        .map((v) => PaymentModel.fromJson(fromHiveMap(v)))
        .toList();
  }

  PaymentModel? getById(int id) {
    final data = _box.get(id.toString());
    if (data == null) return null;
    return PaymentModel.fromJson(fromHiveMap(data));
  }

  List<PaymentModel> getByStudentId(int studentId) {
    return getAll().where((p) => p.studentId == studentId).toList();
  }

  List<PaymentModel> getByGroupId(int groupId) {
    return getAll().where((p) => p.groupId == groupId).toList();
  }

  List<PaymentModel> getByGroupIdAndMonth(int groupId, int year, int month) {
    final monthStr = '$year-${month.toString().padLeft(2, '0')}';
    return getAll()
        .where((p) => p.groupId == groupId && p.paidForMonth == monthStr)
        .toList();
  }

  Future<void> remove(int id) async {
    await _box.delete(id.toString());
  }
}

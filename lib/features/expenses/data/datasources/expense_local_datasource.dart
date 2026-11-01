import 'package:hive_ce/hive.dart';

import '../../../../core/offline/hive_helpers.dart';
import '../models/expense_models.dart';

class ExpenseLocalDataSource {
  static const String _boxName = 'expenses_cache';
  late Box _box;

  Future<void> initialize() async {
    _box = await Hive.openBox(_boxName);
  }

  // Categories caching
  static const String _categoriesKey = 'cached_expense_categories';

  Future<void> cacheCategories(List<ExpenseCategoryModel> categories) async {
    final list = categories.map((c) => toHiveMap(c.toJson())).toList();
    await _box.put(_categoriesKey, list);
  }

  List<ExpenseCategoryModel>? getCachedCategories() {
    final raw = _box.get(_categoriesKey);
    if (raw == null) return null;
    final list = (raw as List<dynamic>)
        .map((e) => ExpenseCategoryModel.fromJson(fromHiveMap(e)))
        .toList();
    return list;
  }

  // Expenses caching by period key
  String _expenseListKey(String period, String dateKey) =>
      'expenses_${period}_$dateKey';
  String _summaryKey(String period, String dateKey) =>
      'summary_${period}_$dateKey';

  Future<void> cacheExpenses(
    String period,
    String dateKey,
    List<ExpenseModel> expenses,
  ) async {
    final list = expenses.map((e) => toHiveMap(e.toJson())).toList();
    await _box.put(_expenseListKey(period, dateKey), list);
  }

  List<ExpenseModel>? getCachedExpenses(String period, String dateKey) {
    final raw = _box.get(_expenseListKey(period, dateKey));
    if (raw == null) return null;
    final list = (raw as List<dynamic>)
        .map((e) => ExpenseModel.fromJson(fromHiveMap(e)))
        .toList();
    return list;
  }

  Future<void> cacheSummary(
    String period,
    String dateKey,
    ExpenseSummaryModel summary,
  ) async {
    await _box.put(_summaryKey(period, dateKey), toHiveMap(summary.toJson()));
  }

  ExpenseSummaryModel? getCachedSummary(String period, String dateKey) {
    final raw = _box.get(_summaryKey(period, dateKey));
    if (raw == null) return null;
    return ExpenseSummaryModel.fromJson(fromHiveMap(raw));
  }
}


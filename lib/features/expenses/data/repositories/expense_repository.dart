import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/connectivity_service.dart';
import '../datasources/expense_local_datasource.dart';
import '../datasources/expense_remote_datasource.dart';
import '../models/expense_models.dart';

abstract class ExpenseRepository {
  Future<(List<ExpenseCategoryModel>?, Failure?)> getCategories();
  Future<(ExpenseCategoryModel?, Failure?)> createCategory(ExpenseCategoryRequest request);
  Future<(ExpenseCategoryModel?, Failure?)> updateCategory(int id, ExpenseCategoryRequest request);
  Future<Failure?> deleteCategory(int id);

  Future<(List<ExpenseModel>?, Failure?)> getExpenses({
    required String period,
    DateTime? date,
    DateTime? startDate,
    DateTime? endDate,
    int? year,
    int? month,
  });

  Future<(ExpenseSummaryModel?, Failure?)> getSummary({
    required String period,
    DateTime? date,
    DateTime? startDate,
    DateTime? endDate,
    int? year,
    int? month,
  });

  Future<(ExpenseModel?, Failure?)> createExpense(ExpenseRequest request);
  Future<(ExpenseModel?, Failure?)> updateExpense(int id, ExpenseRequest request);
  Future<Failure?> deleteExpense(int id);
}

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseRemoteDataSource _remoteDataSource;
  final ExpenseLocalDataSource _localDataSource;
  final ConnectivityService _connectivity;

  ExpenseRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._connectivity,
  );

  String _dateKey(DateTime? date, int? year, int? month) {
    if (date != null) return date.toIso8601String().split('T').first;
    if (year != null && month != null) return '$year-$month';
    final now = DateTime.now();
    return '${now.year}-${now.month}';
  }

  @override
  Future<(List<ExpenseCategoryModel>?, Failure?)> getCategories() async {
    if (_connectivity.isOnline) {
      try {
        final categories = await _remoteDataSource.getCategories();
        await _localDataSource.cacheCategories(categories);
        return (categories, null);
      } on DioException catch (e) {
        final cached = _localDataSource.getCachedCategories();
        if (cached != null) return (cached, null);
        return (null, ServerFailure(e.response?.data?['message'] ?? e.message ?? 'Kategoriyalarni yuklab bo\'lmadi'));
      } catch (e) {
        final cached = _localDataSource.getCachedCategories();
        if (cached != null) return (cached, null);
        return (null, UnknownFailure(e.toString()));
      }
    } else {
      final cached = _localDataSource.getCachedCategories();
      if (cached != null) return (cached, null);
      return (null, const CacheFailure('Oflayn rejimda saqlangan kategoriyalar topilmadi'));
    }
  }

  @override
  Future<(ExpenseCategoryModel?, Failure?)> createCategory(ExpenseCategoryRequest request) async {
    if (!_connectivity.isOnline) {
      return (null, const NetworkFailure('Kategoriya yaratish uchun internet aloqasi zarur'));
    }
    try {
      final category = await _remoteDataSource.createCategory(request);
      return (category, null);
    } on DioException catch (e) {
      return (null, ServerFailure(e.response?.data?['message'] ?? e.message ?? 'Kategoriya yaratishda xatolik'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(ExpenseCategoryModel?, Failure?)> updateCategory(int id, ExpenseCategoryRequest request) async {
    if (!_connectivity.isOnline) {
      return (null, const NetworkFailure('Kategoriyani yangilash uchun internet aloqasi zarur'));
    }
    try {
      final category = await _remoteDataSource.updateCategory(id, request);
      return (category, null);
    } on DioException catch (e) {
      return (null, ServerFailure(e.response?.data?['message'] ?? e.message ?? 'Kategoriyani yangilashda xatolik'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Failure?> deleteCategory(int id) async {
    if (!_connectivity.isOnline) {
      return const NetworkFailure('Kategoriyani o\'chirish uchun internet aloqasi zarur');
    }
    try {
      await _remoteDataSource.deleteCategory(id);
      return null;
    } on DioException catch (e) {
      return ServerFailure(e.response?.data?['message'] ?? e.message ?? 'Kategoriyani o\'chirishda xatolik');
    } catch (e) {
      return UnknownFailure(e.toString());
    }
  }

  @override
  Future<(List<ExpenseModel>?, Failure?)> getExpenses({
    required String period,
    DateTime? date,
    DateTime? startDate,
    DateTime? endDate,
    int? year,
    int? month,
  }) async {
    final dKey = _dateKey(date, year, month);
    if (_connectivity.isOnline) {
      try {
        final expenses = await _remoteDataSource.getExpenses(
          period: period,
          date: date,
          startDate: startDate,
          endDate: endDate,
          year: year,
          month: month,
        );
        await _localDataSource.cacheExpenses(period, dKey, expenses);
        return (expenses, null);
      } on DioException catch (e) {
        final cached = _localDataSource.getCachedExpenses(period, dKey);
        if (cached != null) return (cached, null);
        return (null, ServerFailure(e.response?.data?['message'] ?? e.message ?? 'Xarajatlarni yuklab bo\'lmadi'));
      } catch (e) {
        final cached = _localDataSource.getCachedExpenses(period, dKey);
        if (cached != null) return (cached, null);
        return (null, UnknownFailure(e.toString()));
      }
    } else {
      final cached = _localDataSource.getCachedExpenses(period, dKey);
      if (cached != null) return (cached, null);
      return (null, const CacheFailure('Oflayn rejimda saqlangan xarajatlar topilmadi'));
    }
  }

  @override
  Future<(ExpenseSummaryModel?, Failure?)> getSummary({
    required String period,
    DateTime? date,
    DateTime? startDate,
    DateTime? endDate,
    int? year,
    int? month,
  }) async {
    final dKey = _dateKey(date, year, month);
    if (_connectivity.isOnline) {
      try {
        final summary = await _remoteDataSource.getSummary(
          period: period,
          date: date,
          startDate: startDate,
          endDate: endDate,
          year: year,
          month: month,
        );
        await _localDataSource.cacheSummary(period, dKey, summary);
        return (summary, null);
      } on DioException catch (e) {
        final cached = _localDataSource.getCachedSummary(period, dKey);
        if (cached != null) return (cached, null);
        return (null, ServerFailure(e.response?.data?['message'] ?? e.message ?? 'Hisobot statistikasini yuklab bo\'lmadi'));
      } catch (e) {
        final cached = _localDataSource.getCachedSummary(period, dKey);
        if (cached != null) return (cached, null);
        return (null, UnknownFailure(e.toString()));
      }
    } else {
      final cached = _localDataSource.getCachedSummary(period, dKey);
      if (cached != null) return (cached, null);
      return (null, const CacheFailure('Oflayn rejimda hisobot ma\'lumoti topilmadi'));
    }
  }

  @override
  Future<(ExpenseModel?, Failure?)> createExpense(ExpenseRequest request) async {
    if (!_connectivity.isOnline) {
      return (null, const NetworkFailure('Xarajat kiritish uchun internet aloqasi zarur'));
    }
    try {
      final expense = await _remoteDataSource.createExpense(request);
      return (expense, null);
    } on DioException catch (e) {
      return (null, ServerFailure(e.response?.data?['message'] ?? e.message ?? 'Xarajat qo\'shishda xatolik'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(ExpenseModel?, Failure?)> updateExpense(int id, ExpenseRequest request) async {
    if (!_connectivity.isOnline) {
      return (null, const NetworkFailure('Xarajatni tahrirlash uchun internet aloqasi zarur'));
    }
    try {
      final expense = await _remoteDataSource.updateExpense(id, request);
      return (expense, null);
    } on DioException catch (e) {
      return (null, ServerFailure(e.response?.data?['message'] ?? e.message ?? 'Xarajatni tahrirlashda xatolik'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Failure?> deleteExpense(int id) async {
    if (!_connectivity.isOnline) {
      return const NetworkFailure('Xarajatni o\'chirish uchun internet aloqasi zarur');
    }
    try {
      await _remoteDataSource.deleteExpense(id);
      return null;
    } on DioException catch (e) {
      return ServerFailure(e.response?.data?['message'] ?? e.message ?? 'Xarajatni o\'chirishda xatolik');
    } catch (e) {
      return UnknownFailure(e.toString());
    }
  }
}


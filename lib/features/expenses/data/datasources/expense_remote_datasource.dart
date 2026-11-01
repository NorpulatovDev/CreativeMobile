import '../../../../core/api/api_client.dart';
import '../models/expense_models.dart';

abstract class ExpenseRemoteDataSource {
  Future<List<ExpenseCategoryModel>> getCategories();
  Future<ExpenseCategoryModel> createCategory(ExpenseCategoryRequest request);
  Future<ExpenseCategoryModel> updateCategory(int id, ExpenseCategoryRequest request);
  Future<void> deleteCategory(int id);

  Future<List<ExpenseModel>> getExpenses({
    required String period,
    DateTime? date,
    DateTime? startDate,
    DateTime? endDate,
    int? year,
    int? month,
  });

  Future<ExpenseSummaryModel> getSummary({
    required String period,
    DateTime? date,
    DateTime? startDate,
    DateTime? endDate,
    int? year,
    int? month,
  });

  Future<ExpenseModel> createExpense(ExpenseRequest request);
  Future<ExpenseModel> updateExpense(int id, ExpenseRequest request);
  Future<void> deleteExpense(int id);
}

class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  final ApiClient _apiClient;

  ExpenseRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<ExpenseCategoryModel>> getCategories() async {
    final response = await _apiClient.get<List<dynamic>>('/api/expense-categories');
    return (response.data ?? [])
        .map((json) => ExpenseCategoryModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ExpenseCategoryModel> createCategory(ExpenseCategoryRequest request) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/api/expense-categories',
      data: request.toJson(),
    );
    return ExpenseCategoryModel.fromJson(response.data!);
  }

  @override
  Future<ExpenseCategoryModel> updateCategory(int id, ExpenseCategoryRequest request) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/api/expense-categories/$id',
      data: request.toJson(),
    );
    return ExpenseCategoryModel.fromJson(response.data!);
  }

  @override
  Future<void> deleteCategory(int id) async {
    await _apiClient.delete('/api/expense-categories/$id');
  }

  @override
  Future<List<ExpenseModel>> getExpenses({
    required String period,
    DateTime? date,
    DateTime? startDate,
    DateTime? endDate,
    int? year,
    int? month,
  }) async {
    final queryParams = <String, dynamic>{
      'period': period.toLowerCase(),
    };
    if (date != null) {
      queryParams['date'] = date.toIso8601String().split('T').first;
    }
    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String().split('T').first;
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toIso8601String().split('T').first;
    }
    if (year != null) queryParams['year'] = year;
    if (month != null) queryParams['month'] = month;

    final response = await _apiClient.get<List<dynamic>>(
      '/api/expenses',
      queryParameters: queryParams,
    );
    return (response.data ?? [])
        .map((json) => ExpenseModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ExpenseSummaryModel> getSummary({
    required String period,
    DateTime? date,
    DateTime? startDate,
    DateTime? endDate,
    int? year,
    int? month,
  }) async {
    final queryParams = <String, dynamic>{
      'period': period.toLowerCase(),
    };
    if (date != null) {
      queryParams['date'] = date.toIso8601String().split('T').first;
    }
    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String().split('T').first;
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toIso8601String().split('T').first;
    }
    if (year != null) queryParams['year'] = year;
    if (month != null) queryParams['month'] = month;

    final response = await _apiClient.get<Map<String, dynamic>>(
      '/api/expenses/summary',
      queryParameters: queryParams,
    );
    return ExpenseSummaryModel.fromJson(response.data!);
  }

  @override
  Future<ExpenseModel> createExpense(ExpenseRequest request) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/api/expenses',
      data: request.toJson(),
    );
    return ExpenseModel.fromJson(response.data!);
  }

  @override
  Future<ExpenseModel> updateExpense(int id, ExpenseRequest request) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/api/expenses/$id',
      data: request.toJson(),
    );
    return ExpenseModel.fromJson(response.data!);
  }

  @override
  Future<void> deleteExpense(int id) async {
    await _apiClient.delete('/api/expenses/$id');
  }
}


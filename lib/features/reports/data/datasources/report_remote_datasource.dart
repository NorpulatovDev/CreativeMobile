// lib/features/reports/data/datasources/report_remote_datasource.dart

import '../../../../core/api/api_client.dart';
import '../models/report_models.dart';

abstract class ReportRemoteDataSource {
  /// Get daily report for a specific date
  /// Endpoint: GET /api/reports/daily/{year}/{month}/{day}
  Future<DailyReport> getDailyReport(int year, int month, int day);

  /// Get monthly report for a specific month
  /// Endpoint: GET /api/reports/monthly/{year}/{month}
  Future<MonthlyReport> getMonthlyReport(int year, int month);

  /// Get yearly report for a specific year
  /// Endpoint: GET /api/reports/yearly/{year}
  Future<YearlyReport> getYearlyReport(int year);
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final ApiClient _apiClient;

  ReportRemoteDataSourceImpl(this._apiClient);

  @override
  Future<DailyReport> getDailyReport(int year, int month, int day) async {
    try {
      final response = await _apiClient.get(
        '/api/reports/daily/$year/$month/$day',
      );
      return DailyReport.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to load daily report: $e');
    }
  }

  @override
  Future<MonthlyReport> getMonthlyReport(int year, int month) async {
    try {
      final response = await _apiClient.get(
        '/api/reports/monthly/$year/$month',
      );
      return MonthlyReport.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to load monthly report: $e');
    }
  }

  @override
  Future<YearlyReport> getYearlyReport(int year) async {
    try {
      final response = await _apiClient.get(
        '/api/reports/yearly/$year',
      );
      return YearlyReport.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to load yearly report: $e');
    }
  }
}
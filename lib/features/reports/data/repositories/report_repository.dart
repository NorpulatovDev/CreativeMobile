// lib/features/reports/data/repositories/report_repository.dart

import 'package:dio/dio.dart';

import '../datasources/report_remote_datasource.dart';
import '../models/report_models.dart';

abstract class ReportRepository {
  /// Returns tuple: (DailyReport?, ErrorMessage?)
  Future<(DailyReport?, String?)> getDailyReport(int year, int month, int day);

  /// Returns tuple: (MonthlyReport?, ErrorMessage?)
  Future<(MonthlyReport?, String?)> getMonthlyReport(int year, int month);

  /// Returns tuple: (YearlyReport?, ErrorMessage?)
  Future<(YearlyReport?, String?)> getYearlyReport(int year);
}

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource _dataSource;

  ReportRepositoryImpl(this._dataSource);

  @override
  Future<(DailyReport?, String?)> getDailyReport(
    int year,
    int month,
    int day,
  ) async {
    try {
      final report = await _dataSource.getDailyReport(year, month, day);
      return (report, null);
    } on DioException catch (e) {
      final message = e.response?.data['message'] as String? ??
          e.message ??
          'Failed to load daily report';
      return (null, message);
    } catch (e) {
      return (null, 'An unexpected error occurred: $e');
    }
  }

  @override
  Future<(MonthlyReport?, String?)> getMonthlyReport(
    int year,
    int month,
  ) async {
    try {
      final report = await _dataSource.getMonthlyReport(year, month);
      return (report, null);
    } on DioException catch (e) {
      final message = e.response?.data['message'] as String? ??
          e.message ??
          'Failed to load monthly report';
      return (null, message);
    } catch (e) {
      return (null, 'An unexpected error occurred: $e');
    }
  }

  @override
  Future<(YearlyReport?, String?)> getYearlyReport(int year) async {
    try {
      final report = await _dataSource.getYearlyReport(year);
      return (report, null);
    } on DioException catch (e) {
      final message = e.response?.data['message'] as String? ??
          e.message ??
          'Failed to load yearly report';
      return (null, message);
    } catch (e) {
      return (null, 'An unexpected error occurred: $e');
    }
  }
}
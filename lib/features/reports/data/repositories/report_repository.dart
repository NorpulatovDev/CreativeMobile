// lib/features/reports/data/repositories/report_repository.dart

import 'package:dio/dio.dart';

import '../../../../core/network/connectivity_service.dart';
import '../datasources/report_local_datasource.dart';
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
  final ReportLocalDataSource _localDataSource;
  final ConnectivityService _connectivity;

  ReportRepositoryImpl(this._dataSource, this._localDataSource, this._connectivity);

  @override
  Future<(DailyReport?, String?)> getDailyReport(
    int year,
    int month,
    int day,
  ) async {
    if (_connectivity.isOnline) {
      try {
        final report = await _dataSource.getDailyReport(year, month, day);
        await _localDataSource.cacheDailyReport(year, month, day, report);
        return (report, null);
      } on DioException catch (e) {
        final cached = _localDataSource.getDailyReport(year, month, day);
        if (cached != null) return (cached, null);
        final message = e.response?.data['message'] as String? ??
            e.message ??
            'Failed to load daily report';
        return (null, message);
      } catch (e) {
        final cached = _localDataSource.getDailyReport(year, month, day);
        if (cached != null) return (cached, null);
        return (null, 'An unexpected error occurred: $e');
      }
    }
    final cached = _localDataSource.getDailyReport(year, month, day);
    if (cached != null) return (cached, null);
    return (null, 'No cached report available. Connect to the internet to load.');
  }

  @override
  Future<(MonthlyReport?, String?)> getMonthlyReport(
    int year,
    int month,
  ) async {
    if (_connectivity.isOnline) {
      try {
        final report = await _dataSource.getMonthlyReport(year, month);
        await _localDataSource.cacheMonthlyReport(year, month, report);
        return (report, null);
      } on DioException catch (e) {
        final cached = _localDataSource.getMonthlyReport(year, month);
        if (cached != null) return (cached, null);
        final message = e.response?.data['message'] as String? ??
            e.message ??
            'Failed to load monthly report';
        return (null, message);
      } catch (e) {
        final cached = _localDataSource.getMonthlyReport(year, month);
        if (cached != null) return (cached, null);
        return (null, 'An unexpected error occurred: $e');
      }
    }
    final cached = _localDataSource.getMonthlyReport(year, month);
    if (cached != null) return (cached, null);
    return (null, 'No cached report available. Connect to the internet to load.');
  }

  @override
  Future<(YearlyReport?, String?)> getYearlyReport(int year) async {
    if (_connectivity.isOnline) {
      try {
        final report = await _dataSource.getYearlyReport(year);
        await _localDataSource.cacheYearlyReport(year, report);
        return (report, null);
      } on DioException catch (e) {
        final cached = _localDataSource.getYearlyReport(year);
        if (cached != null) return (cached, null);
        final message = e.response?.data['message'] as String? ??
            e.message ??
            'Failed to load yearly report';
        return (null, message);
      } catch (e) {
        final cached = _localDataSource.getYearlyReport(year);
        if (cached != null) return (cached, null);
        return (null, 'An unexpected error occurred: $e');
      }
    }
    final cached = _localDataSource.getYearlyReport(year);
    if (cached != null) return (cached, null);
    return (null, 'No cached report available. Connect to the internet to load.');
  }
}

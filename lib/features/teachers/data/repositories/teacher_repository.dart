import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/connectivity_service.dart';
import '../datasources/teacher_local_datasource.dart';
import '../datasources/teacher_remote_datasource.dart';
import '../models/teacher_model.dart';
import '../models/teacher_monthly_report_model.dart';

abstract class TeacherRepository {
  Future<(List<TeacherModel>?, Failure?)> getAll();
  Future<(TeacherModel?, Failure?)> getById(int id);
  Future<(TeacherModel?, Failure?)> create(TeacherRequest request);
  Future<(TeacherModel?, Failure?)> update(int id, TeacherRequest request);
  Future<Failure?> delete(int id);
  Future<(TeacherMonthlyReport?, String?)> getMonthlyReport(int id, int year, int month);
}

class TeacherRepositoryImpl implements TeacherRepository {
  final TeacherRemoteDataSource _remoteDataSource;
  final TeacherLocalDataSource _localDataSource;
  final ConnectivityService _connectivity;

  TeacherRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._connectivity,
  );

  @override
  Future<(List<TeacherModel>?, Failure?)> getAll() async {
    if (_connectivity.isOnline) {
      try {
        final teachers = await _remoteDataSource.getAll();
        await _localDataSource.cacheAll(teachers);
        return (teachers, null);
      } on DioException catch (e) {
        final cached = _localDataSource.getAll();
        if (cached.isNotEmpty) return (cached, null);
        return (null, ServerFailure(e.message ?? 'Failed to load teachers'));
      } catch (e) {
        final cached = _localDataSource.getAll();
        if (cached.isNotEmpty) return (cached, null);
        return (null, UnknownFailure(e.toString()));
      }
    }
    final cached = _localDataSource.getAll();
    if (cached.isNotEmpty) return (cached, null);
    return (null, const CacheFailure('No cached teachers available'));
  }

  @override
  Future<(TeacherModel?, Failure?)> getById(int id) async {
    if (_connectivity.isOnline) {
      try {
        final teacher = await _remoteDataSource.getById(id);
        await _localDataSource.cacheSingle(teacher);
        return (teacher, null);
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          return (null, const ServerFailure('Teacher not found'));
        }
        final cached = _localDataSource.getById(id);
        if (cached != null) return (cached, null);
        return (null, ServerFailure(e.message ?? 'Failed to load teacher'));
      } catch (e) {
        final cached = _localDataSource.getById(id);
        if (cached != null) return (cached, null);
        return (null, UnknownFailure(e.toString()));
      }
    }
    final cached = _localDataSource.getById(id);
    if (cached != null) return (cached, null);
    return (null, const CacheFailure('Teacher not found in cache'));
  }

  @override
  Future<(TeacherModel?, Failure?)> create(TeacherRequest request) async {
    if (!_connectivity.isOnline) {
      return (null, const ServerFailure('O\'qituvchi qo\'shish uchun internet kerak'));
    }
    try {
      final teacher = await _remoteDataSource.create(request);
      await _localDataSource.cacheSingle(teacher);
      return (teacher, null);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] as String? ??
          e.message ??
          'O\'qituvchi qo\'shishda xatolik yuz berdi';
      return (null, ServerFailure(message));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(TeacherModel?, Failure?)> update(
      int id, TeacherRequest request) async {
    if (!_connectivity.isOnline) {
      return (null, const ServerFailure('O\'zgartirish uchun internet kerak'));
    }
    try {
      final teacher = await _remoteDataSource.update(id, request);
      await _localDataSource.cacheSingle(teacher);
      return (teacher, null);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] as String? ??
          e.message ??
          'O\'qituvchini yangilashda xatolik yuz berdi';
      return (null, ServerFailure(message));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Failure?> delete(int id) async {
    if (!_connectivity.isOnline) {
      return const ServerFailure('O\'chirish uchun internet kerak');
    }
    try {
      await _remoteDataSource.delete(id);
      await _localDataSource.remove(id);
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        return const ServerFailure('Cannot delete teacher with assigned groups');
      }
      final message = e.response?.data?['message'] as String? ??
          e.message ??
          'O\'qituvchini o\'chirishda xatolik yuz berdi';
      return ServerFailure(message);
    } catch (e) {
      return UnknownFailure(e.toString());
    }
  }

  @override
  Future<(TeacherMonthlyReport?, String?)> getMonthlyReport(int id, int year, int month) async {
    try {
      final report = await _remoteDataSource.getMonthlyReport(id, year, month);
      return (report, null);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] as String? ??
          e.message ??
          'Failed to load monthly report';
      return (null, message);
    } catch (e) {
      return (null, 'An unexpected error occurred: $e');
    }
  }
}

import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/paged_response.dart';
import '../../../../core/network/connectivity_service.dart';
import '../datasources/student_local_datasource.dart';
import '../datasources/student_remote_datasource.dart';
import '../models/student_model.dart';

abstract class StudentRepository {
  Future<(List<StudentModel>?, Failure?)> getAll();
  Future<(PagedResponse<StudentModel>?, Failure?)> search(String query, int page, int size);
  Future<(List<StudentModel>?, Failure?)> getByGroupId(int groupId,
      {int? year, int? month});
  Future<(StudentModel?, Failure?)> getById(int id);
  Future<(StudentModel?, Failure?)> create(StudentRequest request);
  Future<(StudentModel?, Failure?)> update(int id, StudentRequest request);
  Future<Failure?> delete(int id);
}

class StudentRepositoryImpl implements StudentRepository {
  final StudentRemoteDataSource _remoteDataSource;
  final StudentLocalDataSource _localDataSource;
  final ConnectivityService _connectivity;

  StudentRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._connectivity,
  );

  @override
  Future<(PagedResponse<StudentModel>?, Failure?)> search(String query, int page, int size) async {
    try {
      final result = await _remoteDataSource.search(query, page, size);
      return (result, null);
    } on DioException catch (e) {
      return (null, ServerFailure(e.message ?? 'Failed to search students'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(List<StudentModel>?, Failure?)> getAll() async {
    if (_connectivity.isOnline) {
      try {
        final students = await _remoteDataSource.getAll();
        await _localDataSource.cacheAll(students);
        return (students, null);
      } on DioException catch (e) {
        // Fall through to cache
        final cached = _localDataSource.getAll();
        if (cached.isNotEmpty) return (cached, null);
        return (null, ServerFailure(e.message ?? 'Failed to load students'));
      } catch (e) {
        final cached = _localDataSource.getAll();
        if (cached.isNotEmpty) return (cached, null);
        return (null, UnknownFailure(e.toString()));
      }
    }
    final cached = _localDataSource.getAll();
    if (cached.isNotEmpty) return (cached, null);
    return (null, const CacheFailure('No cached students available'));
  }

  @override
  Future<(List<StudentModel>?, Failure?)> getByGroupId(int groupId,
      {int? year, int? month}) async {
    if (_connectivity.isOnline) {
      try {
        final students = await _remoteDataSource.getByGroupId(groupId,
            year: year, month: month);
        // Cache individually (don't clear all)
        for (final s in students) {
          await _localDataSource.cacheSingle(s);
        }
        return (students, null);
      } on DioException catch (e) {
        final cached = _localDataSource.getByGroupId(groupId);
        if (cached.isNotEmpty) return (cached, null);
        return (null, ServerFailure(e.message ?? 'Failed to load students'));
      } catch (e) {
        final cached = _localDataSource.getByGroupId(groupId);
        if (cached.isNotEmpty) return (cached, null);
        return (null, UnknownFailure(e.toString()));
      }
    }
    final cached = _localDataSource.getByGroupId(groupId);
    if (cached.isNotEmpty) return (cached, null);
    return (null, const CacheFailure('No cached students available'));
  }

  @override
  Future<(StudentModel?, Failure?)> getById(int id) async {
    if (_connectivity.isOnline) {
      try {
        final student = await _remoteDataSource.getById(id);
        await _localDataSource.cacheSingle(student);
        return (student, null);
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          return (null, const ServerFailure('Student not found'));
        }
        final cached = _localDataSource.getById(id);
        if (cached != null) return (cached, null);
        return (null, ServerFailure(e.message ?? 'Failed to load student'));
      } catch (e) {
        final cached = _localDataSource.getById(id);
        if (cached != null) return (cached, null);
        return (null, UnknownFailure(e.toString()));
      }
    }
    final cached = _localDataSource.getById(id);
    if (cached != null) return (cached, null);
    return (null, const CacheFailure('Student not found in cache'));
  }

  @override
  Future<(StudentModel?, Failure?)> create(StudentRequest request) async {
    if (!_connectivity.isOnline) {
      return (null, const ServerFailure('O\'quvchi qo\'shish uchun internet kerak'));
    }
    try {
      final student = await _remoteDataSource.create(request);
      await _localDataSource.cacheSingle(student);
      return (student, null);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] as String? ??
          e.message ??
          'O\'quvchi qo\'shishda xatolik yuz berdi';
      return (null, ServerFailure(message));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(StudentModel?, Failure?)> update(
      int id, StudentRequest request) async {
    if (!_connectivity.isOnline) {
      return (null, const ServerFailure('O\'zgartirish uchun internet kerak'));
    }
    try {
      final student = await _remoteDataSource.update(id, request);
      await _localDataSource.cacheSingle(student);
      return (student, null);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] as String? ??
          e.message ??
          'O\'quvchini yangilashda xatolik yuz berdi';
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
      final message = e.response?.data?['message'] as String? ??
          e.message ??
          'O\'quvchini o\'chirishda xatolik yuz berdi';
      return ServerFailure(message);
    } catch (e) {
      return UnknownFailure(e.toString());
    }
  }
}

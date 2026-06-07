import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/connectivity_service.dart';
import '../datasources/group_local_datasource.dart';
import '../datasources/group_remote_datasource.dart';
import '../models/group_model.dart';

abstract class GroupRepository {
  Future<(List<GroupModel>?, Failure?)> getAll();
  Future<(List<GroupModel>?, Failure?)> getAllSortedByTeacher({int? year, int? month});
  Future<(List<GroupModel>?, Failure?)> getByTeacherId(int teacherId);
  Future<(GroupModel?, Failure?)> getById(int id);
  Future<(GroupModel?, Failure?)> create(GroupRequest request);
  Future<(GroupModel?, Failure?)> update(int id, GroupRequest request);
  Future<Failure?> delete(int id);
}

class GroupRepositoryImpl implements GroupRepository {
  final GroupRemoteDataSource _remoteDataSource;
  final GroupLocalDataSource _localDataSource;
  final ConnectivityService _connectivity;

  GroupRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._connectivity,
  );

  @override
  Future<(List<GroupModel>?, Failure?)> getAll() async {
    if (_connectivity.isOnline) {
      try {
        final groups = await _remoteDataSource.getAll();
        await _localDataSource.cacheAll(groups);
        return (groups, null);
      } on DioException catch (e) {
        final cached = _localDataSource.getAll();
        if (cached.isNotEmpty) return (cached, null);
        return (null, ServerFailure(e.message ?? 'Failed to load groups'));
      } catch (e) {
        final cached = _localDataSource.getAll();
        if (cached.isNotEmpty) return (cached, null);
        return (null, UnknownFailure(e.toString()));
      }
    }
    final cached = _localDataSource.getAll();
    if (cached.isNotEmpty) return (cached, null);
    return (null, const CacheFailure('No cached groups available'));
  }

  @override
  Future<(List<GroupModel>?, Failure?)> getAllSortedByTeacher({int? year, int? month}) async {
    if (_connectivity.isOnline) {
      try {
        final groups = await _remoteDataSource.getAllSortedByTeacher(year: year, month: month);
        await _localDataSource.cacheAll(groups);
        return (groups, null);
      } on DioException catch (e) {
        final cached = _localDataSource.getAll();
        if (cached.isNotEmpty) {
          cached.sort((a, b) => a.teacherName.compareTo(b.teacherName));
          return (cached, null);
        }
        return (null, ServerFailure(e.message ?? 'Failed to load groups'));
      } catch (e) {
        final cached = _localDataSource.getAll();
        if (cached.isNotEmpty) {
          cached.sort((a, b) => a.teacherName.compareTo(b.teacherName));
          return (cached, null);
        }
        return (null, UnknownFailure(e.toString()));
      }
    }
    final cached = _localDataSource.getAll();
    if (cached.isNotEmpty) {
      cached.sort((a, b) => a.teacherName.compareTo(b.teacherName));
      return (cached, null);
    }
    return (null, const CacheFailure('No cached groups available'));
  }

  @override
  Future<(List<GroupModel>?, Failure?)> getByTeacherId(int teacherId) async {
    if (_connectivity.isOnline) {
      try {
        final groups = await _remoteDataSource.getByTeacherId(teacherId);
        for (final g in groups) {
          await _localDataSource.cacheSingle(g);
        }
        return (groups, null);
      } on DioException catch (e) {
        final cached = _localDataSource.getByTeacherId(teacherId);
        if (cached.isNotEmpty) return (cached, null);
        return (null, ServerFailure(e.message ?? 'Failed to load groups'));
      } catch (e) {
        final cached = _localDataSource.getByTeacherId(teacherId);
        if (cached.isNotEmpty) return (cached, null);
        return (null, UnknownFailure(e.toString()));
      }
    }
    final cached = _localDataSource.getByTeacherId(teacherId);
    if (cached.isNotEmpty) return (cached, null);
    return (null, const CacheFailure('No cached groups available'));
  }

  @override
  Future<(GroupModel?, Failure?)> getById(int id) async {
    if (_connectivity.isOnline) {
      try {
        final group = await _remoteDataSource.getById(id);
        await _localDataSource.cacheSingle(group);
        return (group, null);
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          return (null, const ServerFailure('Group not found'));
        }
        final cached = _localDataSource.getById(id);
        if (cached != null) return (cached, null);
        return (null, ServerFailure(e.message ?? 'Failed to load group'));
      } catch (e) {
        final cached = _localDataSource.getById(id);
        if (cached != null) return (cached, null);
        return (null, UnknownFailure(e.toString()));
      }
    }
    final cached = _localDataSource.getById(id);
    if (cached != null) return (cached, null);
    return (null, const CacheFailure('Group not found in cache'));
  }

  @override
  Future<(GroupModel?, Failure?)> create(GroupRequest request) async {
    if (!_connectivity.isOnline) {
      return (null, const ServerFailure('Guruh qo\'shish uchun internet kerak'));
    }
    try {
      final group = await _remoteDataSource.create(request);
      await _localDataSource.cacheSingle(group);
      return (group, null);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] as String? ??
          e.message ??
          'Guruh qo\'shishda xatolik yuz berdi';
      return (null, ServerFailure(message));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(GroupModel?, Failure?)> update(int id, GroupRequest request) async {
    if (!_connectivity.isOnline) {
      return (null, const ServerFailure('O\'zgartirish uchun internet kerak'));
    }
    try {
      final group = await _remoteDataSource.update(id, request);
      await _localDataSource.cacheSingle(group);
      return (group, null);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] as String? ??
          e.message ??
          'Guruhni yangilashda xatolik yuz berdi';
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
          'Guruhni o\'chirishda xatolik yuz berdi';
      return ServerFailure(message);
    } catch (e) {
      return UnknownFailure(e.toString());
    }
  }
}

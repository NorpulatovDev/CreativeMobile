import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/offline/sync_queue.dart';
import '../../../../core/offline/temp_id_generator.dart';
import '../datasources/group_local_datasource.dart';
import '../datasources/group_remote_datasource.dart';
import '../models/group_model.dart';

abstract class GroupRepository {
  Future<(List<GroupModel>?, Failure?)> getAll();
  Future<(List<GroupModel>?, Failure?)> getAllSortedByTeacher();
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
  final SyncQueue _syncQueue;
  final TempIdGenerator _tempIdGenerator;

  GroupRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._connectivity,
    this._syncQueue,
    this._tempIdGenerator,
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
  Future<(List<GroupModel>?, Failure?)> getAllSortedByTeacher() async {
    if (_connectivity.isOnline) {
      try {
        final groups = await _remoteDataSource.getAllSortedByTeacher();
        await _localDataSource.cacheAll(groups);
        return (groups, null);
      } on DioException catch (e) {
        // Fallback: return cached groups sorted by teacherName
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
    if (_connectivity.isOnline) {
      try {
        final group = await _remoteDataSource.create(request);
        await _localDataSource.cacheSingle(group);
        return (group, null);
      } on DioException {
        return _createOffline(request);
      } catch (e) {
        return (null, UnknownFailure(e.toString()));
      }
    }
    return _createOffline(request);
  }

  Future<(GroupModel?, Failure?)> _createOffline(GroupRequest request) async {
    final tempId = _tempIdGenerator.next();
    final now = DateTime.now();
    final group = GroupModel(
      id: tempId,
      name: request.name,
      teacherId: request.teacherId,
      teacherName: '', // Unknown offline
      monthlyFee: request.monthlyFee,
      studentsCount: 0,
      totalAmountToPay: 0,
      totalPaid: 0,
      createdAt: now,
      updatedAt: now,
    );
    await _localDataSource.cacheSingle(group);
    await _syncQueue.enqueue(SyncOperation(
      id: const Uuid().v4(),
      entityType: 'group',
      operationType: 'create',
      entityId: tempId,
      payload: request.toJson(),
      createdAt: now,
    ));
    return (group, null);
  }

  @override
  Future<(GroupModel?, Failure?)> update(int id, GroupRequest request) async {
    if (_connectivity.isOnline) {
      try {
        final group = await _remoteDataSource.update(id, request);
        await _localDataSource.cacheSingle(group);
        return (group, null);
      } on DioException {
        return _updateOffline(id, request);
      } catch (e) {
        return (null, UnknownFailure(e.toString()));
      }
    }
    return _updateOffline(id, request);
  }

  Future<(GroupModel?, Failure?)> _updateOffline(
      int id, GroupRequest request) async {
    final existing = _localDataSource.getById(id);
    final now = DateTime.now();
    final updated = GroupModel(
      id: id,
      name: request.name,
      teacherId: request.teacherId,
      teacherName: existing?.teacherName ?? '',
      monthlyFee: request.monthlyFee,
      studentsCount: existing?.studentsCount ?? 0,
      totalAmountToPay: existing?.totalAmountToPay ?? 0,
      totalPaid: existing?.totalPaid ?? 0,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
    await _localDataSource.cacheSingle(updated);
    await _syncQueue.enqueue(SyncOperation(
      id: const Uuid().v4(),
      entityType: 'group',
      operationType: 'update',
      entityId: id,
      payload: request.toJson(),
      createdAt: now,
    ));
    return (updated, null);
  }

  @override
  Future<Failure?> delete(int id) async {
    if (_connectivity.isOnline) {
      try {
        await _remoteDataSource.delete(id);
        await _localDataSource.remove(id);
        return null;
      } on DioException {
        return _deleteOffline(id);
      } catch (e) {
        return UnknownFailure(e.toString());
      }
    }
    return _deleteOffline(id);
  }

  Future<Failure?> _deleteOffline(int id) async {
    await _localDataSource.remove(id);
    await _syncQueue.enqueue(SyncOperation(
      id: const Uuid().v4(),
      entityType: 'group',
      operationType: 'delete',
      entityId: id,
      payload: null,
      createdAt: DateTime.now(),
    ));
    return null;
  }
}

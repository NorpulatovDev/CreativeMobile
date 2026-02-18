import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/offline/sync_queue.dart';
import '../../../../core/offline/temp_id_generator.dart';
import '../datasources/teacher_local_datasource.dart';
import '../datasources/teacher_remote_datasource.dart';
import '../models/teacher_model.dart';

abstract class TeacherRepository {
  Future<(List<TeacherModel>?, Failure?)> getAll();
  Future<(TeacherModel?, Failure?)> getById(int id);
  Future<(TeacherModel?, Failure?)> create(TeacherRequest request);
  Future<(TeacherModel?, Failure?)> update(int id, TeacherRequest request);
  Future<Failure?> delete(int id);
}

class TeacherRepositoryImpl implements TeacherRepository {
  final TeacherRemoteDataSource _remoteDataSource;
  final TeacherLocalDataSource _localDataSource;
  final ConnectivityService _connectivity;
  final SyncQueue _syncQueue;
  final TempIdGenerator _tempIdGenerator;

  TeacherRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._connectivity,
    this._syncQueue,
    this._tempIdGenerator,
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
    if (_connectivity.isOnline) {
      try {
        final teacher = await _remoteDataSource.create(request);
        await _localDataSource.cacheSingle(teacher);
        return (teacher, null);
      } on DioException {
        return _createOffline(request);
      } catch (e) {
        return (null, UnknownFailure(e.toString()));
      }
    }
    return _createOffline(request);
  }

  Future<(TeacherModel?, Failure?)> _createOffline(
      TeacherRequest request) async {
    final tempId = _tempIdGenerator.next();
    final now = DateTime.now();
    final teacher = TeacherModel(
      id: tempId,
      fullName: request.fullName,
      phoneNumber: request.phoneNumber,
      totalIncome: 0,
      createdAt: now,
      updatedAt: now,
    );
    await _localDataSource.cacheSingle(teacher);
    await _syncQueue.enqueue(SyncOperation(
      id: const Uuid().v4(),
      entityType: 'teacher',
      operationType: 'create',
      entityId: tempId,
      payload: request.toJson(),
      createdAt: now,
    ));
    return (teacher, null);
  }

  @override
  Future<(TeacherModel?, Failure?)> update(
      int id, TeacherRequest request) async {
    if (_connectivity.isOnline) {
      try {
        final teacher = await _remoteDataSource.update(id, request);
        await _localDataSource.cacheSingle(teacher);
        return (teacher, null);
      } on DioException {
        return _updateOffline(id, request);
      } catch (e) {
        return (null, UnknownFailure(e.toString()));
      }
    }
    return _updateOffline(id, request);
  }

  Future<(TeacherModel?, Failure?)> _updateOffline(
      int id, TeacherRequest request) async {
    final existing = _localDataSource.getById(id);
    final now = DateTime.now();
    final updated = TeacherModel(
      id: id,
      fullName: request.fullName,
      phoneNumber: request.phoneNumber,
      totalIncome: existing?.totalIncome ?? 0,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
    await _localDataSource.cacheSingle(updated);
    await _syncQueue.enqueue(SyncOperation(
      id: const Uuid().v4(),
      entityType: 'teacher',
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
      } on DioException catch (e) {
        if (e.response?.statusCode == 400) {
          return const ServerFailure('Cannot delete teacher with assigned groups');
        }
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
      entityType: 'teacher',
      operationType: 'delete',
      entityId: id,
      payload: null,
      createdAt: DateTime.now(),
    ));
    return null;
  }
}

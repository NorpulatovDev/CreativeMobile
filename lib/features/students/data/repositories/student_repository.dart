import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/paged_response.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/offline/sync_queue.dart';
import '../../../../core/offline/temp_id_generator.dart';
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
  final SyncQueue _syncQueue;
  final TempIdGenerator _tempIdGenerator;

  StudentRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._connectivity,
    this._syncQueue,
    this._tempIdGenerator,
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
    if (_connectivity.isOnline) {
      try {
        final student = await _remoteDataSource.create(request);
        await _localDataSource.cacheSingle(student);
        return (student, null);
      } on DioException {
        return _createOffline(request);
      } catch (e) {
        return (null, UnknownFailure(e.toString()));
      }
    }
    return _createOffline(request);
  }

  Future<(StudentModel?, Failure?)> _createOffline(
      StudentRequest request) async {
    final tempId = _tempIdGenerator.next();
    final now = DateTime.now();
    final student = StudentModel(
      id: tempId,
      fullName: request.fullName,
      parentName: request.parentName,
      parentPhoneNumber: request.parentPhoneNumber,
      totalPaid: 0,
      activeGroups: const [],
      activeGroupsCount: 0,
      paidForCurrentMonth: false,
      groupsPaidCount: 0,
      groupsUnpaidCount: 0,
      createdAt: now,
      updatedAt: now,
    );
    await _localDataSource.cacheSingle(student);
    await _syncQueue.enqueue(SyncOperation(
      id: const Uuid().v4(),
      entityType: 'student',
      operationType: 'create',
      entityId: tempId,
      payload: request.toJson(),
      createdAt: now,
    ));
    return (student, null);
  }

  @override
  Future<(StudentModel?, Failure?)> update(
      int id, StudentRequest request) async {
    if (_connectivity.isOnline) {
      try {
        final student = await _remoteDataSource.update(id, request);
        await _localDataSource.cacheSingle(student);
        return (student, null);
      } on DioException {
        return _updateOffline(id, request);
      } catch (e) {
        return (null, UnknownFailure(e.toString()));
      }
    }
    return _updateOffline(id, request);
  }

  Future<(StudentModel?, Failure?)> _updateOffline(
      int id, StudentRequest request) async {
    // Update local cache with what we know
    final existing = _localDataSource.getById(id);
    final now = DateTime.now();
    final updated = StudentModel(
      id: id,
      fullName: request.fullName,
      parentName: request.parentName,
      parentPhoneNumber: request.parentPhoneNumber,
      totalPaid: existing?.totalPaid ?? 0,
      activeGroups: existing?.activeGroups ?? const [],
      activeGroupsCount: existing?.activeGroupsCount ?? 0,
      paidForCurrentMonth: existing?.paidForCurrentMonth ?? false,
      groupsPaidCount: existing?.groupsPaidCount ?? 0,
      groupsUnpaidCount: existing?.groupsUnpaidCount ?? 0,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
    await _localDataSource.cacheSingle(updated);
    await _syncQueue.enqueue(SyncOperation(
      id: const Uuid().v4(),
      entityType: 'student',
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
      entityType: 'student',
      operationType: 'delete',
      entityId: id,
      payload: null,
      createdAt: DateTime.now(),
    ));
    return null;
  }
}

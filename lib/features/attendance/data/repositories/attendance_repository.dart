import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/offline/sync_queue.dart';
import '../../../../core/offline/temp_id_generator.dart';
import '../datasources/attendance_local_datasource.dart';
import '../datasources/attendance_remote_datasource.dart';
import '../models/attendance_model.dart';

abstract class AttendanceRepository {
  Future<(List<AttendanceModel>?, Failure?)> createForGroup(AttendanceRequest request);
  Future<(AttendanceModel?, Failure?)> getById(int id);
  Future<(List<AttendanceModel>?, Failure?)> getByGroupAndDate(int groupId, DateTime date);
  Future<(List<AttendanceModel>?, Failure?)> getByMonth(int year, int month);
  Future<(List<AttendanceModel>?, Failure?)> getByGroupIdAndMonth(int groupId, int year, int month);
  Future<(List<AttendanceModel>?, Failure?)> getByStudentIdAndMonth(int studentId, int year, int month);
  Future<(List<AttendanceModel>?, Failure?)> getByStudentIdAndGroupIdAndMonth(int studentId, int groupId, int year, int month);
  Future<(AttendanceModel?, Failure?)> update(int id, AttendanceUpdateRequest request);
}

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource _remoteDataSource;
  final AttendanceLocalDataSource _localDataSource;
  final ConnectivityService _connectivity;
  final SyncQueue _syncQueue;
  final TempIdGenerator _tempIdGenerator;

  AttendanceRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._connectivity,
    this._syncQueue,
    this._tempIdGenerator,
  );

  @override
  Future<(List<AttendanceModel>?, Failure?)> createForGroup(
      AttendanceRequest request) async {
    if (_connectivity.isOnline) {
      try {
        final attendances = await _remoteDataSource.createForGroup(request);
        await _localDataSource.cacheAll(attendances);
        return (attendances, null);
      } on DioException catch (e) {
        final message =
            e.response?.data?['message'] ?? 'Failed to create attendance';
        // Queue for later sync
        await _syncQueue.enqueue(SyncOperation(
          id: const Uuid().v4(),
          entityType: 'attendance',
          operationType: 'create',
          entityId: _tempIdGenerator.next(),
          payload: request.toJson(),
          createdAt: DateTime.now(),
        ));
        return (null, ServerFailure(message));
      } catch (e) {
        return (null, UnknownFailure(e.toString()));
      }
    }
    // Offline: queue the operation
    await _syncQueue.enqueue(SyncOperation(
      id: const Uuid().v4(),
      entityType: 'attendance',
      operationType: 'create',
      entityId: _tempIdGenerator.next(),
      payload: request.toJson(),
      createdAt: DateTime.now(),
    ));
    return (<AttendanceModel>[], null); // Return empty list, will sync later
  }

  @override
  Future<(AttendanceModel?, Failure?)> getById(int id) async {
    if (_connectivity.isOnline) {
      try {
        final attendance = await _remoteDataSource.getById(id);
        await _localDataSource.cacheSingle(attendance);
        return (attendance, null);
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          return (null, const ServerFailure('Attendance not found'));
        }
        final cached = _localDataSource.getById(id);
        if (cached != null) return (cached, null);
        return (null, ServerFailure(e.message ?? 'Failed to load attendance'));
      } catch (e) {
        final cached = _localDataSource.getById(id);
        if (cached != null) return (cached, null);
        return (null, UnknownFailure(e.toString()));
      }
    }
    final cached = _localDataSource.getById(id);
    if (cached != null) return (cached, null);
    return (null, const CacheFailure('Attendance not found in cache'));
  }

  @override
  Future<(List<AttendanceModel>?, Failure?)> getByGroupAndDate(
      int groupId, DateTime date) async {
    if (_connectivity.isOnline) {
      try {
        final attendances =
            await _remoteDataSource.getByGroupAndDate(groupId, date);
        await _localDataSource.cacheAll(attendances);
        return (attendances, null);
      } on DioException catch (e) {
        final cached = _localDataSource.getByGroupAndDate(groupId, date);
        if (cached.isNotEmpty) return (cached, null);
        return (null, ServerFailure(e.message ?? 'Failed to load attendance'));
      } catch (e) {
        final cached = _localDataSource.getByGroupAndDate(groupId, date);
        if (cached.isNotEmpty) return (cached, null);
        return (null, UnknownFailure(e.toString()));
      }
    }
    final cached = _localDataSource.getByGroupAndDate(groupId, date);
    if (cached.isNotEmpty) return (cached, null);
    return (null, const CacheFailure('No cached attendance available'));
  }

  @override
  Future<(List<AttendanceModel>?, Failure?)> getByMonth(
      int year, int month) async {
    if (_connectivity.isOnline) {
      try {
        final attendances = await _remoteDataSource.getByMonth(year, month);
        await _localDataSource.cacheAll(attendances);
        return (attendances, null);
      } on DioException catch (e) {
        final cached = _localDataSource.getByMonth(year, month);
        if (cached.isNotEmpty) return (cached, null);
        return (null, ServerFailure(e.message ?? 'Failed to load attendance'));
      } catch (e) {
        final cached = _localDataSource.getByMonth(year, month);
        if (cached.isNotEmpty) return (cached, null);
        return (null, UnknownFailure(e.toString()));
      }
    }
    final cached = _localDataSource.getByMonth(year, month);
    if (cached.isNotEmpty) return (cached, null);
    return (null, const CacheFailure('No cached attendance available'));
  }

  @override
  Future<(List<AttendanceModel>?, Failure?)> getByGroupIdAndMonth(
      int groupId, int year, int month) async {
    if (_connectivity.isOnline) {
      try {
        final attendances =
            await _remoteDataSource.getByGroupIdAndMonth(groupId, year, month);
        await _localDataSource.cacheAll(attendances);
        return (attendances, null);
      } on DioException catch (e) {
        final cached =
            _localDataSource.getByGroupIdAndMonth(groupId, year, month);
        if (cached.isNotEmpty) return (cached, null);
        return (null, ServerFailure(e.message ?? 'Failed to load attendance'));
      } catch (e) {
        final cached =
            _localDataSource.getByGroupIdAndMonth(groupId, year, month);
        if (cached.isNotEmpty) return (cached, null);
        return (null, UnknownFailure(e.toString()));
      }
    }
    final cached =
        _localDataSource.getByGroupIdAndMonth(groupId, year, month);
    if (cached.isNotEmpty) return (cached, null);
    return (null, const CacheFailure('No cached attendance available'));
  }

  @override
  Future<(List<AttendanceModel>?, Failure?)> getByStudentIdAndMonth(
      int studentId, int year, int month) async {
    if (_connectivity.isOnline) {
      try {
        final attendances = await _remoteDataSource.getByStudentIdAndMonth(
            studentId, year, month);
        await _localDataSource.cacheAll(attendances);
        return (attendances, null);
      } on DioException catch (e) {
        final cached =
            _localDataSource.getByStudentIdAndMonth(studentId, year, month);
        if (cached.isNotEmpty) return (cached, null);
        return (null, ServerFailure(e.message ?? 'Failed to load attendance'));
      } catch (e) {
        final cached =
            _localDataSource.getByStudentIdAndMonth(studentId, year, month);
        if (cached.isNotEmpty) return (cached, null);
        return (null, UnknownFailure(e.toString()));
      }
    }
    final cached =
        _localDataSource.getByStudentIdAndMonth(studentId, year, month);
    if (cached.isNotEmpty) return (cached, null);
    return (null, const CacheFailure('No cached attendance available'));
  }

  @override
  Future<(List<AttendanceModel>?, Failure?)> getByStudentIdAndGroupIdAndMonth(
      int studentId, int groupId, int year, int month) async {
    if (_connectivity.isOnline) {
      try {
        final attendances =
            await _remoteDataSource.getByStudentIdAndGroupIdAndMonth(
                studentId, groupId, year, month);
        await _localDataSource.cacheAll(attendances);
        return (attendances, null);
      } on DioException catch (e) {
        final cached = _localDataSource.getByStudentIdAndGroupIdAndMonth(
            studentId, groupId, year, month);
        if (cached.isNotEmpty) return (cached, null);
        return (null, ServerFailure(e.message ?? 'Failed to load attendance'));
      } catch (e) {
        final cached = _localDataSource.getByStudentIdAndGroupIdAndMonth(
            studentId, groupId, year, month);
        if (cached.isNotEmpty) return (cached, null);
        return (null, UnknownFailure(e.toString()));
      }
    }
    final cached = _localDataSource.getByStudentIdAndGroupIdAndMonth(
        studentId, groupId, year, month);
    if (cached.isNotEmpty) return (cached, null);
    return (null, const CacheFailure('No cached attendance available'));
  }

  @override
  Future<(AttendanceModel?, Failure?)> update(
      int id, AttendanceUpdateRequest request) async {
    if (_connectivity.isOnline) {
      try {
        final attendance = await _remoteDataSource.update(id, request);
        await _localDataSource.cacheSingle(attendance);
        return (attendance, null);
      } on DioException {
        return _updateOffline(id, request);
      } catch (e) {
        return (null, UnknownFailure(e.toString()));
      }
    }
    return _updateOffline(id, request);
  }

  Future<(AttendanceModel?, Failure?)> _updateOffline(
      int id, AttendanceUpdateRequest request) async {
    final existing = _localDataSource.getById(id);
    if (existing != null) {
      final updated = AttendanceModel(
        id: id,
        date: existing.date,
        studentId: existing.studentId,
        studentName: existing.studentName,
        groupId: existing.groupId,
        groupName: existing.groupName,
        status: request.status,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
      );
      await _localDataSource.cacheSingle(updated);
    }
    await _syncQueue.enqueue(SyncOperation(
      id: const Uuid().v4(),
      entityType: 'attendance',
      operationType: 'update',
      entityId: id,
      payload: request.toJson(),
      createdAt: DateTime.now(),
    ));
    final cached = _localDataSource.getById(id);
    return (cached, null);
  }
}

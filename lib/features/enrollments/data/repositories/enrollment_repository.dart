import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/offline/sync_queue.dart';
import '../../../../core/offline/temp_id_generator.dart';
import '../datasources/enrollment_local_datasource.dart';
import '../datasources/enrollment_remote_datasource.dart';
import '../models/enrollment_model.dart';

abstract class EnrollmentRepository {
  Future<(EnrollmentModel?, Failure?)> addStudentToGroup(int studentId, int groupId);
  Future<Failure?> removeStudentFromGroup(int studentId, int groupId);
  Future<(List<EnrollmentModel>?, Failure?)> getStudentGroups(int studentId);
  Future<(List<EnrollmentModel>?, Failure?)> getGroupStudents(int groupId);
}

class EnrollmentRepositoryImpl implements EnrollmentRepository {
  final EnrollmentRemoteDataSource _remoteDataSource;
  final EnrollmentLocalDataSource _localDataSource;
  final ConnectivityService _connectivity;
  final SyncQueue _syncQueue;
  final TempIdGenerator _tempIdGenerator;

  EnrollmentRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._connectivity,
    this._syncQueue,
    this._tempIdGenerator,
  );

  @override
  Future<(EnrollmentModel?, Failure?)> addStudentToGroup(
      int studentId, int groupId) async {
    if (_connectivity.isOnline) {
      try {
        final enrollment = await _remoteDataSource.addStudentToGroup(
          EnrollmentRequest(studentId: studentId, groupId: groupId),
        );
        await _localDataSource.cacheSingle(enrollment);
        return (enrollment, null);
      } on DioException catch (e) {
        final message =
            e.response?.data?['message'] ?? 'Failed to enroll student';
        // If server explicitly rejects, don't queue offline
        if (e.response?.statusCode != null &&
            e.response!.statusCode! >= 400 &&
            e.response!.statusCode! < 500) {
          return (null, ServerFailure(message));
        }
        return _addOffline(studentId, groupId);
      } catch (e) {
        return (null, UnknownFailure(e.toString()));
      }
    }
    return _addOffline(studentId, groupId);
  }

  Future<(EnrollmentModel?, Failure?)> _addOffline(
      int studentId, int groupId) async {
    final tempId = _tempIdGenerator.next();
    final now = DateTime.now();
    final enrollment = EnrollmentModel(
      id: tempId,
      studentId: studentId,
      studentName: '',
      groupId: groupId,
      groupName: '',
      teacherName: '',
      monthlyFee: 0,
      active: true,
      enrolledAt: now,
    );
    await _localDataSource.cacheSingle(enrollment);
    await _syncQueue.enqueue(SyncOperation(
      id: const Uuid().v4(),
      entityType: 'enrollment',
      operationType: 'create',
      entityId: tempId,
      payload: {'studentId': studentId, 'groupId': groupId},
      createdAt: now,
    ));
    return (enrollment, null);
  }

  @override
  Future<Failure?> removeStudentFromGroup(int studentId, int groupId) async {
    if (_connectivity.isOnline) {
      try {
        await _remoteDataSource.removeStudentFromGroup(studentId, groupId);
        await _localDataSource.removeByStudentAndGroup(studentId, groupId);
        return null;
      } on DioException {
        return _removeOffline(studentId, groupId);
      } catch (e) {
        return UnknownFailure(e.toString());
      }
    }
    return _removeOffline(studentId, groupId);
  }

  Future<Failure?> _removeOffline(int studentId, int groupId) async {
    await _localDataSource.removeByStudentAndGroup(studentId, groupId);
    await _syncQueue.enqueue(SyncOperation(
      id: const Uuid().v4(),
      entityType: 'enrollment',
      operationType: 'delete',
      entityId: 0, // Not applicable for this composite key
      payload: {'studentId': studentId, 'groupId': groupId},
      createdAt: DateTime.now(),
    ));
    return null;
  }

  @override
  Future<(List<EnrollmentModel>?, Failure?)> getStudentGroups(
      int studentId) async {
    if (_connectivity.isOnline) {
      try {
        final enrollments =
            await _remoteDataSource.getStudentGroups(studentId);
        for (final e in enrollments) {
          await _localDataSource.cacheSingle(e);
        }
        return (enrollments, null);
      } on DioException catch (e) {
        final cached = _localDataSource.getStudentGroups(studentId);
        if (cached.isNotEmpty) return (cached, null);
        return (
          null,
          ServerFailure(e.message ?? 'Failed to load enrollments')
        );
      } catch (e) {
        final cached = _localDataSource.getStudentGroups(studentId);
        if (cached.isNotEmpty) return (cached, null);
        return (null, UnknownFailure(e.toString()));
      }
    }
    final cached = _localDataSource.getStudentGroups(studentId);
    if (cached.isNotEmpty) return (cached, null);
    return (null, const CacheFailure('No cached enrollments available'));
  }

  @override
  Future<(List<EnrollmentModel>?, Failure?)> getGroupStudents(
      int groupId) async {
    if (_connectivity.isOnline) {
      try {
        final enrollments = await _remoteDataSource.getGroupStudents(groupId);
        for (final e in enrollments) {
          await _localDataSource.cacheSingle(e);
        }
        return (enrollments, null);
      } on DioException catch (e) {
        final cached = _localDataSource.getGroupStudents(groupId);
        if (cached.isNotEmpty) return (cached, null);
        return (
          null,
          ServerFailure(e.message ?? 'Failed to load enrollments')
        );
      } catch (e) {
        final cached = _localDataSource.getGroupStudents(groupId);
        if (cached.isNotEmpty) return (cached, null);
        return (null, UnknownFailure(e.toString()));
      }
    }
    final cached = _localDataSource.getGroupStudents(groupId);
    if (cached.isNotEmpty) return (cached, null);
    return (null, const CacheFailure('No cached enrollments available'));
  }
}

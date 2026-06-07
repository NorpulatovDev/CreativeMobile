import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/connectivity_service.dart';
import '../datasources/enrollment_local_datasource.dart';
import '../datasources/enrollment_remote_datasource.dart';
import '../models/enrollment_model.dart';

abstract class EnrollmentRepository {
  Future<(EnrollmentModel?, Failure?)> addStudentToGroup(int studentId, int groupId);
  Future<Failure?> removeStudentFromGroup(int studentId, int groupId);
  Future<(List<EnrollmentModel>?, Failure?)> getStudentGroups(int studentId);
  Future<(List<EnrollmentModel>?, Failure?)> getGroupStudents(int groupId);
  Future<Failure?> transferStudents(List<int> studentIds, int fromGroupId, int toGroupId, {bool transferCurrentMonthPayment = false});
}

class EnrollmentRepositoryImpl implements EnrollmentRepository {
  final EnrollmentRemoteDataSource _remoteDataSource;
  final EnrollmentLocalDataSource _localDataSource;
  final ConnectivityService _connectivity;

  EnrollmentRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._connectivity,
  );

  @override
  Future<(EnrollmentModel?, Failure?)> addStudentToGroup(
      int studentId, int groupId) async {
    if (!_connectivity.isOnline) {
      return (null, const ServerFailure('Guruhga qo\'shish uchun internet kerak'));
    }
    try {
      final enrollment = await _remoteDataSource.addStudentToGroup(
        EnrollmentRequest(studentId: studentId, groupId: groupId),
      );
      await _localDataSource.cacheSingle(enrollment);
      return (enrollment, null);
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] as String? ??
          e.message ??
          'Guruhga qo\'shishda xatolik yuz berdi';
      return (null, ServerFailure(message));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Failure?> removeStudentFromGroup(int studentId, int groupId) async {
    if (!_connectivity.isOnline) {
      return const ServerFailure('Guruhdan chiqarish uchun internet kerak');
    }
    try {
      await _remoteDataSource.removeStudentFromGroup(studentId, groupId);
      await _localDataSource.removeByStudentAndGroup(studentId, groupId);
      return null;
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] as String? ??
          e.message ??
          'Guruhdan chiqarishda xatolik yuz berdi';
      return ServerFailure(message);
    } catch (e) {
      return UnknownFailure(e.toString());
    }
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
  Future<Failure?> transferStudents(
      List<int> studentIds, int fromGroupId, int toGroupId,
      {bool transferCurrentMonthPayment = false}) async {
    if (!_connectivity.isOnline) {
      return const ServerFailure('O\'tkazish uchun internet aloqasi kerak');
    }
    try {
      await _remoteDataSource.transferStudents(
        TransferRequest(
          studentIds: studentIds,
          fromGroupId: fromGroupId,
          toGroupId: toGroupId,
          transferCurrentMonthPayment: transferCurrentMonthPayment,
        ),
      );
      for (final studentId in studentIds) {
        await _localDataSource.removeByStudentAndGroup(studentId, fromGroupId);
      }
      return null;
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] as String? ??
          e.message ??
          'O\'tkazishda xatolik yuz berdi';
      return ServerFailure(message);
    } catch (e) {
      return UnknownFailure(e.toString());
    }
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

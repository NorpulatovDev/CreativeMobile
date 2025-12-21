import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
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

  AttendanceRepositoryImpl(this._remoteDataSource);

  @override
  Future<(List<AttendanceModel>?, Failure?)> createForGroup(
      AttendanceRequest request) async {
    try {
      final attendances = await _remoteDataSource.createForGroup(request);
      return (attendances, null);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Failed to create attendance';
      return (null, ServerFailure(message));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(AttendanceModel?, Failure?)> getById(int id) async {
    try {
      final attendance = await _remoteDataSource.getById(id);
      return (attendance, null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return (null, const ServerFailure('Attendance not found'));
      }
      return (null, ServerFailure(e.message ?? 'Failed to load attendance'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(List<AttendanceModel>?, Failure?)> getByGroupAndDate(
      int groupId, DateTime date) async {
    try {
      final attendances = await _remoteDataSource.getByGroupAndDate(groupId, date);
      return (attendances, null);
    } on DioException catch (e) {
      return (null, ServerFailure(e.message ?? 'Failed to load attendance'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(List<AttendanceModel>?, Failure?)> getByMonth(int year, int month) async {
    try {
      final attendances = await _remoteDataSource.getByMonth(year, month);
      return (attendances, null);
    } on DioException catch (e) {
      return (null, ServerFailure(e.message ?? 'Failed to load attendance'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(List<AttendanceModel>?, Failure?)> getByGroupIdAndMonth(
      int groupId, int year, int month) async {
    try {
      final attendances =
          await _remoteDataSource.getByGroupIdAndMonth(groupId, year, month);
      return (attendances, null);
    } on DioException catch (e) {
      return (null, ServerFailure(e.message ?? 'Failed to load attendance'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(List<AttendanceModel>?, Failure?)> getByStudentIdAndMonth(
      int studentId, int year, int month) async {
    try {
      final attendances =
          await _remoteDataSource.getByStudentIdAndMonth(studentId, year, month);
      return (attendances, null);
    } on DioException catch (e) {
      return (null, ServerFailure(e.message ?? 'Failed to load attendance'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(List<AttendanceModel>?, Failure?)> getByStudentIdAndGroupIdAndMonth(
      int studentId, int groupId, int year, int month) async {
    try {
      final attendances = await _remoteDataSource.getByStudentIdAndGroupIdAndMonth(
          studentId, groupId, year, month);
      return (attendances, null);
    } on DioException catch (e) {
      return (null, ServerFailure(e.message ?? 'Failed to load attendance'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(AttendanceModel?, Failure?)> update(
      int id, AttendanceUpdateRequest request) async {
    try {
      final attendance = await _remoteDataSource.update(id, request);
      return (attendance, null);
    } on DioException catch (e) {
      return (null, ServerFailure(e.message ?? 'Failed to update attendance'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }
}
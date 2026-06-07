import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/connectivity_service.dart';
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

  AttendanceRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._connectivity,
  );

  @override
  Future<(List<AttendanceModel>?, Failure?)> createForGroup(
      AttendanceRequest request) async {
    if (!_connectivity.isOnline) {
      return (null, const ServerFailure('Davomat belgilash uchun internet kerak'));
    }
    try {
      final attendances = await _remoteDataSource.createForGroup(request);
      await _localDataSource.cacheAll(attendances);
      return (attendances, null);
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] as String? ??
          e.message ??
          'Davomat belgilashda xatolik yuz berdi';
      return (null, ServerFailure(message));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
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
    if (!_connectivity.isOnline) {
      return (null, const ServerFailure('Davomatni yangilash uchun internet kerak'));
    }
    try {
      final attendance = await _remoteDataSource.update(id, request);
      await _localDataSource.cacheSingle(attendance);
      return (attendance, null);
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] as String? ??
          e.message ??
          'Davomatni yangilashda xatolik yuz berdi';
      return (null, ServerFailure(message));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }
}

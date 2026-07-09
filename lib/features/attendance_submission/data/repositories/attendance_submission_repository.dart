import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/connectivity_service.dart';
import '../datasources/attendance_submission_remote_datasource.dart';
import '../models/attendance_submission_model.dart';

abstract class AttendanceSubmissionRepository {
  Future<(AttendanceSubmissionModel?, Failure?)> create(
      AttendanceSubmissionRequest request);
  Future<(List<AttendanceSubmissionModel>?, Failure?)> getPending();
  Future<(List<AttendanceSubmissionModel>?, Failure?)> getMine();
  Future<(AttendanceSubmissionModel?, Failure?)> getById(int id);
  Future<(AttendanceSubmissionModel?, Failure?)> approve(int id);
  Future<(AttendanceSubmissionModel?, Failure?)> reject(int id, String? note);
}

class AttendanceSubmissionRepositoryImpl
    implements AttendanceSubmissionRepository {
  final AttendanceSubmissionRemoteDataSource _remote;
  final ConnectivityService _connectivity;

  AttendanceSubmissionRepositoryImpl(this._remote, this._connectivity);

  @override
  Future<(AttendanceSubmissionModel?, Failure?)> create(
      AttendanceSubmissionRequest request) {
    return _guard(
      () => _remote.create(request),
      offlineMessage: 'Davomat yuborish uchun internet kerak',
      errorMessage: 'Davomat yuborishda xatolik yuz berdi',
    );
  }

  @override
  Future<(List<AttendanceSubmissionModel>?, Failure?)> getPending() {
    return _guardList(
      () => _remote.getPending(),
      errorMessage: 'Tasdiqlanmagan davomatlarni yuklashda xatolik',
    );
  }

  @override
  Future<(List<AttendanceSubmissionModel>?, Failure?)> getMine() {
    return _guardList(
      () => _remote.getMine(),
      errorMessage: 'Davomatlarni yuklashda xatolik',
    );
  }

  @override
  Future<(AttendanceSubmissionModel?, Failure?)> getById(int id) {
    return _guard(
      () => _remote.getById(id),
      offlineMessage: 'Internet aloqasi yo\'q',
      errorMessage: 'Davomatni yuklashda xatolik',
    );
  }

  @override
  Future<(AttendanceSubmissionModel?, Failure?)> approve(int id) {
    return _guard(
      () => _remote.approve(id),
      offlineMessage: 'Tasdiqlash uchun internet kerak',
      errorMessage: 'Tasdiqlashda xatolik yuz berdi',
    );
  }

  @override
  Future<(AttendanceSubmissionModel?, Failure?)> reject(int id, String? note) {
    return _guard(
      () => _remote.reject(id, note),
      offlineMessage: 'Rad etish uchun internet kerak',
      errorMessage: 'Rad etishda xatolik yuz berdi',
    );
  }

  Future<(T?, Failure?)> _guard<T>(
    Future<T> Function() action, {
    required String offlineMessage,
    required String errorMessage,
  }) async {
    if (!_connectivity.isOnline) {
      return (null, ServerFailure(offlineMessage));
    }
    try {
      return (await action(), null);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] as String? ?? e.message ?? errorMessage;
      return (null, ServerFailure(message));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  Future<(List<T>?, Failure?)> _guardList<T>(
    Future<List<T>> Function() action, {
    required String errorMessage,
  }) async {
    if (!_connectivity.isOnline) {
      return (null, const ServerFailure('Internet aloqasi yo\'q'));
    }
    try {
      return (await action(), null);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] as String? ?? e.message ?? errorMessage;
      return (null, ServerFailure(message));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }
}

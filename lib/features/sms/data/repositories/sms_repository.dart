import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/connectivity_service.dart';
import '../datasources/sms_remote_datasource.dart';
import '../models/sms_message_model.dart';

abstract class SmsRepository {
  Future<(List<SmsMessageModel>?, Failure?)> getPending();
  Future<(List<SmsMessageModel>?, Failure?)> getFailed();
  Future<Failure?> retry(int id);
  Future<(int?, Failure?)> retryAll();
}

class SmsRepositoryImpl implements SmsRepository {
  final SmsRemoteDataSource _remote;
  final ConnectivityService _connectivity;

  SmsRepositoryImpl(this._remote, this._connectivity);

  @override
  Future<(List<SmsMessageModel>?, Failure?)> getPending() async {
    if (!_connectivity.isOnline) {
      return (null, const ServerFailure('Internet aloqasi yo\'q'));
    }
    try {
      return (await _remote.getPending(), null);
    } on DioException catch (e) {
      return (null, ServerFailure(e.message ?? 'Yuklashda xatolik'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(List<SmsMessageModel>?, Failure?)> getFailed() async {
    if (!_connectivity.isOnline) {
      return (null, const ServerFailure('Internet aloqasi yo\'q'));
    }
    try {
      return (await _remote.getFailed(), null);
    } on DioException catch (e) {
      return (null, ServerFailure(e.message ?? 'Yuklashda xatolik'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Failure?> retry(int id) async {
    if (!_connectivity.isOnline) {
      return const ServerFailure('Qayta yuborish uchun internet kerak');
    }
    try {
      await _remote.retry(id);
      return null;
    } on DioException catch (e) {
      return ServerFailure(
          e.response?.data?['message'] as String? ?? e.message ?? 'Xatolik');
    } catch (e) {
      return UnknownFailure(e.toString());
    }
  }

  @override
  Future<(int?, Failure?)> retryAll() async {
    if (!_connectivity.isOnline) {
      return (null, const ServerFailure('Qayta yuborish uchun internet kerak'));
    }
    try {
      return (await _remote.retryAll(), null);
    } on DioException catch (e) {
      return (null, ServerFailure(e.message ?? 'Xatolik'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }
}

import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/connectivity_service.dart';
import '../datasources/sms_remote_datasource.dart';
import '../models/sms_message_model.dart';

abstract class SmsRepository {
  Future<(List<SmsMessageModel>?, Failure?)> getPending();
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
}

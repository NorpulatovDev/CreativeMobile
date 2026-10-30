import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/services/sms_template_renderer.dart';
import '../datasources/sms_template_local_datasource.dart';
import '../datasources/sms_template_remote_datasource.dart';
import '../models/sms_template_model.dart';

abstract class SmsTemplateRepository {
  Future<(List<SmsTemplateModel>?, Failure?)> getAll();
  Future<(SmsTemplateModel?, Failure?)> update(String type, String body);
  Future<(SmsTemplateModel?, Failure?)> reset(String type);

  /// Text in effect for [type]: server, else offline cache, else built-in default.
  /// Never fails — an SMS must still go out when offline.
  Future<String> bodyFor(String type);
}

class SmsTemplateRepositoryImpl implements SmsTemplateRepository {
  final SmsTemplateRemoteDataSource _remote;
  final SmsTemplateLocalDataSource _local;
  final ConnectivityService _connectivity;

  SmsTemplateRepositoryImpl(this._remote, this._local, this._connectivity);

  @override
  Future<(List<SmsTemplateModel>?, Failure?)> getAll() async {
    try {
      final templates = await _remote.getAll();
      await _local.cacheAll(templates);
      return (templates, null);
    } on DioException catch (e) {
      return (null, ServerFailure(_message(e, 'Shablonlarni yuklashda xatolik')));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(SmsTemplateModel?, Failure?)> update(String type, String body) async {
    try {
      final template = await _remote.update(type, body);
      await _local.cacheSingle(template);
      return (template, null);
    } on DioException catch (e) {
      return (null, ServerFailure(_message(e, 'Shablonni saqlashda xatolik')));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(SmsTemplateModel?, Failure?)> reset(String type) async {
    try {
      final template = await _remote.reset(type);
      await _local.cacheSingle(template);
      return (template, null);
    } on DioException catch (e) {
      return (null, ServerFailure(_message(e, 'Shablonni tiklashda xatolik')));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<String> bodyFor(String type) async {
    if (_connectivity.isOnline) {
      final (templates, _) = await getAll();
      final fresh = templates?.where((t) => t.type == type).firstOrNull;
      if (fresh != null) return fresh.body;
    }
    return _local.get(type)?.body ?? SmsTemplateType.defaults[type] ?? '';
  }

  String _message(DioException e, String fallback) {
    final data = e.response?.data;
    return (data is Map ? data['message'] as String? : null) ?? e.message ?? fallback;
  }
}

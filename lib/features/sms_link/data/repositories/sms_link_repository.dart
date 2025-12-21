import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../datasources/sms_link_remote_datasource.dart';
import '../models/sms_link_model.dart';

abstract class SmsLinkRepository {
  Future<(List<SmsLinkResponse>?, Failure?)> linkByPhone(String phoneNumber);
  Future<(SmsLinkResponse?, Failure?)> linkByCode(String code, String phoneNumber);
  Future<(SmsLinkResponse?, Failure?)> getLinkStatus(int studentId);
}

class SmsLinkRepositoryImpl implements SmsLinkRepository {
  final SmsLinkRemoteDataSource _remoteDataSource;

  SmsLinkRepositoryImpl(this._remoteDataSource);

  @override
  Future<(List<SmsLinkResponse>?, Failure?)> linkByPhone(String phoneNumber) async {
    try {
      final responses = await _remoteDataSource.linkByPhone(
        SmsLinkByPhoneRequest(phoneNumber: phoneNumber),
      );
      return (responses, null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return (null, const ServerFailure('No students found with this phone number'));
      }
      final message = e.response?.data?['message'] ?? 'Failed to link by phone';
      return (null, ServerFailure(message));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(SmsLinkResponse?, Failure?)> linkByCode(
      String code, String phoneNumber) async {
    try {
      final response = await _remoteDataSource.linkByCode(
        SmsLinkByCodeRequest(code: code, phoneNumber: phoneNumber),
      );
      return (response, null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return (null, const ServerFailure('Invalid SMS link code'));
      }
      final message = e.response?.data?['message'] ?? 'Failed to link by code';
      return (null, ServerFailure(message));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(SmsLinkResponse?, Failure?)> getLinkStatus(int studentId) async {
    try {
      final response = await _remoteDataSource.getLinkStatus(studentId);
      return (response, null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return (null, const ServerFailure('Student not found'));
      }
      return (null, ServerFailure(e.message ?? 'Failed to get link status'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }
}
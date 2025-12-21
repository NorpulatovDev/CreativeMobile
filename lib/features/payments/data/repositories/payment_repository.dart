import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../datasources/payment_remote_datasource.dart';
import '../models/payment_model.dart';

abstract class PaymentRepository {
  Future<(List<PaymentModel>?, Failure?)> getAll();
  Future<(List<PaymentModel>?, Failure?)> getByStudentId(int studentId);
  Future<(List<PaymentModel>?, Failure?)> getByGroupId(int groupId);
  Future<(PaymentModel?, Failure?)> create(PaymentRequest request);
}

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource _remoteDataSource;

  PaymentRepositoryImpl(this._remoteDataSource);

  @override
  Future<(List<PaymentModel>?, Failure?)> getAll() async {
    try {
      final payments = await _remoteDataSource.getAll();
      return (payments, null);
    } on DioException catch (e) {
      return (null, ServerFailure(e.message ?? 'Failed to load payments'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(List<PaymentModel>?, Failure?)> getByStudentId(int studentId) async {
    try {
      final payments = await _remoteDataSource.getByStudentId(studentId);
      return (payments, null);
    } on DioException catch (e) {
      return (null, ServerFailure(e.message ?? 'Failed to load payments'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(List<PaymentModel>?, Failure?)> getByGroupId(int groupId) async {
    try {
      final payments = await _remoteDataSource.getByGroupId(groupId);
      return (payments, null);
    } on DioException catch (e) {
      return (null, ServerFailure(e.message ?? 'Failed to load payments'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(PaymentModel?, Failure?)> create(PaymentRequest request) async {
    try {
      final payment = await _remoteDataSource.create(request);
      return (payment, null);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Failed to create payment';
      return (null, ServerFailure(message));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }
}
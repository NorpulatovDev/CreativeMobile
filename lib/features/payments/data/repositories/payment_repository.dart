import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../datasources/payment_remote_datasource.dart';
import '../models/payment_model.dart';

abstract class PaymentRepository {
  Future<(List<PaymentModel>?, Failure?)> getAll();
  Future<(List<PaymentModel>?, Failure?)> getByStudentId(int studentId);
  Future<(List<PaymentModel>?, Failure?)> getByGroupId(int groupId);
  Future<(List<PaymentModel>?, Failure?)> getByGroupIdAndMonth(
      int groupId, int year, int month);
  Future<(PaymentModel?, Failure?)> getById(int id);
  Future<(PaymentModel?, Failure?)> create(PaymentRequest request);
  Future<(PaymentModel?, Failure?)> update(int id, PaymentRequest request);
  Future<Failure?> delete(int id);
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
  Future<(List<PaymentModel>?, Failure?)> getByGroupIdAndMonth(
      int groupId, int year, int month) async {
    try {
      final payments =
          await _remoteDataSource.getByGroupIdAndMonth(groupId, year, month);
      return (payments, null);
    } on DioException catch (e) {
      return (null, ServerFailure(e.message ?? 'Failed to load payments'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(PaymentModel?, Failure?)> getById(int id) async {
    try {
      final payment = await _remoteDataSource.getById(id);
      return (payment, null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return (null, const ServerFailure('Payment not found'));
      }
      return (null, ServerFailure(e.message ?? 'Failed to load payment'));
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
      return (null, ServerFailure(e.message ?? 'Failed to create payment'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(PaymentModel?, Failure?)> update(
      int id, PaymentRequest request) async {
    try {
      final payment = await _remoteDataSource.update(id, request);
      return (payment, null);
    } on DioException catch (e) {
      return (null, ServerFailure(e.message ?? 'Failed to update payment'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Failure?> delete(int id) async {
    try {
      await _remoteDataSource.delete(id);
      return null;
    } on DioException catch (e) {
      return ServerFailure(e.message ?? 'Failed to delete payment');
    } catch (e) {
      return UnknownFailure(e.toString());
    }
  }
}
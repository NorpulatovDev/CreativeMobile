import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/paged_response.dart';
import '../../../../core/network/connectivity_service.dart';
import '../datasources/payment_local_datasource.dart';
import '../datasources/payment_remote_datasource.dart';
import '../models/payment_model.dart';

abstract class PaymentRepository {
  Future<(List<PaymentModel>?, Failure?)> getAll();
  Future<(PagedResponse<PaymentModel>?, Failure?)> search(String query, int page, int size);
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
  final PaymentLocalDataSource _localDataSource;
  final ConnectivityService _connectivity;

  PaymentRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._connectivity,
  );

  @override
  Future<(PagedResponse<PaymentModel>?, Failure?)> search(String query, int page, int size) async {
    try {
      final result = await _remoteDataSource.search(query, page, size);
      return (result, null);
    } on DioException catch (e) {
      return (null, ServerFailure(e.message ?? 'Failed to search payments'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(List<PaymentModel>?, Failure?)> getAll() async {
    if (_connectivity.isOnline) {
      try {
        final payments = await _remoteDataSource.getAll();
        await _localDataSource.cacheAll(payments);
        return (payments, null);
      } on DioException catch (e) {
        final cached = _localDataSource.getAll();
        if (cached.isNotEmpty) return (cached, null);
        return (null, ServerFailure(e.message ?? 'Failed to load payments'));
      } catch (e) {
        final cached = _localDataSource.getAll();
        if (cached.isNotEmpty) return (cached, null);
        return (null, UnknownFailure(e.toString()));
      }
    }
    final cached = _localDataSource.getAll();
    if (cached.isNotEmpty) return (cached, null);
    return (null, const CacheFailure('No cached payments available'));
  }

  @override
  Future<(List<PaymentModel>?, Failure?)> getByStudentId(int studentId) async {
    if (_connectivity.isOnline) {
      try {
        final payments = await _remoteDataSource.getByStudentId(studentId);
        for (final p in payments) {
          await _localDataSource.cacheSingle(p);
        }
        return (payments, null);
      } on DioException catch (e) {
        final cached = _localDataSource.getByStudentId(studentId);
        if (cached.isNotEmpty) return (cached, null);
        return (null, ServerFailure(e.message ?? 'Failed to load payments'));
      } catch (e) {
        final cached = _localDataSource.getByStudentId(studentId);
        if (cached.isNotEmpty) return (cached, null);
        return (null, UnknownFailure(e.toString()));
      }
    }
    final cached = _localDataSource.getByStudentId(studentId);
    if (cached.isNotEmpty) return (cached, null);
    return (null, const CacheFailure('No cached payments available'));
  }

  @override
  Future<(List<PaymentModel>?, Failure?)> getByGroupId(int groupId) async {
    if (_connectivity.isOnline) {
      try {
        final payments = await _remoteDataSource.getByGroupId(groupId);
        for (final p in payments) {
          await _localDataSource.cacheSingle(p);
        }
        return (payments, null);
      } on DioException catch (e) {
        final cached = _localDataSource.getByGroupId(groupId);
        if (cached.isNotEmpty) return (cached, null);
        return (null, ServerFailure(e.message ?? 'Failed to load payments'));
      } catch (e) {
        final cached = _localDataSource.getByGroupId(groupId);
        if (cached.isNotEmpty) return (cached, null);
        return (null, UnknownFailure(e.toString()));
      }
    }
    final cached = _localDataSource.getByGroupId(groupId);
    if (cached.isNotEmpty) return (cached, null);
    return (null, const CacheFailure('No cached payments available'));
  }

  @override
  Future<(List<PaymentModel>?, Failure?)> getByGroupIdAndMonth(
      int groupId, int year, int month) async {
    if (_connectivity.isOnline) {
      try {
        final payments =
            await _remoteDataSource.getByGroupIdAndMonth(groupId, year, month);
        for (final p in payments) {
          await _localDataSource.cacheSingle(p);
        }
        return (payments, null);
      } on DioException catch (e) {
        final cached =
            _localDataSource.getByGroupIdAndMonth(groupId, year, month);
        if (cached.isNotEmpty) return (cached, null);
        return (null, ServerFailure(e.message ?? 'Failed to load payments'));
      } catch (e) {
        final cached =
            _localDataSource.getByGroupIdAndMonth(groupId, year, month);
        if (cached.isNotEmpty) return (cached, null);
        return (null, UnknownFailure(e.toString()));
      }
    }
    final cached = _localDataSource.getByGroupIdAndMonth(groupId, year, month);
    if (cached.isNotEmpty) return (cached, null);
    return (null, const CacheFailure('No cached payments available'));
  }

  @override
  Future<(PaymentModel?, Failure?)> getById(int id) async {
    if (_connectivity.isOnline) {
      try {
        final payment = await _remoteDataSource.getById(id);
        await _localDataSource.cacheSingle(payment);
        return (payment, null);
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          return (null, const ServerFailure('Payment not found'));
        }
        final cached = _localDataSource.getById(id);
        if (cached != null) return (cached, null);
        return (null, ServerFailure(e.message ?? 'Failed to load payment'));
      } catch (e) {
        final cached = _localDataSource.getById(id);
        if (cached != null) return (cached, null);
        return (null, UnknownFailure(e.toString()));
      }
    }
    final cached = _localDataSource.getById(id);
    if (cached != null) return (cached, null);
    return (null, const CacheFailure('Payment not found in cache'));
  }

  @override
  Future<(PaymentModel?, Failure?)> create(PaymentRequest request) async {
    if (!_connectivity.isOnline) {
      return (null, const ServerFailure('To\'lov qo\'shish uchun internet kerak'));
    }
    try {
      final payment = await _remoteDataSource.create(request);
      await _localDataSource.cacheSingle(payment);
      return (payment, null);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] as String? ??
          e.message ??
          'To\'lov qo\'shishda xatolik yuz berdi';
      return (null, ServerFailure(message));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(PaymentModel?, Failure?)> update(
      int id, PaymentRequest request) async {
    if (!_connectivity.isOnline) {
      return (null, const ServerFailure('To\'lovni yangilash uchun internet kerak'));
    }
    try {
      final payment = await _remoteDataSource.update(id, request);
      await _localDataSource.cacheSingle(payment);
      return (payment, null);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] as String? ??
          e.message ??
          'To\'lovni yangilashda xatolik yuz berdi';
      return (null, ServerFailure(message));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Failure?> delete(int id) async {
    if (!_connectivity.isOnline) {
      return const ServerFailure('To\'lovni o\'chirish uchun internet kerak');
    }
    try {
      await _remoteDataSource.delete(id);
      await _localDataSource.remove(id);
      return null;
    } on DioException catch (e) {
      final message = e.response?.data?['message'] as String? ??
          e.message ??
          'To\'lovni o\'chirishda xatolik yuz berdi';
      return ServerFailure(message);
    } catch (e) {
      return UnknownFailure(e.toString());
    }
  }
}

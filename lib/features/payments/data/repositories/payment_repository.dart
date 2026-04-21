import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/paged_response.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/offline/sync_queue.dart';
import '../../../../core/offline/temp_id_generator.dart';
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
  final SyncQueue _syncQueue;
  final TempIdGenerator _tempIdGenerator;

  PaymentRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._connectivity,
    this._syncQueue,
    this._tempIdGenerator,
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
    if (_connectivity.isOnline) {
      try {
        final payment = await _remoteDataSource.create(request);
        await _localDataSource.cacheSingle(payment);
        return (payment, null);
      } on DioException {
        return _createOffline(request);
      } catch (e) {
        return (null, UnknownFailure(e.toString()));
      }
    }
    return _createOffline(request);
  }

  Future<(PaymentModel?, Failure?)> _createOffline(
      PaymentRequest request) async {
    final tempId = _tempIdGenerator.next();
    final now = DateTime.now();
    final payment = PaymentModel(
      id: tempId,
      studentId: request.studentId,
      studentName: '', // Unknown offline
      groupId: request.groupId,
      groupName: '', // Unknown offline
      amount: request.amount,
      paidForMonth: request.paidForMonth,
      paidAt: now,
    );
    await _localDataSource.cacheSingle(payment);
    await _syncQueue.enqueue(SyncOperation(
      id: const Uuid().v4(),
      entityType: 'payment',
      operationType: 'create',
      entityId: tempId,
      payload: request.toJson(),
      createdAt: now,
    ));
    return (payment, null);
  }

  @override
  Future<(PaymentModel?, Failure?)> update(
      int id, PaymentRequest request) async {
    if (_connectivity.isOnline) {
      try {
        final payment = await _remoteDataSource.update(id, request);
        await _localDataSource.cacheSingle(payment);
        return (payment, null);
      } on DioException {
        return _updateOffline(id, request);
      } catch (e) {
        return (null, UnknownFailure(e.toString()));
      }
    }
    return _updateOffline(id, request);
  }

  Future<(PaymentModel?, Failure?)> _updateOffline(
      int id, PaymentRequest request) async {
    final existing = _localDataSource.getById(id);
    final now = DateTime.now();
    final updated = PaymentModel(
      id: id,
      studentId: request.studentId,
      studentName: existing?.studentName ?? '',
      groupId: request.groupId,
      groupName: existing?.groupName ?? '',
      amount: request.amount,
      paidForMonth: request.paidForMonth,
      paidAt: existing?.paidAt ?? now,
    );
    await _localDataSource.cacheSingle(updated);
    await _syncQueue.enqueue(SyncOperation(
      id: const Uuid().v4(),
      entityType: 'payment',
      operationType: 'update',
      entityId: id,
      payload: request.toJson(),
      createdAt: now,
    ));
    return (updated, null);
  }

  @override
  Future<Failure?> delete(int id) async {
    if (_connectivity.isOnline) {
      try {
        await _remoteDataSource.delete(id);
        await _localDataSource.remove(id);
        return null;
      } on DioException {
        return _deleteOffline(id);
      } catch (e) {
        return UnknownFailure(e.toString());
      }
    }
    return _deleteOffline(id);
  }

  Future<Failure?> _deleteOffline(int id) async {
    await _localDataSource.remove(id);
    await _syncQueue.enqueue(SyncOperation(
      id: const Uuid().v4(),
      entityType: 'payment',
      operationType: 'delete',
      entityId: id,
      payload: null,
      createdAt: DateTime.now(),
    ));
    return null;
  }
}

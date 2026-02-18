import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/offline/sync_queue.dart';
import '../../../../core/offline/temp_id_generator.dart';
import '../datasources/inquiry_local_datasource.dart';
import '../datasources/inquiry_remote_datasource.dart';
import '../models/inquiry_model.dart';

abstract class InquiryRepository {
  Future<(List<InquiryModel>?, Failure?)> getAll();
  Future<(List<InquiryModel>?, Failure?)> getByStatus(String status);
  Future<(InquiryModel?, Failure?)> getById(int id);
  Future<(InquiryModel?, Failure?)> create(InquiryRequest request);
  Future<(InquiryModel?, Failure?)> update(int id, InquiryRequest request);
  Future<Failure?> delete(int id);
}

class InquiryRepositoryImpl implements InquiryRepository {
  final InquiryRemoteDataSource _remoteDataSource;
  final InquiryLocalDataSource _localDataSource;
  final ConnectivityService _connectivity;
  final SyncQueue _syncQueue;
  final TempIdGenerator _tempIdGenerator;

  InquiryRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._connectivity,
    this._syncQueue,
    this._tempIdGenerator,
  );

  @override
  Future<(List<InquiryModel>?, Failure?)> getAll() async {
    if (_connectivity.isOnline) {
      try {
        final inquiries = await _remoteDataSource.getAll();
        await _localDataSource.cacheAll(inquiries);
        return (inquiries, null);
      } on DioException catch (e) {
        final cached = _localDataSource.getAll();
        if (cached.isNotEmpty) return (cached, null);
        return (null, ServerFailure(e.message ?? 'Failed to load inquiries'));
      } catch (e) {
        final cached = _localDataSource.getAll();
        if (cached.isNotEmpty) return (cached, null);
        return (null, UnknownFailure(e.toString()));
      }
    }
    final cached = _localDataSource.getAll();
    if (cached.isNotEmpty) return (cached, null);
    return (null, const CacheFailure('No cached inquiries available'));
  }

  @override
  Future<(List<InquiryModel>?, Failure?)> getByStatus(String status) async {
    if (_connectivity.isOnline) {
      try {
        final inquiries = await _remoteDataSource.getByStatus(status);
        // Cache individually
        for (final i in inquiries) {
          await _localDataSource.cacheSingle(i);
        }
        return (inquiries, null);
      } on DioException catch (e) {
        final cached = _localDataSource.getByStatus(status);
        if (cached.isNotEmpty) return (cached, null);
        return (null, ServerFailure(e.message ?? 'Failed to load inquiries'));
      } catch (e) {
        final cached = _localDataSource.getByStatus(status);
        if (cached.isNotEmpty) return (cached, null);
        return (null, UnknownFailure(e.toString()));
      }
    }
    final cached = _localDataSource.getByStatus(status);
    if (cached.isNotEmpty) return (cached, null);
    return (null, const CacheFailure('No cached inquiries available'));
  }

  @override
  Future<(InquiryModel?, Failure?)> getById(int id) async {
    if (_connectivity.isOnline) {
      try {
        final inquiry = await _remoteDataSource.getById(id);
        await _localDataSource.cacheSingle(inquiry);
        return (inquiry, null);
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          return (null, const ServerFailure('Inquiry not found'));
        }
        final cached = _localDataSource.getById(id);
        if (cached != null) return (cached, null);
        return (null, ServerFailure(e.message ?? 'Failed to load inquiry'));
      } catch (e) {
        final cached = _localDataSource.getById(id);
        if (cached != null) return (cached, null);
        return (null, UnknownFailure(e.toString()));
      }
    }
    final cached = _localDataSource.getById(id);
    if (cached != null) return (cached, null);
    return (null, const CacheFailure('Inquiry not found in cache'));
  }

  @override
  Future<(InquiryModel?, Failure?)> create(InquiryRequest request) async {
    if (_connectivity.isOnline) {
      try {
        final inquiry = await _remoteDataSource.create(request);
        await _localDataSource.cacheSingle(inquiry);
        return (inquiry, null);
      } on DioException {
        return _createOffline(request);
      } catch (e) {
        return (null, UnknownFailure(e.toString()));
      }
    }
    return _createOffline(request);
  }

  Future<(InquiryModel?, Failure?)> _createOffline(
      InquiryRequest request) async {
    final tempId = _tempIdGenerator.next();
    final now = DateTime.now();
    final inquiry = InquiryModel(
      id: tempId,
      fullName: request.fullName,
      parentName: request.parentName,
      parentPhoneNumber: request.parentPhoneNumber,
      interestedCourses: request.interestedCourses,
      status: request.status ?? InquiryStatus.newInquiry,
      notes: request.notes,
      createdAt: now,
      updatedAt: now,
    );
    await _localDataSource.cacheSingle(inquiry);
    await _syncQueue.enqueue(SyncOperation(
      id: const Uuid().v4(),
      entityType: 'inquiry',
      operationType: 'create',
      entityId: tempId,
      payload: request.toJson(),
      createdAt: now,
    ));
    return (inquiry, null);
  }

  @override
  Future<(InquiryModel?, Failure?)> update(
      int id, InquiryRequest request) async {
    if (_connectivity.isOnline) {
      try {
        final inquiry = await _remoteDataSource.update(id, request);
        await _localDataSource.cacheSingle(inquiry);
        return (inquiry, null);
      } on DioException {
        return _updateOffline(id, request);
      } catch (e) {
        return (null, UnknownFailure(e.toString()));
      }
    }
    return _updateOffline(id, request);
  }

  Future<(InquiryModel?, Failure?)> _updateOffline(
      int id, InquiryRequest request) async {
    final existing = _localDataSource.getById(id);
    final now = DateTime.now();
    final updated = InquiryModel(
      id: id,
      fullName: request.fullName,
      parentName: request.parentName,
      parentPhoneNumber: request.parentPhoneNumber,
      interestedCourses: request.interestedCourses,
      status: request.status ?? existing?.status ?? InquiryStatus.newInquiry,
      notes: request.notes,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
    await _localDataSource.cacheSingle(updated);
    await _syncQueue.enqueue(SyncOperation(
      id: const Uuid().v4(),
      entityType: 'inquiry',
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
      entityType: 'inquiry',
      operationType: 'delete',
      entityId: id,
      payload: null,
      createdAt: DateTime.now(),
    ));
    return null;
  }
}

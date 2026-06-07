import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/connectivity_service.dart';
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

  InquiryRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._connectivity,
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
    if (!_connectivity.isOnline) {
      return (null, const ServerFailure('Ariza qo\'shish uchun internet kerak'));
    }
    try {
      final inquiry = await _remoteDataSource.create(request);
      await _localDataSource.cacheSingle(inquiry);
      return (inquiry, null);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] as String? ??
          e.message ??
          'Ariza qo\'shishda xatolik yuz berdi';
      return (null, ServerFailure(message));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(InquiryModel?, Failure?)> update(
      int id, InquiryRequest request) async {
    if (!_connectivity.isOnline) {
      return (null, const ServerFailure('O\'zgartirish uchun internet kerak'));
    }
    try {
      final inquiry = await _remoteDataSource.update(id, request);
      await _localDataSource.cacheSingle(inquiry);
      return (inquiry, null);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] as String? ??
          e.message ??
          'Arizani yangilashda xatolik yuz berdi';
      return (null, ServerFailure(message));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Failure?> delete(int id) async {
    if (!_connectivity.isOnline) {
      return const ServerFailure('O\'chirish uchun internet kerak');
    }
    try {
      await _remoteDataSource.delete(id);
      await _localDataSource.remove(id);
      return null;
    } on DioException catch (e) {
      final message = e.response?.data?['message'] as String? ??
          e.message ??
          'Arizani o\'chirishda xatolik yuz berdi';
      return ServerFailure(message);
    } catch (e) {
      return UnknownFailure(e.toString());
    }
  }
}

import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
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

  InquiryRepositoryImpl(this._remoteDataSource);

  @override
  Future<(List<InquiryModel>?, Failure?)> getAll() async {
    try {
      final inquiries = await _remoteDataSource.getAll();
      return (inquiries, null);
    } on DioException catch (e) {
      return (null, ServerFailure(e.message ?? 'Failed to load inquiries'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(List<InquiryModel>?, Failure?)> getByStatus(String status) async {
    try {
      final inquiries = await _remoteDataSource.getByStatus(status);
      return (inquiries, null);
    } on DioException catch (e) {
      return (null, ServerFailure(e.message ?? 'Failed to load inquiries'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(InquiryModel?, Failure?)> getById(int id) async {
    try {
      final inquiry = await _remoteDataSource.getById(id);
      return (inquiry, null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return (null, const ServerFailure('Inquiry not found'));
      }
      return (null, ServerFailure(e.message ?? 'Failed to load inquiry'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(InquiryModel?, Failure?)> create(InquiryRequest request) async {
    try {
      final inquiry = await _remoteDataSource.create(request);
      return (inquiry, null);
    } on DioException catch (e) {
      return (null, ServerFailure(e.message ?? 'Failed to create inquiry'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(InquiryModel?, Failure?)> update(
      int id, InquiryRequest request) async {
    try {
      final inquiry = await _remoteDataSource.update(id, request);
      return (inquiry, null);
    } on DioException catch (e) {
      return (null, ServerFailure(e.message ?? 'Failed to update inquiry'));
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
      return ServerFailure(e.message ?? 'Failed to delete inquiry');
    } catch (e) {
      return UnknownFailure(e.toString());
    }
  }
}
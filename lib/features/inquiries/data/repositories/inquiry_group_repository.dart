import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/connectivity_service.dart';
import '../datasources/inquiry_group_remote_datasource.dart';
import '../models/inquiry_group_model.dart';
import '../models/inquiry_model.dart';

abstract class InquiryGroupRepository {
  Future<(List<InquiryGroupModel>?, Failure?)> getAll();
  Future<(InquiryGroupModel?, Failure?)> getById(int id);
  Future<(List<InquiryModel>?, Failure?)> getInquiries(int id);
  Future<(InquiryGroupModel?, Failure?)> create(InquiryGroupRequest request);
  Future<Failure?> delete(int id);
  Future<Failure?> migrateToGroup(MigrateToGroupRequest request);
}

class InquiryGroupRepositoryImpl implements InquiryGroupRepository {
  final InquiryGroupRemoteDataSource _remote;
  final ConnectivityService _connectivity;

  InquiryGroupRepositoryImpl(this._remote, this._connectivity);

  @override
  Future<(List<InquiryGroupModel>?, Failure?)> getAll() async {
    if (!_connectivity.isOnline) {
      return (null, const CacheFailure('No internet connection'));
    }
    try {
      final groups = await _remote.getAll();
      return (groups, null);
    } on DioException catch (e) {
      return (null, ServerFailure(e.message ?? 'Failed to load inquiry groups'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(InquiryGroupModel?, Failure?)> getById(int id) async {
    if (!_connectivity.isOnline) {
      return (null, const CacheFailure('No internet connection'));
    }
    try {
      return (await _remote.getById(id), null);
    } on DioException catch (e) {
      return (null, ServerFailure(e.message ?? 'Failed to load inquiry group'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(List<InquiryModel>?, Failure?)> getInquiries(int id) async {
    if (!_connectivity.isOnline) {
      return (null, const CacheFailure('No internet connection'));
    }
    try {
      return (await _remote.getInquiries(id), null);
    } on DioException catch (e) {
      return (null, ServerFailure(e.message ?? 'Failed to load inquiries'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(InquiryGroupModel?, Failure?)> create(
      InquiryGroupRequest request) async {
    if (!_connectivity.isOnline) {
      return (null, const CacheFailure('No internet connection'));
    }
    try {
      return (await _remote.create(request), null);
    } on DioException catch (e) {
      return (null, ServerFailure(e.message ?? 'Failed to create inquiry group'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Failure?> delete(int id) async {
    if (!_connectivity.isOnline) {
      return const CacheFailure('No internet connection');
    }
    try {
      await _remote.delete(id);
      return null;
    } on DioException catch (e) {
      return ServerFailure(e.message ?? 'Failed to delete inquiry group');
    } catch (e) {
      return UnknownFailure(e.toString());
    }
  }

  @override
  Future<Failure?> migrateToGroup(MigrateToGroupRequest request) async {
    if (!_connectivity.isOnline) {
      return const CacheFailure('No internet connection');
    }
    try {
      await _remote.migrateToGroup(request);
      return null;
    } on DioException catch (e) {
      return ServerFailure(e.message ?? 'Failed to migrate inquiries');
    } catch (e) {
      return UnknownFailure(e.toString());
    }
  }
}

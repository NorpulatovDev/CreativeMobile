import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../datasources/admin_remote_datasource.dart';
import '../models/admin_model.dart';

abstract class AdminRepository {
  Future<(List<AdminModel>?, Failure?)> getAll();
  Future<(AdminModel?, Failure?)> getById(int id);
  Future<(AdminModel?, Failure?)> create(AdminRequest request);
  Future<(AdminModel?, Failure?)> update(int id, AdminRequest request);
  Future<Failure?> delete(int id);
}

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource _remoteDataSource;

  AdminRepositoryImpl(this._remoteDataSource);

  @override
  Future<(List<AdminModel>?, Failure?)> getAll() async {
    try {
      final admins = await _remoteDataSource.getAll();
      return (admins, null);
    } on DioException catch (e) {
      return (null, ServerFailure(e.message ?? 'Adminlarni yuklashda xatolik'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(AdminModel?, Failure?)> getById(int id) async {
    try {
      final admin = await _remoteDataSource.getById(id);
      return (admin, null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return (null, const ServerFailure('Admin topilmadi'));
      }
      return (null, ServerFailure(e.message ?? 'Adminni yuklashda xatolik'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(AdminModel?, Failure?)> create(AdminRequest request) async {
    try {
      final admin = await _remoteDataSource.create(request);
      return (admin, null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        return (null, const ServerFailure('Bu foydalanuvchi nomi allaqachon band'));
      }
      return (null, ServerFailure(e.message ?? 'Admin yaratishda xatolik'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(AdminModel?, Failure?)> update(int id, AdminRequest request) async {
    try {
      final admin = await _remoteDataSource.update(id, request);
      return (admin, null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        return (null, const ServerFailure('Bu foydalanuvchi nomi allaqachon band'));
      }
      return (null, ServerFailure(e.message ?? 'Adminni tahrirlashda xatolik'));
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
      return ServerFailure(e.message ?? "Adminni o'chirishda xatolik");
    } catch (e) {
      return UnknownFailure(e.toString());
    }
  }
}

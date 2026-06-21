import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../datasources/branch_local_datasource.dart';
import '../datasources/branch_remote_datasource.dart';
import '../models/branch_model.dart';

abstract class BranchRepository {
  List<BranchModel> getCached();
  Future<(List<BranchModel>?, Failure?)> getAll();
  Future<(BranchModel?, Failure?)> getById(int id);
  Future<(BranchModel?, Failure?)> create(BranchRequest request);
  Future<(BranchModel?, Failure?)> update(int id, BranchRequest request);
  Future<Failure?> delete(int id);
}

class BranchRepositoryImpl implements BranchRepository {
  final BranchRemoteDataSource _remoteDataSource;
  final BranchLocalDataSource _localDataSource;

  BranchRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  List<BranchModel> getCached() => _localDataSource.getAll();

  @override
  Future<(List<BranchModel>?, Failure?)> getAll() async {
    try {
      final branches = await _remoteDataSource.getAll();
      await _localDataSource.cacheAll(branches);
      return (branches, null);
    } on DioException catch (e) {
      return (null, ServerFailure(e.message ?? 'Filiallarni yuklashda xatolik'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(BranchModel?, Failure?)> getById(int id) async {
    try {
      final branch = await _remoteDataSource.getById(id);
      return (branch, null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return (null, const ServerFailure('Filial topilmadi'));
      }
      return (null, ServerFailure(e.message ?? 'Filialni yuklashda xatolik'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(BranchModel?, Failure?)> create(BranchRequest request) async {
    try {
      final branch = await _remoteDataSource.create(request);
      await _localDataSource.cacheSingle(branch);
      return (branch, null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        return (null, const ServerFailure('Bu nomdagi filial allaqachon mavjud'));
      }
      return (null, ServerFailure(e.message ?? 'Filial yaratishda xatolik'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(BranchModel?, Failure?)> update(int id, BranchRequest request) async {
    try {
      final branch = await _remoteDataSource.update(id, request);
      await _localDataSource.cacheSingle(branch);
      return (branch, null);
    } on DioException catch (e) {
      return (null, ServerFailure(e.message ?? 'Filialni tahrirlashda xatolik'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Failure?> delete(int id) async {
    try {
      await _remoteDataSource.delete(id);
      await _localDataSource.remove(id);
      return null;
    } on DioException catch (e) {
      return ServerFailure(e.message ?? "Filialni o'chirishda xatolik");
    } catch (e) {
      return UnknownFailure(e.toString());
    }
  }
}

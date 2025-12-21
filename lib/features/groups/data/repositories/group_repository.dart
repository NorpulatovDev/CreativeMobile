import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../datasources/group_remote_datasource.dart';
import '../models/group_model.dart';

abstract class GroupRepository {
  Future<(List<GroupModel>?, Failure?)> getAll();
  Future<(List<GroupModel>?, Failure?)> getAllSortedByTeacher();
  Future<(List<GroupModel>?, Failure?)> getByTeacherId(int teacherId);
  Future<(GroupModel?, Failure?)> getById(int id);
  Future<(GroupModel?, Failure?)> create(GroupRequest request);
  Future<(GroupModel?, Failure?)> update(int id, GroupRequest request);
  Future<Failure?> delete(int id);
}

class GroupRepositoryImpl implements GroupRepository {
  final GroupRemoteDataSource _remoteDataSource;

  GroupRepositoryImpl(this._remoteDataSource);

  @override
  Future<(List<GroupModel>?, Failure?)> getAll() async {
    try {
      final groups = await _remoteDataSource.getAll();
      return (groups, null);
    } on DioException catch (e) {
      return (null, ServerFailure(e.message ?? 'Failed to load groups'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(List<GroupModel>?, Failure?)> getAllSortedByTeacher() async {
    try {
      final groups = await _remoteDataSource.getAllSortedByTeacher();
      return (groups, null);
    } on DioException catch (e) {
      return (null, ServerFailure(e.message ?? 'Failed to load groups'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(List<GroupModel>?, Failure?)> getByTeacherId(int teacherId) async {
    try {
      final groups = await _remoteDataSource.getByTeacherId(teacherId);
      return (groups, null);
    } on DioException catch (e) {
      return (null, ServerFailure(e.message ?? 'Failed to load groups'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(GroupModel?, Failure?)> getById(int id) async {
    try {
      final group = await _remoteDataSource.getById(id);
      return (group, null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return (null, const ServerFailure('Group not found'));
      }
      return (null, ServerFailure(e.message ?? 'Failed to load group'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(GroupModel?, Failure?)> create(GroupRequest request) async {
    try {
      final group = await _remoteDataSource.create(request);
      return (group, null);
    } on DioException catch (e) {
      return (null, ServerFailure(e.message ?? 'Failed to create group'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(GroupModel?, Failure?)> update(int id, GroupRequest request) async {
    try {
      final group = await _remoteDataSource.update(id, request);
      return (group, null);
    } on DioException catch (e) {
      return (null, ServerFailure(e.message ?? 'Failed to update group'));
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
      return ServerFailure(e.message ?? 'Failed to delete group');
    } catch (e) {
      return UnknownFailure(e.toString());
    }
  }
}
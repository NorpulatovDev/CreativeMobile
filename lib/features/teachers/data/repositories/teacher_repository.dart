import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../datasources/teacher_remote_datasource.dart';
import '../models/teacher_model.dart';

abstract class TeacherRepository {
  Future<(List<TeacherModel>?, Failure?)> getAll();
  Future<(TeacherModel?, Failure?)> getById(int id);
  Future<(TeacherModel?, Failure?)> create(TeacherRequest request);
  Future<(TeacherModel?, Failure?)> update(int id, TeacherRequest request);
  Future<Failure?> delete(int id);
}

class TeacherRepositoryImpl implements TeacherRepository {
  final TeacherRemoteDataSource _remoteDataSource;

  TeacherRepositoryImpl(this._remoteDataSource);

  @override
  Future<(List<TeacherModel>?, Failure?)> getAll() async {
    try {
      final teachers = await _remoteDataSource.getAll();
      return (teachers, null);
    } on DioException catch (e) {
      return (null, ServerFailure(e.message ?? 'Failed to load teachers'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(TeacherModel?, Failure?)> getById(int id) async {
    try {
      final teacher = await _remoteDataSource.getById(id);
      return (teacher, null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return (null, const ServerFailure('Teacher not found'));
      }
      return (null, ServerFailure(e.message ?? 'Failed to load teacher'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(TeacherModel?, Failure?)> create(TeacherRequest request) async {
    try {
      final teacher = await _remoteDataSource.create(request);
      return (teacher, null);
    } on DioException catch (e) {
      return (null, ServerFailure(e.message ?? 'Failed to create teacher'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(TeacherModel?, Failure?)> update(int id, TeacherRequest request) async {
    try {
      final teacher = await _remoteDataSource.update(id, request);
      return (teacher, null);
    } on DioException catch (e) {
      return (null, ServerFailure(e.message ?? 'Failed to update teacher'));
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
      if (e.response?.statusCode == 400) {
        return const ServerFailure('Cannot delete teacher with assigned groups');
      }
      return ServerFailure(e.message ?? 'Failed to delete teacher');
    } catch (e) {
      return UnknownFailure(e.toString());
    }
  }
}
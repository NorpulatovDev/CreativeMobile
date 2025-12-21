import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../datasources/student_remote_datasource.dart';
import '../models/student_model.dart';

abstract class StudentRepository {
  Future<(List<StudentModel>?, Failure?)> getAll();
  Future<(List<StudentModel>?, Failure?)> getByGroupId(int groupId);
  Future<(StudentModel?, Failure?)> getById(int id);
  Future<(StudentModel?, Failure?)> create(StudentRequest request);
  Future<(StudentModel?, Failure?)> update(int id, StudentRequest request);
}

class StudentRepositoryImpl implements StudentRepository {
  final StudentRemoteDataSource _remoteDataSource;

  StudentRepositoryImpl(this._remoteDataSource);

  @override
  Future<(List<StudentModel>?, Failure?)> getAll() async {
    try {
      final students = await _remoteDataSource.getAll();
      return (students, null);
    } on DioException catch (e) {
      return (null, ServerFailure(e.message ?? 'Failed to load students'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(List<StudentModel>?, Failure?)> getByGroupId(int groupId) async {
    try {
      final students = await _remoteDataSource.getByGroupId(groupId);
      return (students, null);
    } on DioException catch (e) {
      return (null, ServerFailure(e.message ?? 'Failed to load students'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(StudentModel?, Failure?)> getById(int id) async {
    try {
      final student = await _remoteDataSource.getById(id);
      return (student, null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return (null, const ServerFailure('Student not found'));
      }
      return (null, ServerFailure(e.message ?? 'Failed to load student'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(StudentModel?, Failure?)> create(StudentRequest request) async {
    try {
      final student = await _remoteDataSource.create(request);
      return (student, null);
    } on DioException catch (e) {
      return (null, ServerFailure(e.message ?? 'Failed to create student'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(StudentModel?, Failure?)> update(int id, StudentRequest request) async {
    try {
      final student = await _remoteDataSource.update(id, request);
      return (student, null);
    } on DioException catch (e) {
      return (null, ServerFailure(e.message ?? 'Failed to update student'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }
}
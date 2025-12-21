import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../datasources/enrollment_remote_datasource.dart';
import '../models/enrollment_model.dart';

abstract class EnrollmentRepository {
  Future<(EnrollmentModel?, Failure?)> addStudentToGroup(int studentId, int groupId);
  Future<Failure?> removeStudentFromGroup(int studentId, int groupId);
  Future<(List<EnrollmentModel>?, Failure?)> getStudentGroups(int studentId);
  Future<(List<EnrollmentModel>?, Failure?)> getGroupStudents(int groupId);
}

class EnrollmentRepositoryImpl implements EnrollmentRepository {
  final EnrollmentRemoteDataSource _remoteDataSource;

  EnrollmentRepositoryImpl(this._remoteDataSource);

  @override
  Future<(EnrollmentModel?, Failure?)> addStudentToGroup(
      int studentId, int groupId) async {
    try {
      final enrollment = await _remoteDataSource.addStudentToGroup(
        EnrollmentRequest(studentId: studentId, groupId: groupId),
      );
      return (enrollment, null);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Failed to enroll student';
      return (null, ServerFailure(message));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Failure?> removeStudentFromGroup(int studentId, int groupId) async {
    try {
      await _remoteDataSource.removeStudentFromGroup(studentId, groupId);
      return null;
    } on DioException catch (e) {
      return ServerFailure(e.message ?? 'Failed to remove student from group');
    } catch (e) {
      return UnknownFailure(e.toString());
    }
  }

  @override
  Future<(List<EnrollmentModel>?, Failure?)> getStudentGroups(
      int studentId) async {
    try {
      final enrollments = await _remoteDataSource.getStudentGroups(studentId);
      return (enrollments, null);
    } on DioException catch (e) {
      return (null, ServerFailure(e.message ?? 'Failed to load enrollments'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(List<EnrollmentModel>?, Failure?)> getGroupStudents(
      int groupId) async {
    try {
      final enrollments = await _remoteDataSource.getGroupStudents(groupId);
      return (enrollments, null);
    } on DioException catch (e) {
      return (null, ServerFailure(e.message ?? 'Failed to load enrollments'));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }
}
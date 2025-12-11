import 'package:injectable/injectable.dart';
import '../datasources/student_remote_datasource.dart';
import '../models/models.dart';

abstract class StudentRepository {
  Future<List<Student>> getAll();
  Future<List<Student>> getByGroupId(int groupId);
  Future<Student> getById(int id);
  Future<Student> create(StudentRequest request);
  Future<Student> update(int id, StudentRequest request);
  Future<Student> assignToGroup(int studentId, int groupId);
  Future<Student> removeFromGroup(int studentId);
}

@LazySingleton(as: StudentRepository)
class StudentRepositoryImpl implements StudentRepository {
  final StudentRemoteDataSource _remoteDataSource;

  StudentRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Student>> getAll() => _remoteDataSource.getAll();

  @override
  Future<List<Student>> getByGroupId(int groupId) =>
      _remoteDataSource.getByGroupId(groupId);

  @override
  Future<Student> getById(int id) => _remoteDataSource.getById(id);

  @override
  Future<Student> create(StudentRequest request) =>
      _remoteDataSource.create(request);

  @override
  Future<Student> update(int id, StudentRequest request) =>
      _remoteDataSource.update(id, request);

  @override
  Future<Student> assignToGroup(int studentId, int groupId) =>
      _remoteDataSource.assignToGroup(studentId, groupId);

  @override
  Future<Student> removeFromGroup(int studentId) =>
      _remoteDataSource.removeFromGroup(studentId);
}
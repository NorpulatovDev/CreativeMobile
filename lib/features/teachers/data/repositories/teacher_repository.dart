import 'package:injectable/injectable.dart';
import '../datasources/teacher_remote_datasource.dart';
import '../models/models.dart';

abstract class TeacherRepository {
  Future<List<Teacher>> getAll();
  Future<Teacher> getById(int id);
  Future<Teacher> create(TeacherRequest request);
  Future<Teacher> update(int id, TeacherRequest request);
  Future<void> delete(int id);
}

@LazySingleton(as: TeacherRepository)
class TeacherRepositoryImpl implements TeacherRepository {
  final TeacherRemoteDataSource _remoteDataSource;

  TeacherRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Teacher>> getAll() => _remoteDataSource.getAll();

  @override
  Future<Teacher> getById(int id) => _remoteDataSource.getById(id);

  @override
  Future<Teacher> create(TeacherRequest request) =>
      _remoteDataSource.create(request);

  @override
  Future<Teacher> update(int id, TeacherRequest request) =>
      _remoteDataSource.update(id, request);

  @override
  Future<void> delete(int id) => _remoteDataSource.delete(id);
}
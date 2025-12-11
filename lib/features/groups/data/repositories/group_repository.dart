import 'package:injectable/injectable.dart';
import '../datasources/group_remote_datasource.dart';
import '../models/models.dart';

abstract class GroupRepository {
  Future<List<Group>> getAll();
  Future<List<Group>> getByTeacherId(int teacherId);
  Future<Group> getById(int id);
  Future<Group> create(GroupRequest request);
  Future<Group> update(int id, GroupRequest request);
  Future<void> delete(int id);
}

@LazySingleton(as: GroupRepository)
class GroupRepositoryImpl implements GroupRepository {
  final GroupRemoteDataSource _remoteDataSource;

  GroupRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Group>> getAll() => _remoteDataSource.getAll();

  @override
  Future<List<Group>> getByTeacherId(int teacherId) =>
      _remoteDataSource.getByTeacherId(teacherId);

  @override
  Future<Group> getById(int id) => _remoteDataSource.getById(id);

  @override
  Future<Group> create(GroupRequest request) =>
      _remoteDataSource.create(request);

  @override
  Future<Group> update(int id, GroupRequest request) =>
      _remoteDataSource.update(id, request);

  @override
  Future<void> delete(int id) => _remoteDataSource.delete(id);
}
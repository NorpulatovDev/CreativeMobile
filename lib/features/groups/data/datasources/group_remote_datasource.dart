import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_constants.dart';
import '../models/models.dart';

abstract class GroupRemoteDataSource {
  Future<List<Group>> getAll();
  Future<List<Group>> getByTeacherId(int teacherId);
  Future<Group> getById(int id);
  Future<Group> create(GroupRequest request);
  Future<Group> update(int id, GroupRequest request);
  Future<void> delete(int id);
}

@LazySingleton(as: GroupRemoteDataSource)
class GroupRemoteDataSourceImpl implements GroupRemoteDataSource {
  final Dio _dio;

  GroupRemoteDataSourceImpl(this._dio);

  @override
  Future<List<Group>> getAll() async {
    final response = await _dio.get(ApiConstants.groups);
    return (response.data as List)
        .map((json) => Group.fromJson(json))
        .toList();
  }

  @override
  Future<List<Group>> getByTeacherId(int teacherId) async {
    final response = await _dio.get('${ApiConstants.groups}/teacher/$teacherId');
    return (response.data as List)
        .map((json) => Group.fromJson(json))
        .toList();
  }

  @override
  Future<Group> getById(int id) async {
    final response = await _dio.get('${ApiConstants.groups}/$id');
    return Group.fromJson(response.data);
  }

  @override
  Future<Group> create(GroupRequest request) async {
    final response = await _dio.post(
      ApiConstants.groups,
      data: request.toJson(),
    );
    return Group.fromJson(response.data);
  }

  @override
  Future<Group> update(int id, GroupRequest request) async {
    final response = await _dio.put(
      '${ApiConstants.groups}/$id',
      data: request.toJson(),
    );
    return Group.fromJson(response.data);
  }

  @override
  Future<void> delete(int id) async {
    await _dio.delete('${ApiConstants.groups}/$id');
  }
}
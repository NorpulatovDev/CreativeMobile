import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../models/group_model.dart';

abstract class GroupRemoteDataSource {
  Future<List<GroupModel>> getAll();

  /// Groups of a specific branch, regardless of the app-wide selected branch.
  /// Sends an explicit X-Branch-Filter so SUPER_ADMIN can read another branch's
  /// groups (e.g. when moving a student across branches).
  Future<List<GroupModel>> getAllForBranch(int branchId);
  Future<List<GroupModel>> getAllSortedByTeacher({int? year, int? month});
  Future<List<GroupModel>> getByTeacherId(int teacherId);
  /// Groups assigned to the logged-in TEACHER. Server derives the teacher
  /// from the JWT, so this only ever returns that teacher's own groups.
  Future<List<GroupModel>> getMine();
  Future<GroupModel> getById(int id);
  Future<GroupModel> create(GroupRequest request);
  Future<GroupModel> update(int id, GroupRequest request);
  Future<void> delete(int id);
}

class GroupRemoteDataSourceImpl implements GroupRemoteDataSource {
  final ApiClient _apiClient;

  GroupRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<GroupModel>> getAll() async {
    final response = await _apiClient.get<List<dynamic>>('/api/groups');
    return (response.data ?? [])
        .map((json) => GroupModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<GroupModel>> getAllForBranch(int branchId) async {
    final response = await _apiClient.get<List<dynamic>>(
      '/api/groups',
      options: Options(headers: {'X-Branch-Filter': branchId.toString()}),
    );
    return (response.data ?? [])
        .map((json) => GroupModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<GroupModel>> getAllSortedByTeacher({int? year, int? month}) async {
    final response = await _apiClient.get<List<dynamic>>(
      '/api/groups/sorted-by-teacher',
      queryParameters: (year != null && month != null)
          ? {'year': year, 'month': month}
          : null,
    );
    return (response.data ?? [])
        .map((json) => GroupModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<GroupModel>> getByTeacherId(int teacherId) async {
    final response =
        await _apiClient.get<List<dynamic>>('/api/groups/teacher/$teacherId');
    return (response.data ?? [])
        .map((json) => GroupModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<GroupModel>> getMine() async {
    final response = await _apiClient.get<List<dynamic>>('/api/groups/mine');
    return (response.data ?? [])
        .map((json) => GroupModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<GroupModel> getById(int id) async {
    final response =
        await _apiClient.get<Map<String, dynamic>>('/api/groups/$id');
    return GroupModel.fromJson(response.data!);
  }

  @override
  Future<GroupModel> create(GroupRequest request) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/api/groups',
      data: request.toJson(),
    );
    return GroupModel.fromJson(response.data!);
  }

  @override
  Future<GroupModel> update(int id, GroupRequest request) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/api/groups/$id',
      data: request.toJson(),
    );
    return GroupModel.fromJson(response.data!);
  }

  @override
  Future<void> delete(int id) async {
    await _apiClient.delete('/api/groups/$id');
  }
}
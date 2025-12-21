import '../../../../core/api/api_client.dart';
import '../models/group_model.dart';

abstract class GroupRemoteDataSource {
  Future<List<GroupModel>> getAll();
  Future<List<GroupModel>> getAllSortedByTeacher();
  Future<List<GroupModel>> getByTeacherId(int teacherId);
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
  Future<List<GroupModel>> getAllSortedByTeacher() async {
    final response =
        await _apiClient.get<List<dynamic>>('/api/groups/sorted-by-teacher');
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
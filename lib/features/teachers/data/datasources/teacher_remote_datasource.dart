import '../../../../core/api/api_client.dart';
import '../models/teacher_model.dart';

abstract class TeacherRemoteDataSource {
  Future<List<TeacherModel>> getAll();
  Future<TeacherModel> getById(int id);
  Future<TeacherModel> create(TeacherRequest request);
  Future<TeacherModel> update(int id, TeacherRequest request);
  Future<void> delete(int id);
}

class TeacherRemoteDataSourceImpl implements TeacherRemoteDataSource {
  final ApiClient _apiClient;

  TeacherRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<TeacherModel>> getAll() async {
    final response = await _apiClient.get<List<dynamic>>('/api/teachers');
    return (response.data ?? [])
        .map((json) => TeacherModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<TeacherModel> getById(int id) async {
    final response =
        await _apiClient.get<Map<String, dynamic>>('/api/teachers/$id');
    return TeacherModel.fromJson(response.data!);
  }

  @override
  Future<TeacherModel> create(TeacherRequest request) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/api/teachers',
      data: request.toJson(),
    );
    return TeacherModel.fromJson(response.data!);
  }

  @override
  Future<TeacherModel> update(int id, TeacherRequest request) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/api/teachers/$id',
      data: request.toJson(),
    );
    return TeacherModel.fromJson(response.data!);
  }

  @override
  Future<void> delete(int id) async {
    await _apiClient.delete('/api/teachers/$id');
  }
}
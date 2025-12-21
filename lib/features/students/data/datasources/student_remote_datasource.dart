import '../../../../core/api/api_client.dart';
import '../models/student_model.dart';

abstract class StudentRemoteDataSource {
  Future<List<StudentModel>> getAll();
  Future<List<StudentModel>> getByGroupId(int groupId);
  Future<StudentModel> getById(int id);
  Future<StudentModel> create(StudentRequest request);
  Future<StudentModel> update(int id, StudentRequest request);
}

class StudentRemoteDataSourceImpl implements StudentRemoteDataSource {
  final ApiClient _apiClient;

  StudentRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<StudentModel>> getAll() async {
    final response = await _apiClient.get<List<dynamic>>('/api/students');
    return (response.data ?? [])
        .map((json) => StudentModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<StudentModel>> getByGroupId(int groupId) async {
    final response =
        await _apiClient.get<List<dynamic>>('/api/students/group/$groupId');
    return (response.data ?? [])
        .map((json) => StudentModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<StudentModel> getById(int id) async {
    final response =
        await _apiClient.get<Map<String, dynamic>>('/api/students/$id');
    return StudentModel.fromJson(response.data!);
  }

  @override
  Future<StudentModel> create(StudentRequest request) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/api/students',
      data: request.toJson(),
    );
    return StudentModel.fromJson(response.data!);
  }

  @override
  Future<StudentModel> update(int id, StudentRequest request) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/api/students/$id',
      data: request.toJson(),
    );
    return StudentModel.fromJson(response.data!);
  }
}
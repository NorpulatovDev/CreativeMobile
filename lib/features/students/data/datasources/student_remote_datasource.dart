import '../../../../core/api/api_client.dart';
import '../../../../core/models/paged_response.dart';
import '../models/student_model.dart';

abstract class StudentRemoteDataSource {
  Future<List<StudentModel>> getAll();
  Future<PagedResponse<StudentModel>> search(String query, int page, int size);
  Future<List<StudentModel>> getByGroupId(int groupId, {int? year, int? month});
  Future<StudentModel> getById(int id);
  Future<StudentModel> create(StudentRequest request);
  Future<StudentModel> update(int id, StudentRequest request);
  Future<void> delete(int id);
}

class StudentRemoteDataSourceImpl implements StudentRemoteDataSource {
  final ApiClient _apiClient;

  StudentRemoteDataSourceImpl(this._apiClient);

  @override
  Future<PagedResponse<StudentModel>> search(String query, int page, int size) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/api/students/search',
      queryParameters: {'search': query, 'page': page, 'size': size},
    );
    return PagedResponse.fromJson(response.data!, StudentModel.fromJson);
  }

  @override
  Future<List<StudentModel>> getAll() async {
    final response = await _apiClient.get<List<dynamic>>('/api/students');
    return (response.data ?? [])
        .map((json) => StudentModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<StudentModel>> getByGroupId(int groupId,
      {int? year, int? month}) async {
    // Build query parameters
    final queryParams = <String, dynamic>{};
    if (year != null) queryParams['year'] = year;
    if (month != null) queryParams['month'] = month;

    final response = await _apiClient.get<List<dynamic>>(
      '/api/students/group/$groupId',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
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

  @override
  Future<void> delete(int id) async {
    await _apiClient.delete('/api/students/$id');
  }
}
import '../../../../core/api/api_client.dart';
import '../models/enrollment_model.dart';

abstract class EnrollmentRemoteDataSource {
  Future<EnrollmentModel> addStudentToGroup(EnrollmentRequest request);
  Future<void> removeStudentFromGroup(int studentId, int groupId);
  Future<List<EnrollmentModel>> getStudentGroups(int studentId);
  Future<List<EnrollmentModel>> getStudentActiveGroups(int studentId);
  Future<List<EnrollmentModel>> getGroupStudents(int groupId);
}

class EnrollmentRemoteDataSourceImpl implements EnrollmentRemoteDataSource {
  final ApiClient _apiClient;

  EnrollmentRemoteDataSourceImpl(this._apiClient);

  @override
  Future<EnrollmentModel> addStudentToGroup(EnrollmentRequest request) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/api/enrollments',
      data: request.toJson(),
    );
    return EnrollmentModel.fromJson(response.data!);
  }

  @override
  Future<void> removeStudentFromGroup(int studentId, int groupId) async {
    await _apiClient.delete('/api/enrollments/student/$studentId/group/$groupId');
  }

  @override
  Future<List<EnrollmentModel>> getStudentGroups(int studentId) async {
    final response = await _apiClient
        .get<List<dynamic>>('/api/enrollments/student/$studentId');
    return (response.data ?? [])
        .map((json) => EnrollmentModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<EnrollmentModel>> getStudentActiveGroups(int studentId) async {
    final response = await _apiClient
        .get<List<dynamic>>('/api/enrollments/student/$studentId/active');
    return (response.data ?? [])
        .map((json) => EnrollmentModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<EnrollmentModel>> getGroupStudents(int groupId) async {
    final response =
        await _apiClient.get<List<dynamic>>('/api/enrollments/group/$groupId');
    return (response.data ?? [])
        .map((json) => EnrollmentModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
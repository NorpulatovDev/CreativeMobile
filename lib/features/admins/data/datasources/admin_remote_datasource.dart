import '../../../../core/api/api_client.dart';
import '../models/admin_model.dart';

abstract class AdminRemoteDataSource {
  Future<List<AdminModel>> getAll();
  Future<AdminModel> getById(int id);
  Future<AdminModel> create(AdminRequest request);
  Future<AdminModel> update(int id, AdminRequest request);
  Future<void> delete(int id);
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final ApiClient _apiClient;

  AdminRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<AdminModel>> getAll() async {
    final response = await _apiClient.get<List<dynamic>>('/api/admins');
    return (response.data ?? [])
        .map((json) => AdminModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AdminModel> getById(int id) async {
    final response =
        await _apiClient.get<Map<String, dynamic>>('/api/admins/$id');
    return AdminModel.fromJson(response.data!);
  }

  @override
  Future<AdminModel> create(AdminRequest request) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/api/admins',
      data: request.toJson(),
    );
    return AdminModel.fromJson(response.data!);
  }

  @override
  Future<AdminModel> update(int id, AdminRequest request) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/api/admins/$id',
      data: request.toJson(),
    );
    return AdminModel.fromJson(response.data!);
  }

  @override
  Future<void> delete(int id) async {
    await _apiClient.delete('/api/admins/$id');
  }
}

import '../../../../core/api/api_client.dart';
import '../models/branch_model.dart';

abstract class BranchRemoteDataSource {
  Future<List<BranchModel>> getAll();
  Future<BranchModel> getById(int id);
  Future<BranchModel> create(BranchRequest request);
  Future<BranchModel> update(int id, BranchRequest request);
  Future<void> delete(int id);
}

class BranchRemoteDataSourceImpl implements BranchRemoteDataSource {
  final ApiClient _apiClient;

  BranchRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<BranchModel>> getAll() async {
    final response = await _apiClient.get<List<dynamic>>('/api/branches');
    return (response.data ?? [])
        .map((json) => BranchModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<BranchModel> getById(int id) async {
    final response =
        await _apiClient.get<Map<String, dynamic>>('/api/branches/$id');
    return BranchModel.fromJson(response.data!);
  }

  @override
  Future<BranchModel> create(BranchRequest request) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/api/branches',
      data: request.toJson(),
    );
    return BranchModel.fromJson(response.data!);
  }

  @override
  Future<BranchModel> update(int id, BranchRequest request) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/api/branches/$id',
      data: request.toJson(),
    );
    return BranchModel.fromJson(response.data!);
  }

  @override
  Future<void> delete(int id) async {
    await _apiClient.delete('/api/branches/$id');
  }
}

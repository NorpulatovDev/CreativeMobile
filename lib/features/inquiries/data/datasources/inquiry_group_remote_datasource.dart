import '../../../../core/api/api_client.dart';
import '../models/inquiry_group_model.dart';
import '../models/inquiry_model.dart';

abstract class InquiryGroupRemoteDataSource {
  Future<List<InquiryGroupModel>> getAll();
  Future<InquiryGroupModel> getById(int id);
  Future<List<InquiryModel>> getInquiries(int id);
  Future<InquiryGroupModel> create(InquiryGroupRequest request);
  Future<void> delete(int id);
  Future<void> migrateToGroup(MigrateToGroupRequest request);
}

class InquiryGroupRemoteDataSourceImpl implements InquiryGroupRemoteDataSource {
  final ApiClient _apiClient;

  InquiryGroupRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<InquiryGroupModel>> getAll() async {
    final response =
        await _apiClient.get<List<dynamic>>('/api/inquiry-groups');
    return (response.data ?? [])
        .map((json) =>
            InquiryGroupModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<InquiryGroupModel> getById(int id) async {
    final response = await _apiClient
        .get<Map<String, dynamic>>('/api/inquiry-groups/$id');
    return InquiryGroupModel.fromJson(response.data!);
  }

  @override
  Future<List<InquiryModel>> getInquiries(int id) async {
    final response = await _apiClient
        .get<List<dynamic>>('/api/inquiry-groups/$id/inquiries');
    return (response.data ?? [])
        .map((json) => InquiryModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<InquiryGroupModel> create(InquiryGroupRequest request) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/api/inquiry-groups',
      data: request.toJson(),
    );
    return InquiryGroupModel.fromJson(response.data!);
  }

  @override
  Future<void> delete(int id) async {
    await _apiClient.delete('/api/inquiry-groups/$id');
  }

  @override
  Future<void> migrateToGroup(MigrateToGroupRequest request) async {
    await _apiClient.post<Map<String, dynamic>>(
      '/api/inquiries/migrate-to-group',
      data: request.toJson(),
    );
  }
}

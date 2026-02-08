import '../../../../core/api/api_client.dart';
import '../models/inquiry_model.dart';

abstract class InquiryRemoteDataSource {
  Future<List<InquiryModel>> getAll();
  Future<List<InquiryModel>> getByStatus(String status);
  Future<InquiryModel> getById(int id);
  Future<InquiryModel> create(InquiryRequest request);
  Future<InquiryModel> update(int id, InquiryRequest request);
  Future<void> delete(int id);
}

class InquiryRemoteDataSourceImpl implements InquiryRemoteDataSource {
  final ApiClient _apiClient;

  InquiryRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<InquiryModel>> getAll() async {
    final response = await _apiClient.get<List<dynamic>>('/api/inquiries');
    return (response.data ?? [])
        .map((json) => InquiryModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<InquiryModel>> getByStatus(String status) async {
    final response =
        await _apiClient.get<List<dynamic>>('/api/inquiries/status/$status');
    return (response.data ?? [])
        .map((json) => InquiryModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<InquiryModel> getById(int id) async {
    final response =
        await _apiClient.get<Map<String, dynamic>>('/api/inquiries/$id');
    return InquiryModel.fromJson(response.data!);
  }

  @override
  Future<InquiryModel> create(InquiryRequest request) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/api/inquiries',
      data: request.toJson(),
    );
    return InquiryModel.fromJson(response.data!);
  }

  @override
  Future<InquiryModel> update(int id, InquiryRequest request) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/api/inquiries/$id',
      data: request.toJson(),
    );
    return InquiryModel.fromJson(response.data!);
  }

  @override
  Future<void> delete(int id) async {
    await _apiClient.delete('/api/inquiries/$id');
  }
}
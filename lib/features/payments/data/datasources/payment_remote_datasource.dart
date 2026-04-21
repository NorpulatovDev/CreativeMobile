import '../../../../core/api/api_client.dart';
import '../../../../core/models/paged_response.dart';
import '../models/payment_model.dart';

abstract class PaymentRemoteDataSource {
  Future<List<PaymentModel>> getAll();
  Future<PagedResponse<PaymentModel>> search(String query, int page, int size);
  Future<List<PaymentModel>> getByStudentId(int studentId);
  Future<List<PaymentModel>> getByGroupId(int groupId);
  Future<List<PaymentModel>> getByGroupIdAndMonth(int groupId, int year, int month);
  Future<PaymentModel> getById(int id);
  Future<PaymentModel> create(PaymentRequest request);
  Future<PaymentModel> update(int id, PaymentRequest request);
  Future<void> delete(int id);
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final ApiClient _apiClient;

  PaymentRemoteDataSourceImpl(this._apiClient);

  @override
  Future<PagedResponse<PaymentModel>> search(String query, int page, int size) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/api/payments/search',
      queryParameters: {'search': query, 'page': page, 'size': size},
    );
    return PagedResponse.fromJson(response.data!, PaymentModel.fromJson);
  }

  @override
  Future<List<PaymentModel>> getAll() async {
    final response = await _apiClient.get<List<dynamic>>('/api/payments');
    return (response.data ?? [])
        .map((json) => PaymentModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<PaymentModel>> getByStudentId(int studentId) async {
    final response = await _apiClient
        .get<List<dynamic>>('/api/payments/student/$studentId');
    return (response.data ?? [])
        .map((json) => PaymentModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<PaymentModel>> getByGroupId(int groupId) async {
    final response =
        await _apiClient.get<List<dynamic>>('/api/payments/group/$groupId');
    return (response.data ?? [])
        .map((json) => PaymentModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<PaymentModel>> getByGroupIdAndMonth(
      int groupId, int year, int month) async {
    final response = await _apiClient.get<List<dynamic>>(
        '/api/payments/group/$groupId/month/$year/$month');
    return (response.data ?? [])
        .map((json) => PaymentModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PaymentModel> getById(int id) async {
    final response =
        await _apiClient.get<Map<String, dynamic>>('/api/payments/$id');
    return PaymentModel.fromJson(response.data!);
  }

  @override
  Future<PaymentModel> create(PaymentRequest request) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/api/payments',
      data: request.toJson(),
    );
    return PaymentModel.fromJson(response.data!);
  }

  @override
  Future<PaymentModel> update(int id, PaymentRequest request) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/api/payments/$id',
      data: request.toJson(),
    );
    return PaymentModel.fromJson(response.data!);
  }

  @override
  Future<void> delete(int id) async {
    await _apiClient.delete('/api/payments/$id');
  }
}
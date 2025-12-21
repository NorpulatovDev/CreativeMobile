import '../../../../core/api/api_client.dart';
import '../models/payment_model.dart';

abstract class PaymentRemoteDataSource {
  Future<List<PaymentModel>> getAll();
  Future<PaymentModel> getById(int id);
  Future<List<PaymentModel>> getByStudentId(int studentId);
  Future<List<PaymentModel>> getByGroupId(int groupId);
  Future<PaymentModel> create(PaymentRequest request);
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final ApiClient _apiClient;

  PaymentRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<PaymentModel>> getAll() async {
    final response = await _apiClient.get<List<dynamic>>('/api/payments');
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
  Future<PaymentModel> create(PaymentRequest request) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/api/payments',
      data: request.toJson(),
    );
    return PaymentModel.fromJson(response.data!);
  }
}
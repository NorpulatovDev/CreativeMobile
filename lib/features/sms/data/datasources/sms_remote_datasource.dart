import '../../../../core/api/api_client.dart';
import '../models/sms_message_model.dart';

abstract class SmsRemoteDataSource {
  Future<List<SmsMessageModel>> getFailed();
  Future<void> retry(int id);
  Future<int> retryAll();
}

class SmsRemoteDataSourceImpl implements SmsRemoteDataSource {
  final ApiClient _apiClient;

  SmsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<SmsMessageModel>> getFailed() async {
    final response = await _apiClient.get<List<dynamic>>('/api/sms/failed');
    return (response.data ?? [])
        .map((j) => SmsMessageModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> retry(int id) async {
    await _apiClient.post<void>('/api/sms/$id/retry');
  }

  @override
  Future<int> retryAll() async {
    final response = await _apiClient.post<dynamic>('/api/sms/retry-failed');
    return (response.data as num?)?.toInt() ?? 0;
  }
}

import '../../../../core/api/api_client.dart';
import '../models/sms_message_model.dart';

abstract class SmsRemoteDataSource {
  Future<List<SmsMessageModel>> getPending();
}

class SmsRemoteDataSourceImpl implements SmsRemoteDataSource {
  final ApiClient _apiClient;

  SmsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<SmsMessageModel>> getPending() async {
    final response = await _apiClient.get<List<dynamic>>('/api/sms/pending');
    return (response.data ?? [])
        .map((j) => SmsMessageModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }
}

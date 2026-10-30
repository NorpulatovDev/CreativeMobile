import '../../../../core/api/api_client.dart';
import '../models/sms_template_model.dart';

abstract class SmsTemplateRemoteDataSource {
  Future<List<SmsTemplateModel>> getAll();
  Future<SmsTemplateModel> update(String type, String body);
  Future<SmsTemplateModel> reset(String type);
}

class SmsTemplateRemoteDataSourceImpl implements SmsTemplateRemoteDataSource {
  final ApiClient _apiClient;

  SmsTemplateRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<SmsTemplateModel>> getAll() async {
    final response = await _apiClient.get<List<dynamic>>('/api/sms-templates');
    return (response.data ?? [])
        .map((json) => SmsTemplateModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<SmsTemplateModel> update(String type, String body) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/api/sms-templates/$type',
      data: {'body': body},
    );
    return SmsTemplateModel.fromJson(response.data!);
  }

  @override
  Future<SmsTemplateModel> reset(String type) async {
    final response = await _apiClient
        .delete<Map<String, dynamic>>('/api/sms-templates/$type');
    return SmsTemplateModel.fromJson(response.data!);
  }
}

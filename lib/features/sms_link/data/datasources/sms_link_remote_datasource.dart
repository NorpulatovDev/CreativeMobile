import '../../../../core/api/api_client.dart';
import '../models/sms_link_model.dart';

abstract class SmsLinkRemoteDataSource {
  Future<List<SmsLinkResponse>> linkByPhone(SmsLinkByPhoneRequest request);
  Future<SmsLinkResponse> linkByCode(SmsLinkByCodeRequest request);
  Future<SmsLinkResponse> getLinkStatus(int studentId);
}

class SmsLinkRemoteDataSourceImpl implements SmsLinkRemoteDataSource {
  final ApiClient _apiClient;

  SmsLinkRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<SmsLinkResponse>> linkByPhone(SmsLinkByPhoneRequest request) async {
    final response = await _apiClient.post<List<dynamic>>(
      '/sms/link/by-phone',
      data: request.toJson(),
    );
    return (response.data ?? [])
        .map((json) => SmsLinkResponse.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<SmsLinkResponse> linkByCode(SmsLinkByCodeRequest request) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/sms/link/by-code',
      data: request.toJson(),
    );
    return SmsLinkResponse.fromJson(response.data!);
  }

  @override
  Future<SmsLinkResponse> getLinkStatus(int studentId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/sms/link/$studentId',
    );
    return SmsLinkResponse.fromJson(response.data!);
  }
}
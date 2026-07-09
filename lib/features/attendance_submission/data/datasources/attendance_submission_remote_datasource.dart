import '../../../../core/api/api_client.dart';
import '../models/attendance_submission_model.dart';

abstract class AttendanceSubmissionRemoteDataSource {
  Future<AttendanceSubmissionModel> create(AttendanceSubmissionRequest request);
  Future<List<AttendanceSubmissionModel>> getPending();
  Future<List<AttendanceSubmissionModel>> getMine();
  Future<AttendanceSubmissionModel> getById(int id);
  Future<AttendanceSubmissionModel> approve(int id);
  Future<AttendanceSubmissionModel> reject(int id, String? note);
}

class AttendanceSubmissionRemoteDataSourceImpl
    implements AttendanceSubmissionRemoteDataSource {
  final ApiClient _apiClient;

  AttendanceSubmissionRemoteDataSourceImpl(this._apiClient);

  static const _base = '/api/attendance-submissions';

  @override
  Future<AttendanceSubmissionModel> create(
      AttendanceSubmissionRequest request) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      _base,
      data: request.toJson(),
    );
    return AttendanceSubmissionModel.fromJson(response.data!);
  }

  @override
  Future<List<AttendanceSubmissionModel>> getPending() async {
    final response = await _apiClient.get<List<dynamic>>(_base);
    return (response.data ?? [])
        .map((j) => AttendanceSubmissionModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<AttendanceSubmissionModel>> getMine() async {
    final response = await _apiClient.get<List<dynamic>>('$_base/mine');
    return (response.data ?? [])
        .map((j) => AttendanceSubmissionModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AttendanceSubmissionModel> getById(int id) async {
    final response = await _apiClient.get<Map<String, dynamic>>('$_base/$id');
    return AttendanceSubmissionModel.fromJson(response.data!);
  }

  @override
  Future<AttendanceSubmissionModel> approve(int id) async {
    final response =
        await _apiClient.post<Map<String, dynamic>>('$_base/$id/approve');
    return AttendanceSubmissionModel.fromJson(response.data!);
  }

  @override
  Future<AttendanceSubmissionModel> reject(int id, String? note) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '$_base/$id/reject',
      data: {'note': note},
    );
    return AttendanceSubmissionModel.fromJson(response.data!);
  }
}

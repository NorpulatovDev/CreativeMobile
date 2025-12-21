import 'package:intl/intl.dart';

import '../../../../core/api/api_client.dart';
import '../models/attendance_model.dart';

abstract class AttendanceRemoteDataSource {
  Future<List<AttendanceModel>> createForGroup(AttendanceRequest request);
  Future<AttendanceModel> getById(int id);
  Future<List<AttendanceModel>> getByGroupAndDate(int groupId, DateTime date);
  Future<List<AttendanceModel>> getByMonth(int year, int month);
  Future<List<AttendanceModel>> getByGroupIdAndMonth(int groupId, int year, int month);
  Future<List<AttendanceModel>> getByStudentIdAndMonth(int studentId, int year, int month);
  Future<List<AttendanceModel>> getByStudentIdAndGroupIdAndMonth(int studentId, int groupId, int year, int month);
  Future<AttendanceModel> update(int id, AttendanceUpdateRequest request);
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final ApiClient _apiClient;
  final _dateFormat = DateFormat('yyyy-MM-dd');

  AttendanceRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<AttendanceModel>> createForGroup(AttendanceRequest request) async {
    final response = await _apiClient.post<List<dynamic>>(
      '/api/attendances',
      data: request.toJson(),
    );
    return (response.data ?? [])
        .map((json) => AttendanceModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AttendanceModel> getById(int id) async {
    final response =
        await _apiClient.get<Map<String, dynamic>>('/api/attendances/$id');
    return AttendanceModel.fromJson(response.data!);
  }

  @override
  Future<List<AttendanceModel>> getByGroupAndDate(int groupId, DateTime date) async {
    final dateStr = _dateFormat.format(date);
    final response = await _apiClient
        .get<List<dynamic>>('/api/attendances/group/$groupId/date/$dateStr');
    return (response.data ?? [])
        .map((json) => AttendanceModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<AttendanceModel>> getByMonth(int year, int month) async {
    final response = await _apiClient
        .get<List<dynamic>>('/api/attendances/month/$year/$month');
    return (response.data ?? [])
        .map((json) => AttendanceModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<AttendanceModel>> getByGroupIdAndMonth(
      int groupId, int year, int month) async {
    final response = await _apiClient
        .get<List<dynamic>>('/api/attendances/group/$groupId/month/$year/$month');
    return (response.data ?? [])
        .map((json) => AttendanceModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<AttendanceModel>> getByStudentIdAndMonth(
      int studentId, int year, int month) async {
    final response = await _apiClient
        .get<List<dynamic>>('/api/attendances/student/$studentId/month/$year/$month');
    return (response.data ?? [])
        .map((json) => AttendanceModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<AttendanceModel>> getByStudentIdAndGroupIdAndMonth(
      int studentId, int groupId, int year, int month) async {
    final response = await _apiClient
        .get<List<dynamic>>('/api/attendances/student/$studentId/group/$groupId/month/$year/$month');
    return (response.data ?? [])
        .map((json) => AttendanceModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AttendanceModel> update(int id, AttendanceUpdateRequest request) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      '/api/attendances/$id',
      data: request.toJson(),
    );
    return AttendanceModel.fromJson(response.data!);
  }
}
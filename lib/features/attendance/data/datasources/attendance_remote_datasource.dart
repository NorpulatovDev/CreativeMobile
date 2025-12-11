import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_constants.dart';
import '../models/models.dart';

abstract class AttendanceRemoteDataSource {
  Future<List<Attendance>> createForGroup(AttendanceRequest request);
  Future<List<Attendance>> getByGroupAndDate(int groupId, DateTime date);
  Future<List<Attendance>> getByGroupAndMonth(int groupId, int year, int month);
  Future<List<Attendance>> getByStudentAndMonth(int studentId, int year, int month);
  Future<Attendance> updateStatus(int id, AttendanceUpdateRequest request);
}

@LazySingleton(as: AttendanceRemoteDataSource)
class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final Dio _dio;

  AttendanceRemoteDataSourceImpl(this._dio);

  @override
  Future<List<Attendance>> createForGroup(AttendanceRequest request) async {
    final response = await _dio.post(
      ApiConstants.attendances,
      data: {
        'groupId': request.groupId,
        'date': request.date.toIso8601String().split('T')[0],
        'absentStudentIds': request.absentStudentIds ?? [],
      },
    );
    return (response.data as List)
        .map((json) => Attendance.fromJson(json))
        .toList();
  }

  @override
  Future<List<Attendance>> getByGroupAndDate(int groupId, DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];
    final response = await _dio.get(
      '${ApiConstants.attendances}/group/$groupId/date/$dateStr',
    );
    return (response.data as List)
        .map((json) => Attendance.fromJson(json))
        .toList();
  }

  @override
  Future<List<Attendance>> getByGroupAndMonth(int groupId, int year, int month) async {
    final response = await _dio.get(
      '${ApiConstants.attendances}/group/$groupId/month/$year/$month',
    );
    return (response.data as List)
        .map((json) => Attendance.fromJson(json))
        .toList();
  }

  @override
  Future<List<Attendance>> getByStudentAndMonth(int studentId, int year, int month) async {
    final response = await _dio.get(
      '${ApiConstants.attendances}/student/$studentId/month/$year/$month',
    );
    return (response.data as List)
        .map((json) => Attendance.fromJson(json))
        .toList();
  }

  @override
  Future<Attendance> updateStatus(int id, AttendanceUpdateRequest request) async {
    final response = await _dio.patch(
      '${ApiConstants.attendances}/$id',
      data: request.toJson(),
    );
    return Attendance.fromJson(response.data);
  }
}
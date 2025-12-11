import 'package:injectable/injectable.dart';
import '../datasources/attendance_remote_datasource.dart';
import '../models/models.dart';

abstract class AttendanceRepository {
  Future<List<Attendance>> createForGroup(AttendanceRequest request);
  Future<List<Attendance>> getByGroupAndDate(int groupId, DateTime date);
  Future<List<Attendance>> getByGroupAndMonth(int groupId, int year, int month);
  Future<List<Attendance>> getByStudentAndMonth(int studentId, int year, int month);
  Future<Attendance> updateStatus(int id, String status);
}

@LazySingleton(as: AttendanceRepository)
class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource _remoteDataSource;

  AttendanceRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Attendance>> createForGroup(AttendanceRequest request) =>
      _remoteDataSource.createForGroup(request);

  @override
  Future<List<Attendance>> getByGroupAndDate(int groupId, DateTime date) =>
      _remoteDataSource.getByGroupAndDate(groupId, date);

  @override
  Future<List<Attendance>> getByGroupAndMonth(int groupId, int year, int month) =>
      _remoteDataSource.getByGroupAndMonth(groupId, year, month);

  @override
  Future<List<Attendance>> getByStudentAndMonth(int studentId, int year, int month) =>
      _remoteDataSource.getByStudentAndMonth(studentId, year, month);

  @override
  Future<Attendance> updateStatus(int id, String status) =>
      _remoteDataSource.updateStatus(id, AttendanceUpdateRequest(status: status));
}
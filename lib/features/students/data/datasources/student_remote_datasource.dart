import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_constants.dart';
import '../models/models.dart';

abstract class StudentRemoteDataSource {
  Future<List<Student>> getAll();
  Future<List<Student>> getByGroupId(int groupId);
  Future<Student> getById(int id);
  Future<Student> create(StudentRequest request);
  Future<Student> update(int id, StudentRequest request);
  Future<Student> assignToGroup(int studentId, int groupId);
  Future<Student> removeFromGroup(int studentId);
}

@LazySingleton(as: StudentRemoteDataSource)
class StudentRemoteDataSourceImpl implements StudentRemoteDataSource {
  final Dio _dio;

  StudentRemoteDataSourceImpl(this._dio);

  @override
  Future<List<Student>> getAll() async {
    final response = await _dio.get(ApiConstants.students);
    return (response.data as List)
        .map((json) => Student.fromJson(json))
        .toList();
  }

  @override
  Future<List<Student>> getByGroupId(int groupId) async {
    final response = await _dio.get('${ApiConstants.students}/group/$groupId');
    return (response.data as List)
        .map((json) => Student.fromJson(json))
        .toList();
  }

  @override
  Future<Student> getById(int id) async {
    final response = await _dio.get('${ApiConstants.students}/$id');
    return Student.fromJson(response.data);
  }

  @override
  Future<Student> create(StudentRequest request) async {
    final response = await _dio.post(
      ApiConstants.students,
      data: request.toJson(),
    );
    return Student.fromJson(response.data);
  }

  @override
  Future<Student> update(int id, StudentRequest request) async {
    final response = await _dio.put(
      '${ApiConstants.students}/$id',
      data: request.toJson(),
    );
    return Student.fromJson(response.data);
  }

  @override
  Future<Student> assignToGroup(int studentId, int groupId) async {
    final response = await _dio.patch(
      '${ApiConstants.students}/$studentId/assign-group/$groupId',
    );
    return Student.fromJson(response.data);
  }

  @override
  Future<Student> removeFromGroup(int studentId) async {
    final response = await _dio.patch(
      '${ApiConstants.students}/$studentId/remove-from-group',
    );
    return Student.fromJson(response.data);
  }
}
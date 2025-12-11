import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_constants.dart';
import '../models/models.dart';

abstract class TeacherRemoteDataSource {
  Future<List<Teacher>> getAll();
  Future<Teacher> getById(int id);
  Future<Teacher> create(TeacherRequest request);
  Future<Teacher> update(int id, TeacherRequest request);
  Future<void> delete(int id);
}

@LazySingleton(as: TeacherRemoteDataSource)
class TeacherRemoteDataSourceImpl implements TeacherRemoteDataSource {
  final Dio _dio;

  TeacherRemoteDataSourceImpl(this._dio);

  @override
  Future<List<Teacher>> getAll() async {
    final response = await _dio.get(ApiConstants.teachers);
    return (response.data as List)
        .map((json) => Teacher.fromJson(json))
        .toList();
  }

  @override
  Future<Teacher> getById(int id) async {
    final response = await _dio.get('${ApiConstants.teachers}/$id');
    return Teacher.fromJson(response.data);
  }

  @override
  Future<Teacher> create(TeacherRequest request) async {
    final response = await _dio.post(
      ApiConstants.teachers,
      data: request.toJson(),
    );
    return Teacher.fromJson(response.data);
  }

  @override
  Future<Teacher> update(int id, TeacherRequest request) async {
    final response = await _dio.put(
      '${ApiConstants.teachers}/$id',
      data: request.toJson(),
    );
    return Teacher.fromJson(response.data);
  }

  @override
  Future<void> delete(int id) async {
    await _dio.delete('${ApiConstants.teachers}/$id');
  }
}
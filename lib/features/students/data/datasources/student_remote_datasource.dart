import 'package:dio/dio.dart';
import '../../../../core/network/api_constants.dart';
import '../models/student.dart';
import '../models/student_group.dart';

class StudentRemoteDataSource {
  final Dio dio;

  StudentRemoteDataSource(this.dio);

  /// GET /api/students
  Future<List<Student>> getAll() async {
    final response = await dio.get(ApiConstants.students);
    final list = response.data as List;
    return list.map((json) => Student.fromJson(json)).toList();
  }

  /// GET /api/students/{id}
  Future<Student> getById(int id) async {
    final response = await dio.get('${ApiConstants.students}/$id');
    return Student.fromJson(response.data);
  }

  /// GET /api/students/group/{groupId}
  Future<List<Student>> getByGroupId(int groupId) async {
    final response = await dio.get('${ApiConstants.students}/group/$groupId');
    final list = response.data as List;
    return list.map((json) => Student.fromJson(json)).toList();
  }

  /// POST /api/students
  Future<Student> create(StudentRequest request) async {
    final response = await dio.post(
      ApiConstants.students,
      data: request.toJson(),
    );
    return Student.fromJson(response.data);
  }

  /// PUT /api/students/{id}
  Future<Student> update(int id, StudentRequest request) async {
    final response = await dio.put(
      '${ApiConstants.students}/$id',
      data: request.toJson(),
    );
    return Student.fromJson(response.data);
  }

  /// POST /api/enrollments
  Future<StudentGroup> addToGroup(StudentGroupRequest request) async {
    final response = await dio.post(
      ApiConstants.enrollments,
      data: request.toJson(),
    );
    return StudentGroup.fromJson(response.data);
  }

  /// DELETE /api/enrollments/student/{studentId}/group/{groupId}
  Future<void> removeFromGroup(int studentId, int groupId) async {
    await dio.delete(
      '${ApiConstants.enrollments}/student/$studentId/group/$groupId',
    );
  }

  /// GET /api/enrollments/student/{studentId}
  Future<List<StudentGroup>> getStudentGroups(int studentId) async {
    final response = await dio.get(
      '${ApiConstants.enrollments}/student/$studentId',
    );
    final list = response.data as List;
    return list.map((json) => StudentGroup.fromJson(json)).toList();
  }

  /// GET /api/enrollments/student/{studentId}/active
  Future<List<StudentGroup>> getStudentActiveGroups(int studentId) async {
    final response = await dio.get(
      '${ApiConstants.enrollments}/student/$studentId/active',
    );
    final list = response.data as List;
    return list.map((json) => StudentGroup.fromJson(json)).toList();
  }

  /// GET /api/enrollments/group/{groupId}
  Future<List<StudentGroup>> getGroupStudents(int groupId) async {
    final response = await dio.get(
      '${ApiConstants.enrollments}/group/$groupId',
    );
    final list = response.data as List;
    return list.map((json) => StudentGroup.fromJson(json)).toList();
  }
}
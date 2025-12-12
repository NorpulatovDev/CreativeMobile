import '../datasources/student_remote_datasource.dart';
import '../models/student.dart';
import '../models/student_group.dart';

class StudentRepository {
  final StudentRemoteDataSource dataSource;

  StudentRepository(this.dataSource);

  Future<List<Student>> getAll() {
    return dataSource.getAll();
  }

  Future<Student> getById(int id) {
    return dataSource.getById(id);
  }

  Future<List<Student>> getByGroupId(int groupId) {
    return dataSource.getByGroupId(groupId);
  }

  Future<Student> create(StudentRequest request) {
    return dataSource.create(request);
  }

  Future<Student> update(int id, StudentRequest request) {
    return dataSource.update(id, request);
  }

  Future<StudentGroup> addToGroup(StudentGroupRequest request) {
    return dataSource.addToGroup(request);
  }

  Future<void> removeFromGroup(int studentId, int groupId) {
    return dataSource.removeFromGroup(studentId, groupId);
  }

  Future<List<StudentGroup>> getStudentGroups(int studentId) {
    return dataSource.getStudentGroups(studentId);
  }

  Future<List<StudentGroup>> getStudentActiveGroups(int studentId) {
    return dataSource.getStudentActiveGroups(studentId);
  }

  Future<List<StudentGroup>> getGroupStudents(int groupId) {
    return dataSource.getGroupStudents(groupId);
  }
}
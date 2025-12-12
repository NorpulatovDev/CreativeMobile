import '../../data/models/student.dart';
import '../../data/models/student_group.dart';

abstract class StudentEvent {}

class LoadStudents extends StudentEvent {}

class LoadStudentDetail extends StudentEvent {
  final int studentId;
  LoadStudentDetail(this.studentId);
}

class CreateStudent extends StudentEvent {
  final StudentRequest request;
  CreateStudent(this.request);
}

class UpdateStudent extends StudentEvent {
  final int id;
  final StudentRequest request;
  UpdateStudent(this.id, this.request);
}

class AddStudentToGroup extends StudentEvent {
  final int studentId;
  final int groupId;
  AddStudentToGroup(this.studentId, this.groupId);
}

class RemoveStudentFromGroup extends StudentEvent {
  final int studentId;
  final int groupId;
  RemoveStudentFromGroup(this.studentId, this.groupId);
}
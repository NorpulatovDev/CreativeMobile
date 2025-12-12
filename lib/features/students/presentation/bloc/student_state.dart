import '../../data/models/student.dart';
import '../../data/models/student_group.dart';

abstract class StudentState {}

class StudentInitial extends StudentState {}

class StudentLoading extends StudentState {}

class StudentsLoaded extends StudentState {
  final List<Student> students;
  StudentsLoaded(this.students);
}

class StudentDetailLoaded extends StudentState {
  final Student student;
  final List<StudentGroup> enrollments;
  StudentDetailLoaded(this.student, this.enrollments);
}

class StudentOperationSuccess extends StudentState {
  final String message;
  StudentOperationSuccess(this.message);
}

class StudentError extends StudentState {
  final String message;
  StudentError(this.message);
}
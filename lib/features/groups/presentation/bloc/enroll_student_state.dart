part of 'enroll_student_cubit.dart';

sealed class EnrollStudentState extends Equatable {
  const EnrollStudentState();

  @override
  List<Object?> get props => [];
}

class EnrollStudentIdle extends EnrollStudentState {
  const EnrollStudentIdle();
}

class EnrollStudentSearching extends EnrollStudentState {
  const EnrollStudentSearching();
}

class EnrollStudentResults extends EnrollStudentState {
  final List<StudentModel> students;
  final String query;

  const EnrollStudentResults({required this.students, required this.query});

  @override
  List<Object?> get props => [students, query];
}

class EnrollStudentEnrolling extends EnrollStudentState {
  const EnrollStudentEnrolling();
}

class EnrollStudentSuccess extends EnrollStudentState {
  const EnrollStudentSuccess();
}

class EnrollStudentError extends EnrollStudentState {
  final String message;

  const EnrollStudentError(this.message);

  @override
  List<Object?> get props => [message];
}

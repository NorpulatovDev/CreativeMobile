import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/student_group.dart';
import '../../data/repositories/student_repository.dart';
import 'student_event.dart';
import 'student_state.dart';

class StudentBloc extends Bloc<StudentEvent, StudentState> {
  final StudentRepository repository;

  StudentBloc(this.repository) : super(StudentInitial()) {
    on<LoadStudents>(_onLoadStudents);
    on<LoadStudentDetail>(_onLoadStudentDetail);
    on<CreateStudent>(_onCreateStudent);
    on<UpdateStudent>(_onUpdateStudent);
    on<AddStudentToGroup>(_onAddStudentToGroup);
    on<RemoveStudentFromGroup>(_onRemoveStudentFromGroup);
  }

  Future<void> _onLoadStudents(
    LoadStudents event,
    Emitter<StudentState> emit,
  ) async {
    emit(StudentLoading());
    try {
      final students = await repository.getAll();
      emit(StudentsLoaded(students));
    } catch (e) {
      emit(StudentError(e.toString()));
    }
  }

  Future<void> _onLoadStudentDetail(
    LoadStudentDetail event,
    Emitter<StudentState> emit,
  ) async {
    emit(StudentLoading());
    try {
      final student = await repository.getById(event.studentId);
      final enrollments = await repository.getStudentGroups(event.studentId);
      emit(StudentDetailLoaded(student, enrollments));
    } catch (e) {
      emit(StudentError(e.toString()));
    }
  }

  Future<void> _onCreateStudent(
    CreateStudent event,
    Emitter<StudentState> emit,
  ) async {
    emit(StudentLoading());
    try {
      await repository.create(event.request);
      emit(StudentOperationSuccess('Student created successfully'));
      add(LoadStudents());
    } catch (e) {
      emit(StudentError(e.toString()));
    }
  }

  Future<void> _onUpdateStudent(
    UpdateStudent event,
    Emitter<StudentState> emit,
  ) async {
    emit(StudentLoading());
    try {
      await repository.update(event.id, event.request);
      emit(StudentOperationSuccess('Student updated successfully'));
      add(LoadStudents());
    } catch (e) {
      emit(StudentError(e.toString()));
    }
  }

  Future<void> _onAddStudentToGroup(
    AddStudentToGroup event,
    Emitter<StudentState> emit,
  ) async {
    try {
      final request = StudentGroupRequest(
        studentId: event.studentId,
        groupId: event.groupId,
      );
      await repository.addToGroup(request);
      emit(StudentOperationSuccess('Student added to group'));
      add(LoadStudentDetail(event.studentId));
    } catch (e) {
      emit(StudentError(e.toString()));
    }
  }

  Future<void> _onRemoveStudentFromGroup(
    RemoveStudentFromGroup event,
    Emitter<StudentState> emit,
  ) async {
    try {
      await repository.removeFromGroup(event.studentId, event.groupId);
      emit(StudentOperationSuccess('Student removed from group'));
      add(LoadStudentDetail(event.studentId));
    } catch (e) {
      emit(StudentError(e.toString()));
    }
  }
}
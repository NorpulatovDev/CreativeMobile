import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../enrollments/data/datasources/enrollment_local_datasource.dart';
import '../../../enrollments/data/repositories/enrollment_repository.dart';
import '../../../students/data/models/student_model.dart';
import '../../../students/data/repositories/student_repository.dart';

part 'enroll_student_state.dart';

class EnrollStudentCubit extends Cubit<EnrollStudentState> {
  final StudentRepository _studentRepo;
  final EnrollmentRepository _enrollmentRepo;
  final EnrollmentLocalDataSource _enrollmentLocal;
  final int groupId;

  Timer? _debounce;

  EnrollStudentCubit({
    required StudentRepository studentRepo,
    required EnrollmentRepository enrollmentRepo,
    required EnrollmentLocalDataSource enrollmentLocal,
    required this.groupId,
  })  : _studentRepo = studentRepo,
        _enrollmentRepo = enrollmentRepo,
        _enrollmentLocal = enrollmentLocal,
        super(const EnrollStudentIdle());

  void search(String query) {
    _debounce?.cancel();
    if (query.trim().length < 2) {
      emit(const EnrollStudentIdle());
      return;
    }
    emit(const EnrollStudentSearching());
    _debounce = Timer(
      const Duration(milliseconds: 300),
      () => _doSearch(query.trim()),
    );
  }

  Future<void> _doSearch(String query) async {
    final (result, failure) = await _studentRepo.search(query, 0, 20);
    if (isClosed) return;
    if (failure != null) {
      emit(EnrollStudentError(failure.message));
      return;
    }
    final enrolledIds = _enrollmentLocal
        .getGroupStudents(groupId)
        .map((e) => e.studentId)
        .toSet();
    final students = (result?.content ?? [])
        .where((s) => !enrolledIds.contains(s.id))
        .toList();
    emit(EnrollStudentResults(students: students, query: query));
  }

  Future<void> enroll(int studentId) async {
    emit(const EnrollStudentEnrolling());
    final (_, failure) =
        await _enrollmentRepo.addStudentToGroup(studentId, groupId);
    if (isClosed) return;
    if (failure != null) {
      emit(EnrollStudentError(failure.message));
      return;
    }
    emit(const EnrollStudentSuccess());
  }

  Future<void> createAndEnroll(StudentRequest request) async {
    emit(const EnrollStudentEnrolling());
    final (student, createFailure) = await _studentRepo.create(request);
    if (isClosed) return;
    if (createFailure != null) {
      emit(EnrollStudentError(createFailure.message));
      return;
    }
    final (_, enrollFailure) =
        await _enrollmentRepo.addStudentToGroup(student!.id, groupId);
    if (isClosed) return;
    if (enrollFailure != null) {
      emit(EnrollStudentError(enrollFailure.message));
      return;
    }
    emit(const EnrollStudentSuccess());
  }

  void reset() {
    _debounce?.cancel();
    emit(const EnrollStudentIdle());
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}

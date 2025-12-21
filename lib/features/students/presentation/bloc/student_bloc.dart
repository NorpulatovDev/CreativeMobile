import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../enrollments/data/repositories/enrollment_repository.dart';
import '../../data/models/student_model.dart';
import '../../data/repositories/student_repository.dart';

// Events
abstract class StudentEvent extends Equatable {
  const StudentEvent();

  @override
  List<Object?> get props => [];
}

class StudentLoadAll extends StudentEvent {}

class StudentLoadByGroup extends StudentEvent {
  final int groupId;

  const StudentLoadByGroup(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class StudentCreate extends StudentEvent {
  final String fullName;
  final String parentName;
  final String parentPhoneNumber;

  const StudentCreate({
    required this.fullName,
    required this.parentName,
    required this.parentPhoneNumber,
  });

  @override
  List<Object?> get props => [fullName, parentName, parentPhoneNumber];
}

class StudentCreateWithGroup extends StudentEvent {
  final String fullName;
  final String parentName;
  final String parentPhoneNumber;
  final int? groupId;

  const StudentCreateWithGroup({
    required this.fullName,
    required this.parentName,
    required this.parentPhoneNumber,
    this.groupId,
  });

  @override
  List<Object?> get props => [fullName, parentName, parentPhoneNumber, groupId];
}

class StudentUpdate extends StudentEvent {
  final int id;
  final String fullName;
  final String parentName;
  final String parentPhoneNumber;

  const StudentUpdate({
    required this.id,
    required this.fullName,
    required this.parentName,
    required this.parentPhoneNumber,
  });

  @override
  List<Object?> get props => [id, fullName, parentName, parentPhoneNumber];
}

// States
abstract class StudentState extends Equatable {
  const StudentState();

  @override
  List<Object?> get props => [];
}

class StudentInitial extends StudentState {}

class StudentLoading extends StudentState {}

class StudentLoaded extends StudentState {
  final List<StudentModel> students;

  const StudentLoaded(this.students);

  @override
  List<Object?> get props => [students];
}

class StudentError extends StudentState {
  final String message;

  const StudentError(this.message);

  @override
  List<Object?> get props => [message];
}

class StudentActionSuccess extends StudentState {
  final String message;

  const StudentActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class StudentBloc extends Bloc<StudentEvent, StudentState> {
  final StudentRepository _repository;
  List<StudentModel> _students = [];

  StudentBloc(this._repository) : super(StudentInitial()) {
    on<StudentLoadAll>(_onLoadAll);
    on<StudentLoadByGroup>(_onLoadByGroup);
    on<StudentCreate>(_onCreate);
    on<StudentCreateWithGroup>(_onCreateWithGroup);
    on<StudentUpdate>(_onUpdate);
  }

  Future<void> _onLoadAll(
    StudentLoadAll event,
    Emitter<StudentState> emit,
  ) async {
    emit(StudentLoading());
    final (students, failure) = await _repository.getAll();
    if (failure != null) {
      emit(StudentError(failure.message));
    } else {
      _students = students ?? [];
      emit(StudentLoaded(_students));
    }
  }

  Future<void> _onLoadByGroup(
    StudentLoadByGroup event,
    Emitter<StudentState> emit,
  ) async {
    emit(StudentLoading());
    final (students, failure) = await _repository.getByGroupId(event.groupId);
    if (failure != null) {
      emit(StudentError(failure.message));
    } else {
      _students = students ?? [];
      emit(StudentLoaded(_students));
    }
  }

  Future<void> _onCreate(
    StudentCreate event,
    Emitter<StudentState> emit,
  ) async {
    emit(StudentLoading());
    final (student, failure) = await _repository.create(
      StudentRequest(
        fullName: event.fullName,
        parentName: event.parentName,
        parentPhoneNumber: event.parentPhoneNumber,
      ),
    );
    if (failure != null) {
      emit(StudentError(failure.message));
      emit(StudentLoaded(_students));
    } else {
      _students = [..._students, student!];
      emit(const StudentActionSuccess('Student created successfully'));
      emit(StudentLoaded(_students));
    }
  }

  Future<void> _onCreateWithGroup(
    StudentCreateWithGroup event,
    Emitter<StudentState> emit,
  ) async {
    emit(StudentLoading());
    final (student, failure) = await _repository.create(
      StudentRequest(
        fullName: event.fullName,
        parentName: event.parentName,
        parentPhoneNumber: event.parentPhoneNumber,
      ),
    );
    if (failure != null) {
      emit(StudentError(failure.message));
      emit(StudentLoaded(_students));
      return;
    }

    // Enroll in group if specified
    if (event.groupId != null) {
      final enrollmentRepo = getIt<EnrollmentRepository>();
      final (_, enrollFailure) = await enrollmentRepo.addStudentToGroup(
        student!.id,
        event.groupId!,
      );
      if (enrollFailure != null) {
        // Student created but enrollment failed
        _students = [..._students, student];
        emit(StudentActionSuccess(
            'Student created but enrollment failed: ${enrollFailure.message}'));
        emit(StudentLoaded(_students));
        return;
      }
    }

    // Reload to get updated student with group info
    final (updatedStudent, _) = await _repository.getById(student!.id);
    if (updatedStudent != null) {
      _students = [..._students, updatedStudent];
    } else {
      _students = [..._students, student];
    }

    final message = event.groupId != null
        ? 'Student created and enrolled successfully'
        : 'Student created successfully';
    emit(StudentActionSuccess(message));
    emit(StudentLoaded(_students));
  }

  Future<void> _onUpdate(
    StudentUpdate event,
    Emitter<StudentState> emit,
  ) async {
    emit(StudentLoading());
    final (student, failure) = await _repository.update(
      event.id,
      StudentRequest(
        fullName: event.fullName,
        parentName: event.parentName,
        parentPhoneNumber: event.parentPhoneNumber,
      ),
    );
    if (failure != null) {
      emit(StudentError(failure.message));
      emit(StudentLoaded(_students));
    } else {
      _students =
          _students.map((s) => s.id == event.id ? student! : s).toList();
      emit(const StudentActionSuccess('Student updated successfully'));
      emit(StudentLoaded(_students));
    }
  }
}
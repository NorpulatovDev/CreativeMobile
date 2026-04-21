import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../enrollments/data/repositories/enrollment_repository.dart';
import '../../data/models/student_model.dart';
import '../../data/repositories/student_repository.dart';

// ignore_for_file: constant_identifier_names
const _kPageSize = 20;

// Events
abstract class StudentEvent extends Equatable {
  const StudentEvent();

  @override
  List<Object?> get props => [];
}

class StudentLoadAll extends StudentEvent {}

class StudentSearch extends StudentEvent {
  final String query;
  const StudentSearch(this.query);
  @override
  List<Object?> get props => [query];
}

class StudentLoadMore extends StudentEvent {}

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

class StudentDelete extends StudentEvent {
  final int id;

  const StudentDelete(this.id);

  @override
  List<Object?> get props => [id];
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
  final bool hasMore;
  final bool isLoadingMore;

  const StudentLoaded(this.students, {this.hasMore = false, this.isLoadingMore = false});

  @override
  List<Object?> get props => [students, hasMore, isLoadingMore];
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
  String _currentQuery = '';
  int _currentPage = 0;
  bool _hasMore = false;

  StudentBloc(this._repository) : super(StudentInitial()) {
    on<StudentLoadAll>(_onLoadAll);
    on<StudentSearch>(_onSearch);
    on<StudentLoadMore>(_onLoadMore);
    on<StudentLoadByGroup>(_onLoadByGroup);
    on<StudentCreate>(_onCreate);
    on<StudentCreateWithGroup>(_onCreateWithGroup);
    on<StudentUpdate>(_onUpdate);
    on<StudentDelete>(_onDelete);
  }

  Future<void> _onSearch(
    StudentSearch event,
    Emitter<StudentState> emit,
  ) async {
    _currentQuery = event.query;
    _currentPage = 0;
    emit(StudentLoading());
    final (result, failure) = await _repository.search(event.query, 0, _kPageSize);
    if (failure != null) {
      emit(StudentError(failure.message));
    } else {
      _students = result?.content ?? [];
      _hasMore = (_currentPage + 1) < (result?.totalPages ?? 0);
      _currentPage = 1;
      emit(StudentLoaded(_students, hasMore: _hasMore));
    }
  }

  Future<void> _onLoadMore(
    StudentLoadMore event,
    Emitter<StudentState> emit,
  ) async {
    if (!_hasMore) return;
    final current = state;
    if (current is StudentLoaded && current.isLoadingMore) return;
    emit(StudentLoaded(_students, hasMore: _hasMore, isLoadingMore: true));
    final (result, failure) = await _repository.search(_currentQuery, _currentPage, _kPageSize);
    if (failure != null) {
      emit(StudentLoaded(_students, hasMore: _hasMore));
    } else {
      _students = [..._students, ...(result?.content ?? [])];
      _hasMore = (_currentPage + 1) < (result?.totalPages ?? 0);
      _currentPage++;
      emit(StudentLoaded(_students, hasMore: _hasMore));
    }
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
      _hasMore = false;
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
      _hasMore = false;
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
      emit(StudentLoaded(_students, hasMore: _hasMore));
    } else {
      _students = [..._students, student!];
      emit(const StudentActionSuccess('O\'quvchi muvaffaqiyatli qo\'shildi'));
      emit(StudentLoaded(_students, hasMore: _hasMore));
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
      emit(StudentLoaded(_students, hasMore: _hasMore));
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
        _students = [..._students, student];
        emit(StudentActionSuccess(
            'O\'quvchi qo\'shildi, lekin guruhga qo\'shib bo\'lmadi: ${enrollFailure.message}'));
        emit(StudentLoaded(_students, hasMore: _hasMore));
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
        ? 'O\'quvchi qo\'shildi va guruhga birlashtrildi'
        : 'O\'quvchi muvaffaqiyatli qo\'shildi';
    emit(StudentActionSuccess(message));
    emit(StudentLoaded(_students, hasMore: _hasMore));
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
      emit(StudentLoaded(_students, hasMore: _hasMore));
    } else {
      _students =
          _students.map((s) => s.id == event.id ? student! : s).toList();
      emit(const StudentActionSuccess('O\'quvchi muvaffaqiyatli yangilandi'));
      emit(StudentLoaded(_students, hasMore: _hasMore));
    }
  }

  Future<void> _onDelete(
    StudentDelete event,
    Emitter<StudentState> emit,
  ) async {
    emit(StudentLoading());
    final failure = await _repository.delete(event.id);
    if (failure != null) {
      emit(StudentError(failure.message));
      emit(StudentLoaded(_students, hasMore: _hasMore));
    } else {
      _students = _students.where((s) => s.id != event.id).toList();
      emit(const StudentActionSuccess('O\'quvchi va barcha ma\'lumotlari o\'chirildi'));
      emit(StudentLoaded(_students, hasMore: _hasMore));
    }
  }
}

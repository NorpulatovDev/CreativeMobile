import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/teacher_model.dart';
import '../../data/repositories/teacher_repository.dart';

// Events
abstract class TeacherEvent extends Equatable {
  const TeacherEvent();

  @override
  List<Object?> get props => [];
}

class TeacherLoadAll extends TeacherEvent {}

class TeacherCreate extends TeacherEvent {
  final String fullName;
  final String phoneNumber;

  const TeacherCreate({required this.fullName, required this.phoneNumber});

  @override
  List<Object?> get props => [fullName, phoneNumber];
}

class TeacherUpdate extends TeacherEvent {
  final int id;
  final String fullName;
  final String phoneNumber;

  const TeacherUpdate({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [id, fullName, phoneNumber];
}

class TeacherDelete extends TeacherEvent {
  final int id;

  const TeacherDelete(this.id);

  @override
  List<Object?> get props => [id];
}

// States
abstract class TeacherState extends Equatable {
  const TeacherState();

  @override
  List<Object?> get props => [];
}

class TeacherInitial extends TeacherState {}

class TeacherLoading extends TeacherState {}

class TeacherLoaded extends TeacherState {
  final List<TeacherModel> teachers;

  const TeacherLoaded(this.teachers);

  @override
  List<Object?> get props => [teachers];
}

class TeacherError extends TeacherState {
  final String message;

  const TeacherError(this.message);

  @override
  List<Object?> get props => [message];
}

class TeacherActionSuccess extends TeacherState {
  final String message;

  const TeacherActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class TeacherBloc extends Bloc<TeacherEvent, TeacherState> {
  final TeacherRepository _repository;
  List<TeacherModel> _teachers = [];

  TeacherBloc(this._repository) : super(TeacherInitial()) {
    on<TeacherLoadAll>(_onLoadAll);
    on<TeacherCreate>(_onCreate);
    on<TeacherUpdate>(_onUpdate);
    on<TeacherDelete>(_onDelete);
  }

  Future<void> _onLoadAll(
    TeacherLoadAll event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherLoading());
    final (teachers, failure) = await _repository.getAll();
    if (failure != null) {
      emit(TeacherError(failure.message));
    } else {
      _teachers = teachers ?? [];
      emit(TeacherLoaded(_teachers));
    }
  }

  Future<void> _onCreate(
    TeacherCreate event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherLoading());
    final (teacher, failure) = await _repository.create(
      TeacherRequest(fullName: event.fullName, phoneNumber: event.phoneNumber),
    );
    if (failure != null) {
      emit(TeacherError(failure.message));
      emit(TeacherLoaded(_teachers));
    } else {
      _teachers = [..._teachers, teacher!];
      emit(const TeacherActionSuccess('Teacher created successfully'));
      emit(TeacherLoaded(_teachers));
    }
  }

  Future<void> _onUpdate(
    TeacherUpdate event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherLoading());
    final (teacher, failure) = await _repository.update(
      event.id,
      TeacherRequest(fullName: event.fullName, phoneNumber: event.phoneNumber),
    );
    if (failure != null) {
      emit(TeacherError(failure.message));
      emit(TeacherLoaded(_teachers));
    } else {
      _teachers = _teachers.map((t) => t.id == event.id ? teacher! : t).toList();
      emit(const TeacherActionSuccess('Teacher updated successfully'));
      emit(TeacherLoaded(_teachers));
    }
  }

  Future<void> _onDelete(
    TeacherDelete event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherLoading());
    final failure = await _repository.delete(event.id);
    if (failure != null) {
      emit(TeacherError(failure.message));
      emit(TeacherLoaded(_teachers));
    } else {
      _teachers = _teachers.where((t) => t.id != event.id).toList();
      emit(const TeacherActionSuccess('Teacher deleted successfully'));
      emit(TeacherLoaded(_teachers));
    }
  }
}
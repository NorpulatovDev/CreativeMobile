import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import '../../data/models/models.dart';
import '../../data/repositories/teacher_repository.dart';

part 'teacher_bloc.freezed.dart';

// Events
@freezed
class TeacherEvent with _$TeacherEvent {
  const factory TeacherEvent.loadAll() = TeacherLoadAll;
  const factory TeacherEvent.create({
    required String fullName,
    required String phoneNumber,
  }) = TeacherCreate;
  const factory TeacherEvent.update({
    required int id,
    required String fullName,
    required String phoneNumber,
  }) = TeacherUpdate;
  const factory TeacherEvent.delete({required int id}) = TeacherDelete;
}

// States
@freezed
class TeacherState with _$TeacherState {
  const factory TeacherState.initial() = TeacherInitial;
  const factory TeacherState.loading() = TeacherLoading;
  const factory TeacherState.loaded({required List<Teacher> teachers}) = TeacherLoaded;
  const factory TeacherState.error({required String message}) = TeacherError;
}

// Bloc
@injectable
class TeacherBloc extends Bloc<TeacherEvent, TeacherState> {
  final TeacherRepository _repository;

  TeacherBloc(this._repository) : super(const TeacherState.initial()) {
    on<TeacherLoadAll>(_onLoadAll);
    on<TeacherCreate>(_onCreate);
    on<TeacherUpdate>(_onUpdate);
    on<TeacherDelete>(_onDelete);
  }

  Future<void> _onLoadAll(
    TeacherLoadAll event,
    Emitter<TeacherState> emit,
  ) async {
    emit(const TeacherState.loading());
    try {
      final teachers = await _repository.getAll();
      emit(TeacherState.loaded(teachers: teachers));
    } catch (e) {
      emit(TeacherState.error(message: e.toString()));
    }
  }

  Future<void> _onCreate(
    TeacherCreate event,
    Emitter<TeacherState> emit,
  ) async {
    try {
      await _repository.create(TeacherRequest(
        fullName: event.fullName,
        phoneNumber: event.phoneNumber,
      ));
      add(const TeacherLoadAll());
    } catch (e) {
      emit(TeacherState.error(message: e.toString()));
    }
  }

  Future<void> _onUpdate(
    TeacherUpdate event,
    Emitter<TeacherState> emit,
  ) async {
    try {
      await _repository.update(
        event.id,
        TeacherRequest(
          fullName: event.fullName,
          phoneNumber: event.phoneNumber,
        ),
      );
      add(const TeacherLoadAll());
    } catch (e) {
      emit(TeacherState.error(message: e.toString()));
    }
  }

  Future<void> _onDelete(
    TeacherDelete event,
    Emitter<TeacherState> emit,
  ) async {
    try {
      await _repository.delete(event.id);
      add(const TeacherLoadAll());
    } catch (e) {
      emit(TeacherState.error(message: e.toString()));
    }
  }
}
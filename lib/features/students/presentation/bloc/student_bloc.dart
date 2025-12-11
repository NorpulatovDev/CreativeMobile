import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import '../../data/models/models.dart';
import '../../data/repositories/student_repository.dart';
import '../../../groups/data/models/models.dart';
import '../../../groups/data/repositories/group_repository.dart';

part 'student_bloc.freezed.dart';

// Events
@freezed
class StudentEvent with _$StudentEvent {
  const factory StudentEvent.loadAll() = StudentLoadAll;
  const factory StudentEvent.create({
    required String fullName,
    required String parentName,
    required String parentPhoneNumber,
    int? activeGroupId,
  }) = StudentCreate;
  const factory StudentEvent.update({
    required int id,
    required String fullName,
    required String parentName,
    required String parentPhoneNumber,
    int? activeGroupId,
  }) = StudentUpdate;
  const factory StudentEvent.assignToGroup({
    required int studentId,
    required int groupId,
  }) = StudentAssignToGroup;
  const factory StudentEvent.removeFromGroup({
    required int studentId,
  }) = StudentRemoveFromGroup;
}

// States
@freezed
class StudentState with _$StudentState {
  const factory StudentState.initial() = StudentInitial;
  const factory StudentState.loading() = StudentLoading;
  const factory StudentState.loaded({
    required List<Student> students,
    required List<Group> groups,
  }) = StudentLoaded;
  const factory StudentState.error({required String message}) = StudentError;
}

// Bloc
@injectable
class StudentBloc extends Bloc<StudentEvent, StudentState> {
  final StudentRepository _studentRepository;
  final GroupRepository _groupRepository;

  StudentBloc(this._studentRepository, this._groupRepository)
      : super(const StudentState.initial()) {
    on<StudentLoadAll>(_onLoadAll);
    on<StudentCreate>(_onCreate);
    on<StudentUpdate>(_onUpdate);
    on<StudentAssignToGroup>(_onAssignToGroup);
    on<StudentRemoveFromGroup>(_onRemoveFromGroup);
  }

  Future<void> _onLoadAll(
    StudentLoadAll event,
    Emitter<StudentState> emit,
  ) async {
    emit(const StudentState.loading());
    try {
      final results = await Future.wait([
        _studentRepository.getAll(),
        _groupRepository.getAll(),
      ]);
      emit(StudentState.loaded(
        students: results[0] as List<Student>,
        groups: results[1] as List<Group>,
      ));
    } catch (e) {
      emit(StudentState.error(message: e.toString()));
    }
  }

  Future<void> _onCreate(
    StudentCreate event,
    Emitter<StudentState> emit,
  ) async {
    try {
      await _studentRepository.create(StudentRequest(
        fullName: event.fullName,
        parentName: event.parentName,
        parentPhoneNumber: event.parentPhoneNumber,
        activeGroupId: event.activeGroupId,
      ));
      add(const StudentLoadAll());
    } catch (e) {
      emit(StudentState.error(message: e.toString()));
    }
  }

  Future<void> _onUpdate(
    StudentUpdate event,
    Emitter<StudentState> emit,
  ) async {
    try {
      await _studentRepository.update(
        event.id,
        StudentRequest(
          fullName: event.fullName,
          parentName: event.parentName,
          parentPhoneNumber: event.parentPhoneNumber,
          activeGroupId: event.activeGroupId,
        ),
      );
      add(const StudentLoadAll());
    } catch (e) {
      emit(StudentState.error(message: e.toString()));
    }
  }

  Future<void> _onAssignToGroup(
    StudentAssignToGroup event,
    Emitter<StudentState> emit,
  ) async {
    try {
      await _studentRepository.assignToGroup(event.studentId, event.groupId);
      add(const StudentLoadAll());
    } catch (e) {
      emit(StudentState.error(message: e.toString()));
    }
  }

  Future<void> _onRemoveFromGroup(
    StudentRemoveFromGroup event,
    Emitter<StudentState> emit,
  ) async {
    try {
      await _studentRepository.removeFromGroup(event.studentId);
      add(const StudentLoadAll());
    } catch (e) {
      emit(StudentState.error(message: e.toString()));
    }
  }
}
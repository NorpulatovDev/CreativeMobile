import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import '../../data/models/models.dart';
import '../../data/repositories/group_repository.dart';
import '../../../teachers/data/models/models.dart';
import '../../../teachers/data/repositories/teacher_repository.dart';

part 'group_bloc.freezed.dart';

// Events
@freezed
class GroupEvent with _$GroupEvent {
  const factory GroupEvent.loadAll() = GroupLoadAll;
  const factory GroupEvent.create({
    required String name,
    required int teacherId,
    required double monthlyFee,
  }) = GroupCreate;
  const factory GroupEvent.update({
    required int id,
    required String name,
    required int teacherId,
    required double monthlyFee,
  }) = GroupUpdate;
  const factory GroupEvent.delete({required int id}) = GroupDelete;
}

// States
@freezed
class GroupState with _$GroupState {
  const factory GroupState.initial() = GroupInitial;
  const factory GroupState.loading() = GroupLoading;
  const factory GroupState.loaded({
    required List<Group> groups,
    required List<Teacher> teachers,
  }) = GroupLoaded;
  const factory GroupState.error({required String message}) = GroupError;
}

// Bloc
@injectable
class GroupBloc extends Bloc<GroupEvent, GroupState> {
  final GroupRepository _groupRepository;
  final TeacherRepository _teacherRepository;

  GroupBloc(this._groupRepository, this._teacherRepository)
      : super(const GroupState.initial()) {
    on<GroupLoadAll>(_onLoadAll);
    on<GroupCreate>(_onCreate);
    on<GroupUpdate>(_onUpdate);
    on<GroupDelete>(_onDelete);
  }

  Future<void> _onLoadAll(
    GroupLoadAll event,
    Emitter<GroupState> emit,
  ) async {
    emit(const GroupState.loading());
    try {
      final results = await Future.wait([
        _groupRepository.getAll(),
        _teacherRepository.getAll(),
      ]);
      emit(GroupState.loaded(
        groups: results[0] as List<Group>,
        teachers: results[1] as List<Teacher>,
      ));
    } catch (e) {
      emit(GroupState.error(message: e.toString()));
    }
  }

  Future<void> _onCreate(
    GroupCreate event,
    Emitter<GroupState> emit,
  ) async {
    try {
      await _groupRepository.create(GroupRequest(
        name: event.name,
        teacherId: event.teacherId,
        monthlyFee: event.monthlyFee,
      ));
      add(const GroupLoadAll());
    } catch (e) {
      emit(GroupState.error(message: e.toString()));
    }
  }

  Future<void> _onUpdate(
    GroupUpdate event,
    Emitter<GroupState> emit,
  ) async {
    try {
      await _groupRepository.update(
        event.id,
        GroupRequest(
          name: event.name,
          teacherId: event.teacherId,
          monthlyFee: event.monthlyFee,
        ),
      );
      add(const GroupLoadAll());
    } catch (e) {
      emit(GroupState.error(message: e.toString()));
    }
  }

  Future<void> _onDelete(
    GroupDelete event,
    Emitter<GroupState> emit,
  ) async {
    try {
      await _groupRepository.delete(event.id);
      add(const GroupLoadAll());
    } catch (e) {
      emit(GroupState.error(message: e.toString()));
    }
  }
}
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/group_model.dart';
import '../../data/repositories/group_repository.dart';

// Events
abstract class GroupEvent extends Equatable {
  const GroupEvent();

  @override
  List<Object?> get props => [];
}

class GroupLoadAll extends GroupEvent {}

class GroupCreate extends GroupEvent {
  final String name;
  final int teacherId;
  final double monthlyFee;

  const GroupCreate({
    required this.name,
    required this.teacherId,
    required this.monthlyFee,
  });

  @override
  List<Object?> get props => [name, teacherId, monthlyFee];
}

class GroupUpdate extends GroupEvent {
  final int id;
  final String name;
  final int teacherId;
  final double monthlyFee;

  const GroupUpdate({
    required this.id,
    required this.name,
    required this.teacherId,
    required this.monthlyFee,
  });

  @override
  List<Object?> get props => [id, name, teacherId, monthlyFee];
}

class GroupDelete extends GroupEvent {
  final int id;

  const GroupDelete(this.id);

  @override
  List<Object?> get props => [id];
}

// States
abstract class GroupState extends Equatable {
  const GroupState();

  @override
  List<Object?> get props => [];
}

class GroupInitial extends GroupState {}

class GroupLoading extends GroupState {}

class GroupLoaded extends GroupState {
  final List<GroupModel> groups;

  const GroupLoaded(this.groups);

  @override
  List<Object?> get props => [groups];
}

class GroupError extends GroupState {
  final String message;

  const GroupError(this.message);

  @override
  List<Object?> get props => [message];
}

class GroupActionSuccess extends GroupState {
  final String message;

  const GroupActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class GroupBloc extends Bloc<GroupEvent, GroupState> {
  final GroupRepository _repository;
  List<GroupModel> _groups = [];

  GroupBloc(this._repository) : super(GroupInitial()) {
    on<GroupLoadAll>(_onLoadAll);
    on<GroupCreate>(_onCreate);
    on<GroupUpdate>(_onUpdate);
    on<GroupDelete>(_onDelete);
  }

  Future<void> _onLoadAll(
    GroupLoadAll event,
    Emitter<GroupState> emit,
  ) async {
    emit(GroupLoading());
    final (groups, failure) = await _repository.getAllSortedByTeacher();
    if (failure != null) {
      emit(GroupError(failure.message));
    } else {
      _groups = groups ?? [];
      emit(GroupLoaded(_groups));
    }
  }

  Future<void> _onCreate(
    GroupCreate event,
    Emitter<GroupState> emit,
  ) async {
    emit(GroupLoading());
    final (group, failure) = await _repository.create(
      GroupRequest(
        name: event.name,
        teacherId: event.teacherId,
        monthlyFee: event.monthlyFee,
      ),
    );
    if (failure != null) {
      emit(GroupError(failure.message));
      emit(GroupLoaded(_groups));
    } else {
      _groups = [..._groups, group!];
      emit(const GroupActionSuccess('Group created successfully'));
      emit(GroupLoaded(_groups));
    }
  }

  Future<void> _onUpdate(
    GroupUpdate event,
    Emitter<GroupState> emit,
  ) async {
    emit(GroupLoading());
    final (group, failure) = await _repository.update(
      event.id,
      GroupRequest(
        name: event.name,
        teacherId: event.teacherId,
        monthlyFee: event.monthlyFee,
      ),
    );
    if (failure != null) {
      emit(GroupError(failure.message));
      emit(GroupLoaded(_groups));
    } else {
      _groups = _groups.map((g) => g.id == event.id ? group! : g).toList();
      emit(const GroupActionSuccess('Group updated successfully'));
      emit(GroupLoaded(_groups));
    }
  }

  Future<void> _onDelete(
    GroupDelete event,
    Emitter<GroupState> emit,
  ) async {
    emit(GroupLoading());
    final failure = await _repository.delete(event.id);
    if (failure != null) {
      emit(GroupError(failure.message));
      emit(GroupLoaded(_groups));
    } else {
      _groups = _groups.where((g) => g.id != event.id).toList();
      emit(const GroupActionSuccess('Group deleted successfully'));
      emit(GroupLoaded(_groups));
    }
  }
}
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/inquiry_group_model.dart';
import '../../data/repositories/inquiry_group_repository.dart';

// Events
abstract class InquiryGroupEvent extends Equatable {
  const InquiryGroupEvent();

  @override
  List<Object?> get props => [];
}

class InquiryGroupLoadAll extends InquiryGroupEvent {}

class InquiryGroupCreate extends InquiryGroupEvent {
  final String name;

  const InquiryGroupCreate(this.name);

  @override
  List<Object?> get props => [name];
}

class InquiryGroupDelete extends InquiryGroupEvent {
  final int id;

  const InquiryGroupDelete(this.id);

  @override
  List<Object?> get props => [id];
}

class InquiryGroupMigrate extends InquiryGroupEvent {
  final int inquiryGroupId;
  final int groupId;

  const InquiryGroupMigrate({
    required this.inquiryGroupId,
    required this.groupId,
  });

  @override
  List<Object?> get props => [inquiryGroupId, groupId];
}

// States
abstract class InquiryGroupState extends Equatable {
  const InquiryGroupState();

  @override
  List<Object?> get props => [];
}

class InquiryGroupInitial extends InquiryGroupState {}

class InquiryGroupLoading extends InquiryGroupState {}

class InquiryGroupLoaded extends InquiryGroupState {
  final List<InquiryGroupModel> groups;

  const InquiryGroupLoaded(this.groups);

  @override
  List<Object?> get props => [groups];
}

class InquiryGroupError extends InquiryGroupState {
  final String message;

  const InquiryGroupError(this.message);

  @override
  List<Object?> get props => [message];
}

class InquiryGroupActionSuccess extends InquiryGroupState {
  final String message;

  const InquiryGroupActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class InquiryGroupBloc extends Bloc<InquiryGroupEvent, InquiryGroupState> {
  final InquiryGroupRepository _repository;
  List<InquiryGroupModel> _groups = [];

  InquiryGroupBloc(this._repository) : super(InquiryGroupInitial()) {
    on<InquiryGroupLoadAll>(_onLoadAll);
    on<InquiryGroupCreate>(_onCreate);
    on<InquiryGroupDelete>(_onDelete);
    on<InquiryGroupMigrate>(_onMigrate);
  }

  Future<void> _onLoadAll(
    InquiryGroupLoadAll event,
    Emitter<InquiryGroupState> emit,
  ) async {
    emit(InquiryGroupLoading());
    final (groups, failure) = await _repository.getAll();
    if (failure != null) {
      emit(InquiryGroupError(failure.message));
    } else {
      _groups = groups ?? [];
      emit(InquiryGroupLoaded(_groups));
    }
  }

  Future<void> _onCreate(
    InquiryGroupCreate event,
    Emitter<InquiryGroupState> emit,
  ) async {
    emit(InquiryGroupLoading());
    final (group, failure) =
        await _repository.create(InquiryGroupRequest(name: event.name));
    if (failure != null) {
      emit(InquiryGroupError(failure.message));
      emit(InquiryGroupLoaded(_groups));
    } else {
      _groups = [..._groups, group!];
      emit(const InquiryGroupActionSuccess('Guruh muvaffaqiyatli qo\'shildi'));
      emit(InquiryGroupLoaded(_groups));
    }
  }

  Future<void> _onDelete(
    InquiryGroupDelete event,
    Emitter<InquiryGroupState> emit,
  ) async {
    emit(InquiryGroupLoading());
    final failure = await _repository.delete(event.id);
    if (failure != null) {
      emit(InquiryGroupError(failure.message));
      emit(InquiryGroupLoaded(_groups));
    } else {
      _groups = _groups.where((g) => g.id != event.id).toList();
      emit(const InquiryGroupActionSuccess('Guruh o\'chirildi'));
      emit(InquiryGroupLoaded(_groups));
    }
  }

  Future<void> _onMigrate(
    InquiryGroupMigrate event,
    Emitter<InquiryGroupState> emit,
  ) async {
    emit(InquiryGroupLoading());
    final failure = await _repository.migrateToGroup(
      MigrateToGroupRequest(
        inquiryGroupId: event.inquiryGroupId,
        groupId: event.groupId,
      ),
    );
    if (failure != null) {
      emit(InquiryGroupError(failure.message));
      emit(InquiryGroupLoaded(_groups));
    } else {
      emit(const InquiryGroupActionSuccess('So\'rovlar guruhga ko\'chirildi'));
      emit(InquiryGroupLoaded(_groups));
    }
  }
}

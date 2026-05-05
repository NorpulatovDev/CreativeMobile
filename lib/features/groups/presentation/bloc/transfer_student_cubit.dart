import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../enrollments/data/repositories/enrollment_repository.dart';
import '../../../groups/data/models/group_model.dart';
import '../../../groups/data/repositories/group_repository.dart';

// States

abstract class TransferStudentState extends Equatable {
  const TransferStudentState();

  @override
  List<Object?> get props => [];
}

class TransferStudentInitial extends TransferStudentState {}

class TransferGroupsLoading extends TransferStudentState {}

class TransferGroupsLoaded extends TransferStudentState {
  final List<GroupModel> groups;

  const TransferGroupsLoaded(this.groups);

  @override
  List<Object?> get props => [groups];
}

class TransferInProgress extends TransferStudentState {
  final List<GroupModel> groups;

  const TransferInProgress(this.groups);

  @override
  List<Object?> get props => [groups];
}

class TransferSuccess extends TransferStudentState {}

class TransferError extends TransferStudentState {
  final String message;
  final List<GroupModel> groups;

  const TransferError({required this.message, required this.groups});

  @override
  List<Object?> get props => [message, groups];
}

// Cubit

class TransferStudentCubit extends Cubit<TransferStudentState> {
  final GroupRepository _groupRepository;
  final EnrollmentRepository _enrollmentRepository;
  final int currentGroupId;

  TransferStudentCubit({
    required GroupRepository groupRepository,
    required EnrollmentRepository enrollmentRepository,
    required this.currentGroupId,
  })  : _groupRepository = groupRepository,
        _enrollmentRepository = enrollmentRepository,
        super(TransferStudentInitial());

  Future<void> loadGroups() async {
    emit(TransferGroupsLoading());
    final (groups, failure) = await _groupRepository.getAll();
    if (isClosed) return;
    if (failure != null) {
      emit(TransferError(message: failure.message, groups: const []));
      return;
    }
    final filtered =
        (groups ?? []).where((g) => g.id != currentGroupId).toList();
    emit(TransferGroupsLoaded(filtered));
  }

  Future<void> transfer({
    required List<int> studentIds,
    required int toGroupId,
  }) async {
    final currentGroups = state is TransferGroupsLoaded
        ? (state as TransferGroupsLoaded).groups
        : state is TransferError
            ? (state as TransferError).groups
            : <GroupModel>[];

    emit(TransferInProgress(currentGroups));

    final failure = await _enrollmentRepository.transferStudents(
      studentIds,
      currentGroupId,
      toGroupId,
    );
    if (isClosed) return;
    if (failure != null) {
      emit(TransferError(message: failure.message, groups: currentGroups));
      return;
    }
    emit(TransferSuccess());
  }
}

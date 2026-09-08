import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../branches/data/models/branch_model.dart';
import '../../../branches/data/repositories/branch_repository.dart';
import '../../../enrollments/data/repositories/enrollment_repository.dart';
import '../../../groups/data/models/group_model.dart';
import '../../../groups/data/repositories/group_repository.dart';

// States

abstract class TransferBranchState extends Equatable {
  const TransferBranchState();

  @override
  List<Object?> get props => [];
}

class TransferBranchInitial extends TransferBranchState {}

class TransferBranchesLoading extends TransferBranchState {}

class TransferBranchesLoaded extends TransferBranchState {
  final List<BranchModel> branches;

  const TransferBranchesLoaded(this.branches);

  @override
  List<Object?> get props => [branches];
}

/// Loading the target branch's groups after a branch was picked.
class TransferBranchGroupsLoading extends TransferBranchState {
  final BranchModel branch;

  const TransferBranchGroupsLoading(this.branch);

  @override
  List<Object?> get props => [branch];
}

class TransferBranchGroupsLoaded extends TransferBranchState {
  final BranchModel branch;
  final List<GroupModel> groups;

  const TransferBranchGroupsLoaded(this.branch, this.groups);

  @override
  List<Object?> get props => [branch, groups];
}

class TransferBranchInProgress extends TransferBranchState {
  final BranchModel branch;
  final List<GroupModel> groups;

  const TransferBranchInProgress(this.branch, this.groups);

  @override
  List<Object?> get props => [branch, groups];
}

class TransferBranchSuccess extends TransferBranchState {}

class TransferBranchError extends TransferBranchState {
  final String message;
  // Context kept so the dialog can stay on the correct step after an error.
  final List<BranchModel> branches;
  final BranchModel? branch;
  final List<GroupModel> groups;

  const TransferBranchError({
    required this.message,
    this.branches = const [],
    this.branch,
    this.groups = const [],
  });

  @override
  List<Object?> get props => [message, branches, branch, groups];
}

// Cubit

class TransferBranchCubit extends Cubit<TransferBranchState> {
  final BranchRepository _branchRepository;
  final GroupRepository _groupRepository;
  final EnrollmentRepository _enrollmentRepository;
  final int fromBranchId;
  final int sourceGroupId;

  // Cached so error states on any step can still show the branch list.
  List<BranchModel> _branches = const [];

  TransferBranchCubit({
    required BranchRepository branchRepository,
    required GroupRepository groupRepository,
    required EnrollmentRepository enrollmentRepository,
    required this.fromBranchId,
    required this.sourceGroupId,
  })  : _branchRepository = branchRepository,
        _groupRepository = groupRepository,
        _enrollmentRepository = enrollmentRepository,
        super(TransferBranchInitial());

  Future<void> loadBranches() async {
    emit(TransferBranchesLoading());
    final (branches, failure) = await _branchRepository.getAll();
    if (isClosed) return;
    if (failure != null) {
      emit(TransferBranchError(message: failure.message));
      return;
    }
    // Can't move to the branch the students already belong to.
    _branches = (branches ?? []).where((b) => b.id != fromBranchId).toList();
    emit(TransferBranchesLoaded(_branches));
  }

  Future<void> selectBranch(BranchModel branch) async {
    emit(TransferBranchGroupsLoading(branch));
    final (groups, failure) =
        await _groupRepository.getAllForBranch(branch.id);
    if (isClosed) return;
    if (failure != null) {
      emit(TransferBranchError(message: failure.message, branches: _branches));
      return;
    }
    emit(TransferBranchGroupsLoaded(branch, groups ?? []));
  }

  Future<void> transfer({
    required List<int> studentIds,
    required BranchModel branch,
    required int targetGroupId,
    bool transferAllPayments = false,
  }) async {
    final groups = switch (state) {
      TransferBranchGroupsLoaded s => s.groups,
      TransferBranchError s => s.groups,
      _ => const <GroupModel>[],
    };

    emit(TransferBranchInProgress(branch, groups));

    final failure = await _enrollmentRepository.transferStudentsBranch(
      studentIds,
      fromBranchId,
      branch.id,
      targetGroupId,
      sourceGroupId: sourceGroupId,
      transferAllPayments: transferAllPayments,
    );
    if (isClosed) return;
    if (failure != null) {
      emit(TransferBranchError(
        message: failure.message,
        branches: _branches,
        branch: branch,
        groups: groups,
      ));
      return;
    }
    emit(TransferBranchSuccess());
  }
}

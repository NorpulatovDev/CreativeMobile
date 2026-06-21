import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../storage/token_storage.dart';

class BranchSelectionState extends Equatable {
  final int? selectedBranchId;
  final String? selectedBranchName;
  final bool isInitialized;

  const BranchSelectionState({
    this.selectedBranchId,
    this.selectedBranchName,
    this.isInitialized = false,
  });

  @override
  List<Object?> get props => [selectedBranchId, selectedBranchName, isInitialized];
}

class BranchSelectionCubit extends Cubit<BranchSelectionState> {
  final TokenStorage _tokenStorage;

  // Emits only when the user explicitly switches branches — not on app init.
  // GoRouter subscribes to this so redirect is not re-evaluated on startup.
  final _switchController = StreamController<void>.broadcast();
  Stream<void> get onBranchSwitch => _switchController.stream;

  BranchSelectionCubit(this._tokenStorage) : super(const BranchSelectionState());

  Future<void> init() async {
    final id = await _tokenStorage.getActiveBranchFilterId();
    final name = await _tokenStorage.getActiveBranchFilterName();
    emit(BranchSelectionState(
      selectedBranchId: id,
      selectedBranchName: name,
      isInitialized: true,
    ));
  }

  Future<void> selectBranch({int? branchId, String? branchName}) async {
    await _tokenStorage.setActiveBranchFilterId(branchId);
    await _tokenStorage.setActiveBranchFilterName(branchName);
    emit(BranchSelectionState(
      selectedBranchId: branchId,
      selectedBranchName: branchName,
      isInitialized: true,
    ));
    _switchController.add(null);
  }

  Future<void> clearSelection() => selectBranch();

  @override
  Future<void> close() {
    _switchController.close();
    return super.close();
  }
}

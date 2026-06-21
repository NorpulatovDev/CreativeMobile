import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/branch/branch_selection_cubit.dart';
import '../../data/models/branch_model.dart';
import '../../data/repositories/branch_repository.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class BranchEvent extends Equatable {
  const BranchEvent();

  @override
  List<Object?> get props => [];
}

class BranchLoadAll extends BranchEvent {}

class BranchCreate extends BranchEvent {
  final String name;
  final String? address;
  final String? phoneNumber;

  const BranchCreate({required this.name, this.address, this.phoneNumber});

  @override
  List<Object?> get props => [name, address, phoneNumber];
}

class BranchUpdate extends BranchEvent {
  final int id;
  final String name;
  final String? address;
  final String? phoneNumber;

  const BranchUpdate({
    required this.id,
    required this.name,
    this.address,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [id, name, address, phoneNumber];
}

class BranchDelete extends BranchEvent {
  final int id;

  const BranchDelete(this.id);

  @override
  List<Object?> get props => [id];
}

// ── States ────────────────────────────────────────────────────────────────────

abstract class BranchState extends Equatable {
  const BranchState();

  @override
  List<Object?> get props => [];
}

class BranchInitial extends BranchState {}

class BranchLoading extends BranchState {}

class BranchLoaded extends BranchState {
  final List<BranchModel> branches;

  const BranchLoaded(this.branches);

  @override
  List<Object?> get props => [branches];
}

class BranchError extends BranchState {
  final String message;

  const BranchError(this.message);

  @override
  List<Object?> get props => [message];
}

class BranchActionSuccess extends BranchState {
  final String message;

  const BranchActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// ── BLoC ──────────────────────────────────────────────────────────────────────

class BranchBloc extends Bloc<BranchEvent, BranchState> {
  final BranchRepository _repository;
  final BranchSelectionCubit _selectionCubit;
  List<BranchModel> _branches = [];

  BranchBloc(this._repository, this._selectionCubit) : super(BranchInitial()) {
    on<BranchLoadAll>(_onLoadAll);
    on<BranchCreate>(_onCreate);
    on<BranchUpdate>(_onUpdate);
    on<BranchDelete>(_onDelete);
  }

  Future<void> _onLoadAll(BranchLoadAll event, Emitter<BranchState> emit) async {
    // Serve cache immediately for instant UI, then refresh from API in background.
    final cached = _repository.getCached();
    if (cached.isNotEmpty) {
      _branches = cached;
      emit(BranchLoaded(_branches));
    } else {
      emit(BranchLoading());
    }
    final (branches, failure) = await _repository.getAll();
    if (failure != null) {
      if (cached.isEmpty) emit(BranchError(failure.message));
    } else {
      _branches = branches ?? [];
      emit(BranchLoaded(_branches));
    }
  }

  Future<void> _onCreate(BranchCreate event, Emitter<BranchState> emit) async {
    emit(BranchLoading());
    final (branch, failure) = await _repository.create(
      BranchRequest(name: event.name, address: event.address, phoneNumber: event.phoneNumber),
    );
    if (failure != null) {
      emit(BranchError(failure.message));
      emit(BranchLoaded(_branches));
    } else {
      _branches = [..._branches, branch!];
      emit(const BranchActionSuccess("Filial muvaffaqiyatli qo'shildi"));
      emit(BranchLoaded(_branches));
    }
  }

  Future<void> _onUpdate(BranchUpdate event, Emitter<BranchState> emit) async {
    emit(BranchLoading());
    final (branch, failure) = await _repository.update(
      event.id,
      BranchRequest(name: event.name, address: event.address, phoneNumber: event.phoneNumber),
    );
    if (failure != null) {
      emit(BranchError(failure.message));
      emit(BranchLoaded(_branches));
    } else {
      _branches = _branches.map((b) => b.id == event.id ? branch! : b).toList();
      emit(const BranchActionSuccess('Filial muvaffaqiyatli tahrirlandi'));
      emit(BranchLoaded(_branches));
    }
  }

  Future<void> _onDelete(BranchDelete event, Emitter<BranchState> emit) async {
    emit(BranchLoading());
    final failure = await _repository.delete(event.id);
    if (failure != null) {
      emit(BranchError(failure.message));
      emit(BranchLoaded(_branches));
    } else {
      _branches = _branches.where((b) => b.id != event.id).toList();
      if (_selectionCubit.state.selectedBranchId == event.id) {
        await _selectionCubit.clearSelection();
      }
      emit(const BranchActionSuccess("Filial o'chirildi"));
      emit(BranchLoaded(_branches));
    }
  }
}

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/admin_model.dart';
import '../../data/repositories/admin_repository.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

class AdminLoadAll extends AdminEvent {}

class AdminCreate extends AdminEvent {
  final String username;
  final String password;
  final String role;
  final int? branchId;

  const AdminCreate({
    required this.username,
    required this.password,
    required this.role,
    this.branchId,
  });

  @override
  List<Object?> get props => [username, password, role, branchId];
}

class AdminUpdate extends AdminEvent {
  final int id;
  final String username;
  final String password;
  final String role;
  final int? branchId;

  const AdminUpdate({
    required this.id,
    required this.username,
    required this.password,
    required this.role,
    this.branchId,
  });

  @override
  List<Object?> get props => [id, username, password, role, branchId];
}

class AdminDelete extends AdminEvent {
  final int id;

  const AdminDelete(this.id);

  @override
  List<Object?> get props => [id];
}

// ── States ────────────────────────────────────────────────────────────────────

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminLoaded extends AdminState {
  final List<AdminModel> admins;

  const AdminLoaded(this.admins);

  @override
  List<Object?> get props => [admins];
}

class AdminError extends AdminState {
  final String message;

  const AdminError(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminActionSuccess extends AdminState {
  final String message;

  const AdminActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// ── BLoC ──────────────────────────────────────────────────────────────────────

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository _repository;
  List<AdminModel> _admins = [];

  AdminBloc(this._repository) : super(AdminInitial()) {
    on<AdminLoadAll>(_onLoadAll);
    on<AdminCreate>(_onCreate);
    on<AdminUpdate>(_onUpdate);
    on<AdminDelete>(_onDelete);
  }

  Future<void> _onLoadAll(AdminLoadAll event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    final (admins, failure) = await _repository.getAll();
    if (failure != null) {
      emit(AdminError(failure.message));
    } else {
      _admins = admins ?? [];
      emit(AdminLoaded(_admins));
    }
  }

  Future<void> _onCreate(AdminCreate event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    final (admin, failure) = await _repository.create(AdminRequest(
      username: event.username,
      password: event.password,
      role: event.role,
      branchId: event.branchId,
    ));
    if (failure != null) {
      emit(AdminError(failure.message));
      emit(AdminLoaded(_admins));
    } else {
      _admins = [..._admins, admin!];
      emit(const AdminActionSuccess("Admin muvaffaqiyatli qo'shildi"));
      emit(AdminLoaded(_admins));
    }
  }

  Future<void> _onUpdate(AdminUpdate event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    final (admin, failure) = await _repository.update(
      event.id,
      AdminRequest(
        username: event.username,
        password: event.password,
        role: event.role,
        branchId: event.branchId,
      ),
    );
    if (failure != null) {
      emit(AdminError(failure.message));
      emit(AdminLoaded(_admins));
    } else {
      _admins = _admins.map((a) => a.id == event.id ? admin! : a).toList();
      emit(const AdminActionSuccess('Admin muvaffaqiyatli tahrirlandi'));
      emit(AdminLoaded(_admins));
    }
  }

  Future<void> _onDelete(AdminDelete event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    final failure = await _repository.delete(event.id);
    if (failure != null) {
      emit(AdminError(failure.message));
      emit(AdminLoaded(_admins));
    } else {
      _admins = _admins.where((a) => a.id != event.id).toList();
      emit(const AdminActionSuccess("Admin o'chirildi"));
      emit(AdminLoaded(_admins));
    }
  }
}

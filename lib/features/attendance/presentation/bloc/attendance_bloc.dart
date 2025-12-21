import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/attendance_model.dart';
import '../../data/repositories/attendance_repository.dart';

// Events
abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object?> get props => [];
}

class AttendanceLoadByGroupAndDate extends AttendanceEvent {
  final int groupId;
  final DateTime date;

  const AttendanceLoadByGroupAndDate({required this.groupId, required this.date});

  @override
  List<Object?> get props => [groupId, date];
}

class AttendanceLoadByGroupAndMonth extends AttendanceEvent {
  final int groupId;
  final int year;
  final int month;

  const AttendanceLoadByGroupAndMonth({
    required this.groupId,
    required this.year,
    required this.month,
  });

  @override
  List<Object?> get props => [groupId, year, month];
}

class AttendanceLoadByStudentAndMonth extends AttendanceEvent {
  final int studentId;
  final int year;
  final int month;

  const AttendanceLoadByStudentAndMonth({
    required this.studentId,
    required this.year,
    required this.month,
  });

  @override
  List<Object?> get props => [studentId, year, month];
}

class AttendanceCreate extends AttendanceEvent {
  final int groupId;
  final DateTime date;
  final List<int> absentStudentIds;

  const AttendanceCreate({
    required this.groupId,
    required this.date,
    required this.absentStudentIds,
  });

  @override
  List<Object?> get props => [groupId, date, absentStudentIds];
}

class AttendanceUpdateStatus extends AttendanceEvent {
  final int id;
  final AttendanceStatus status;

  const AttendanceUpdateStatus({required this.id, required this.status});

  @override
  List<Object?> get props => [id, status];
}

// States
abstract class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceLoaded extends AttendanceState {
  final List<AttendanceModel> attendances;

  const AttendanceLoaded(this.attendances);

  @override
  List<Object?> get props => [attendances];
}

class AttendanceError extends AttendanceState {
  final String message;

  const AttendanceError(this.message);

  @override
  List<Object?> get props => [message];
}

class AttendanceActionSuccess extends AttendanceState {
  final String message;

  const AttendanceActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceRepository _repository;
  List<AttendanceModel> _attendances = [];

  AttendanceBloc(this._repository) : super(AttendanceInitial()) {
    on<AttendanceLoadByGroupAndDate>(_onLoadByGroupAndDate);
    on<AttendanceLoadByGroupAndMonth>(_onLoadByGroupAndMonth);
    on<AttendanceLoadByStudentAndMonth>(_onLoadByStudentAndMonth);
    on<AttendanceCreate>(_onCreate);
    on<AttendanceUpdateStatus>(_onUpdateStatus);
  }

  Future<void> _onLoadByGroupAndDate(
    AttendanceLoadByGroupAndDate event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    final (attendances, failure) =
        await _repository.getByGroupAndDate(event.groupId, event.date);
    if (failure != null) {
      emit(AttendanceError(failure.message));
    } else {
      _attendances = attendances ?? [];
      emit(AttendanceLoaded(_attendances));
    }
  }

  Future<void> _onLoadByGroupAndMonth(
    AttendanceLoadByGroupAndMonth event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    final (attendances, failure) = await _repository.getByGroupIdAndMonth(
        event.groupId, event.year, event.month);
    if (failure != null) {
      emit(AttendanceError(failure.message));
    } else {
      _attendances = attendances ?? [];
      emit(AttendanceLoaded(_attendances));
    }
  }

  Future<void> _onLoadByStudentAndMonth(
    AttendanceLoadByStudentAndMonth event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    final (attendances, failure) = await _repository.getByStudentIdAndMonth(
        event.studentId, event.year, event.month);
    if (failure != null) {
      emit(AttendanceError(failure.message));
    } else {
      _attendances = attendances ?? [];
      emit(AttendanceLoaded(_attendances));
    }
  }

  Future<void> _onCreate(
    AttendanceCreate event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    final (attendances, failure) = await _repository.createForGroup(
      AttendanceRequest(
        groupId: event.groupId,
        date: event.date,
        absentStudentIds: event.absentStudentIds,
      ),
    );
    if (failure != null) {
      emit(AttendanceError(failure.message));
      emit(AttendanceLoaded(_attendances));
    } else {
      _attendances = attendances ?? [];
      emit(const AttendanceActionSuccess('Attendance recorded successfully'));
      emit(AttendanceLoaded(_attendances));
    }
  }

  Future<void> _onUpdateStatus(
    AttendanceUpdateStatus event,
    Emitter<AttendanceState> emit,
  ) async {
    final (attendance, failure) = await _repository.update(
      event.id,
      AttendanceUpdateRequest(status: event.status),
    );
    if (failure != null) {
      emit(AttendanceError(failure.message));
      emit(AttendanceLoaded(_attendances));
    } else {
      _attendances = _attendances
          .map((a) => a.id == event.id ? attendance! : a)
          .toList();
      emit(AttendanceLoaded(_attendances));
    }
  }
}
// lib/features/reports/presentation/bloc/report_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/models/report_models.dart';
import '../../data/repositories/report_repository.dart';

// ==================== EVENTS ====================

abstract class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object?> get props => [];
}

class ReportLoadDaily extends ReportEvent {
  final int year;
  final int month;
  final int day;

  const ReportLoadDaily({
    required this.year,
    required this.month,
    required this.day,
  });

  @override
  List<Object?> get props => [year, month, day];
}

class ReportLoadMonthly extends ReportEvent {
  final int year;
  final int month;

  const ReportLoadMonthly({
    required this.year,
    required this.month,
  });

  @override
  List<Object?> get props => [year, month];
}

class ReportLoadYearly extends ReportEvent {
  final int year;

  const ReportLoadYearly({required this.year});

  @override
  List<Object?> get props => [year];
}

class ReportClear extends ReportEvent {
  const ReportClear();
}

// ==================== STATES ====================

abstract class ReportState extends Equatable {
  const ReportState();

  @override
  List<Object?> get props => [];
}

class ReportInitial extends ReportState {
  const ReportInitial();
}

class ReportLoading extends ReportState {
  const ReportLoading();
}

class ReportDailyLoaded extends ReportState {
  final DailyReport report;

  const ReportDailyLoaded(this.report);

  @override
  List<Object?> get props => [report];
}

class ReportMonthlyLoaded extends ReportState {
  final MonthlyReport report;

  const ReportMonthlyLoaded(this.report);

  @override
  List<Object?> get props => [report];
}

class ReportYearlyLoaded extends ReportState {
  final YearlyReport report;

  const ReportYearlyLoaded(this.report);

  @override
  List<Object?> get props => [report];
}

class ReportError extends ReportState {
  final String message;

  const ReportError(this.message);

  @override
  List<Object?> get props => [message];
}

// ==================== BLOC ====================

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final ReportRepository _repository;

  ReportBloc(this._repository) : super(const ReportInitial()) {
    on<ReportLoadDaily>(_onLoadDaily);
    on<ReportLoadMonthly>(_onLoadMonthly);
    on<ReportLoadYearly>(_onLoadYearly);
    on<ReportClear>(_onClear);
  }

  Future<void> _onLoadDaily(
    ReportLoadDaily event,
    Emitter<ReportState> emit,
  ) async {
    emit(const ReportLoading());

    final (report, error) = await _repository.getDailyReport(
      event.year,
      event.month,
      event.day,
    );

    if (error != null) {
      emit(ReportError(error));
    } else if (report != null) {
      emit(ReportDailyLoaded(report));
    } else {
      emit(const ReportError('Unknown error occurred'));
    }
  }

  Future<void> _onLoadMonthly(
    ReportLoadMonthly event,
    Emitter<ReportState> emit,
  ) async {
    emit(const ReportLoading());

    final (report, error) = await _repository.getMonthlyReport(
      event.year,
      event.month,
    );

    if (error != null) {
      emit(ReportError(error));
    } else if (report != null) {
      emit(ReportMonthlyLoaded(report));
    } else {
      emit(const ReportError('Unknown error occurred'));
    }
  }

  Future<void> _onLoadYearly(
    ReportLoadYearly event,
    Emitter<ReportState> emit,
  ) async {
    emit(const ReportLoading());

    final (report, error) = await _repository.getYearlyReport(event.year);

    if (error != null) {
      emit(ReportError(error));
    } else if (report != null) {
      emit(ReportYearlyLoaded(report));
    } else {
      emit(const ReportError('Unknown error occurred'));
    }
  }

  void _onClear(ReportClear event, Emitter<ReportState> emit) {
    emit(const ReportInitial());
  }
}
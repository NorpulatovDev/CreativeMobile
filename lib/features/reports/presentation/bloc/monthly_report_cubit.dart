import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/report_models.dart';
import '../../data/repositories/report_repository.dart';

// States

abstract class MonthlyReportState extends Equatable {
  const MonthlyReportState();

  @override
  List<Object?> get props => [];
}

class MonthlyReportInitial extends MonthlyReportState {}

class MonthlyReportLoading extends MonthlyReportState {
  final int year;
  final int month;

  const MonthlyReportLoading({required this.year, required this.month});

  @override
  List<Object?> get props => [year, month];
}

class MonthlyReportLoaded extends MonthlyReportState {
  final MonthlyReport report;
  final int year;
  final int month;

  const MonthlyReportLoaded({
    required this.report,
    required this.year,
    required this.month,
  });

  @override
  List<Object?> get props => [report, year, month];
}

class MonthlyReportError extends MonthlyReportState {
  final String message;
  final int year;
  final int month;

  const MonthlyReportError({
    required this.message,
    required this.year,
    required this.month,
  });

  @override
  List<Object?> get props => [message, year, month];
}

// Cubit

class MonthlyReportCubit extends Cubit<MonthlyReportState> {
  final ReportRepository _repository;

  MonthlyReportCubit(this._repository) : super(MonthlyReportInitial());

  Future<void> load({required int year, required int month}) async {
    emit(MonthlyReportLoading(year: year, month: month));
    final (report, error) = await _repository.getMonthlyReport(year, month);
    if (error != null) {
      emit(MonthlyReportError(message: error, year: year, month: month));
    } else if (report != null) {
      emit(MonthlyReportLoaded(report: report, year: year, month: month));
    } else {
      emit(MonthlyReportError(
          message: 'Noma\'lum xatolik', year: year, month: month));
    }
  }

  Future<void> changeYear(int year) async {
    final current = state;
    int month = _currentMonth(current);
    final now = DateTime.now();
    if (year == now.year && month > now.month) {
      month = now.month;
    }
    await load(year: year, month: month);
  }

  Future<void> changeMonth(int month) async {
    await load(year: _currentYear(state), month: month);
  }

  int _currentYear(MonthlyReportState s) {
    if (s is MonthlyReportLoading) return s.year;
    if (s is MonthlyReportLoaded) return s.year;
    if (s is MonthlyReportError) return s.year;
    return DateTime.now().year;
  }

  int _currentMonth(MonthlyReportState s) {
    if (s is MonthlyReportLoading) return s.month;
    if (s is MonthlyReportLoaded) return s.month;
    if (s is MonthlyReportError) return s.month;
    return DateTime.now().month;
  }
}

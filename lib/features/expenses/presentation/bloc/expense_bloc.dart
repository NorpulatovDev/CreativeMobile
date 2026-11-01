import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/expense_models.dart';
import '../../data/repositories/expense_repository.dart';

// Events
abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();
  @override
  List<Object?> get props => [];
}

class LoadExpensesEvent extends ExpenseEvent {
  final String? period;
  final DateTime? date;

  const LoadExpensesEvent({
    this.period,
    this.date,
  });

  @override
  List<Object?> get props => [period, date];
}

class ChangeExpensePeriodEvent extends ExpenseEvent {
  final String period; // 'daily', 'weekly', 'monthly'
  const ChangeExpensePeriodEvent(this.period);
  @override
  List<Object?> get props => [period];
}

class ChangeExpenseDateEvent extends ExpenseEvent {
  final DateTime date;
  const ChangeExpenseDateEvent(this.date);
  @override
  List<Object?> get props => [date];
}

class CreateExpenseEvent extends ExpenseEvent {
  final ExpenseRequest request;
  const CreateExpenseEvent(this.request);
  @override
  List<Object?> get props => [request];
}

class UpdateExpenseEvent extends ExpenseEvent {
  final int id;
  final ExpenseRequest request;
  const UpdateExpenseEvent(this.id, this.request);
  @override
  List<Object?> get props => [id, request];
}

class DeleteExpenseEvent extends ExpenseEvent {
  final int id;
  const DeleteExpenseEvent(this.id);
  @override
  List<Object?> get props => [id];
}

// States
abstract class ExpenseState extends Equatable {
  const ExpenseState();
  @override
  List<Object?> get props => [];
}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpenseLoaded extends ExpenseState {
  final List<ExpenseModel> expenses;
  final ExpenseSummaryModel? summary;
  final String currentPeriod;
  final DateTime selectedDate;

  const ExpenseLoaded({
    required this.expenses,
    this.summary,
    required this.currentPeriod,
    required this.selectedDate,
  });

  @override
  List<Object?> get props => [expenses, summary, currentPeriod, selectedDate];

  ExpenseLoaded copyWith({
    List<ExpenseModel>? expenses,
    ExpenseSummaryModel? summary,
    String? currentPeriod,
    DateTime? selectedDate,
  }) {
    return ExpenseLoaded(
      expenses: expenses ?? this.expenses,
      summary: summary ?? this.summary,
      currentPeriod: currentPeriod ?? this.currentPeriod,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

class ExpenseActionSuccess extends ExpenseState {
  final String message;
  const ExpenseActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class ExpenseError extends ExpenseState {
  final String message;
  const ExpenseError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseRepository _repository;
  String _currentPeriod = 'monthly';
  DateTime _selectedDate = DateTime.now();

  ExpenseBloc(this._repository) : super(ExpenseInitial()) {
    on<LoadExpensesEvent>(_onLoadExpenses);
    on<ChangeExpensePeriodEvent>(_onChangePeriod);
    on<ChangeExpenseDateEvent>(_onChangeDate);
    on<CreateExpenseEvent>(_onCreateExpense);
    on<UpdateExpenseEvent>(_onUpdateExpense);
    on<DeleteExpenseEvent>(_onDeleteExpense);
  }

  Future<void> _onLoadExpenses(
    LoadExpensesEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    if (event.period != null) _currentPeriod = event.period!;
    if (event.date != null) _selectedDate = event.date!;

    emit(ExpenseLoading());
    await _fetchData(emit);
  }

  Future<void> _onChangePeriod(
    ChangeExpensePeriodEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    _currentPeriod = event.period;
    emit(ExpenseLoading());
    await _fetchData(emit);
  }

  Future<void> _onChangeDate(
    ChangeExpenseDateEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    _selectedDate = event.date;
    emit(ExpenseLoading());
    await _fetchData(emit);
  }

  Future<void> _fetchData(Emitter<ExpenseState> emit) async {
    final (expenses, expenseFailure) = await _repository.getExpenses(
      period: _currentPeriod,
      date: _selectedDate,
      year: _selectedDate.year,
      month: _selectedDate.month,
    );

    final (summary, summaryFailure) = await _repository.getSummary(
      period: _currentPeriod,
      date: _selectedDate,
      year: _selectedDate.year,
      month: _selectedDate.month,
    );

    if (expenseFailure != null && (expenses == null || expenses.isEmpty)) {
      emit(ExpenseError(expenseFailure.message));
      return;
    }

    emit(ExpenseLoaded(
      expenses: expenses ?? [],
      summary: summary,
      currentPeriod: _currentPeriod,
      selectedDate: _selectedDate,
    ));
  }

  Future<void> _onCreateExpense(
    CreateExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    final (expense, failure) = await _repository.createExpense(event.request);
    if (failure != null) {
      emit(ExpenseError(failure.message));
    } else {
      emit(const ExpenseActionSuccess('Xarajat muvaffaqiyatli saqlandi'));
      add(LoadExpensesEvent(period: _currentPeriod, date: _selectedDate));
    }
  }

  Future<void> _onUpdateExpense(
    UpdateExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    final (expense, failure) =
        await _repository.updateExpense(event.id, event.request);
    if (failure != null) {
      emit(ExpenseError(failure.message));
    } else {
      emit(const ExpenseActionSuccess('Xarajat muvaffaqiyatli yangilandi'));
      add(LoadExpensesEvent(period: _currentPeriod, date: _selectedDate));
    }
  }

  Future<void> _onDeleteExpense(
    DeleteExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    final failure = await _repository.deleteExpense(event.id);
    if (failure != null) {
      emit(ExpenseError(failure.message));
    } else {
      emit(const ExpenseActionSuccess('Xarajat o\'chirildi'));
      add(LoadExpensesEvent(period: _currentPeriod, date: _selectedDate));
    }
  }
}


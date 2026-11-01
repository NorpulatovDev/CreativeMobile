import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/expense_models.dart';
import '../../data/repositories/expense_repository.dart';

// Events
abstract class ExpenseCategoryEvent extends Equatable {
  const ExpenseCategoryEvent();
  @override
  List<Object?> get props => [];
}

class LoadExpenseCategories extends ExpenseCategoryEvent {
  const LoadExpenseCategories();
}

class CreateExpenseCategoryEvent extends ExpenseCategoryEvent {
  final ExpenseCategoryRequest request;
  const CreateExpenseCategoryEvent(this.request);
  @override
  List<Object?> get props => [request];
}

class UpdateExpenseCategoryEvent extends ExpenseCategoryEvent {
  final int id;
  final ExpenseCategoryRequest request;
  const UpdateExpenseCategoryEvent(this.id, this.request);
  @override
  List<Object?> get props => [id, request];
}

class DeleteExpenseCategoryEvent extends ExpenseCategoryEvent {
  final int id;
  const DeleteExpenseCategoryEvent(this.id);
  @override
  List<Object?> get props => [id];
}

// States
abstract class ExpenseCategoryState extends Equatable {
  const ExpenseCategoryState();
  @override
  List<Object?> get props => [];
}

class ExpenseCategoryInitial extends ExpenseCategoryState {}

class ExpenseCategoryLoading extends ExpenseCategoryState {}

class ExpenseCategoryLoaded extends ExpenseCategoryState {
  final List<ExpenseCategoryModel> categories;
  const ExpenseCategoryLoaded(this.categories);
  @override
  List<Object?> get props => [categories];
}

class ExpenseCategoryActionSuccess extends ExpenseCategoryState {
  final String message;
  const ExpenseCategoryActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class ExpenseCategoryError extends ExpenseCategoryState {
  final String message;
  const ExpenseCategoryError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class ExpenseCategoryBloc
    extends Bloc<ExpenseCategoryEvent, ExpenseCategoryState> {
  final ExpenseRepository _repository;

  ExpenseCategoryBloc(this._repository) : super(ExpenseCategoryInitial()) {
    on<LoadExpenseCategories>(_onLoadCategories);
    on<CreateExpenseCategoryEvent>(_onCreateCategory);
    on<UpdateExpenseCategoryEvent>(_onUpdateCategory);
    on<DeleteExpenseCategoryEvent>(_onDeleteCategory);
  }

  Future<void> _onLoadCategories(
    LoadExpenseCategories event,
    Emitter<ExpenseCategoryState> emit,
  ) async {
    emit(ExpenseCategoryLoading());
    final (categories, failure) = await _repository.getCategories();
    if (failure != null) {
      emit(ExpenseCategoryError(failure.message));
    } else {
      emit(ExpenseCategoryLoaded(categories ?? []));
    }
  }

  Future<void> _onCreateCategory(
    CreateExpenseCategoryEvent event,
    Emitter<ExpenseCategoryState> emit,
  ) async {
    emit(ExpenseCategoryLoading());
    final (category, failure) = await _repository.createCategory(event.request);
    if (failure != null) {
      emit(ExpenseCategoryError(failure.message));
    } else {
      emit(const ExpenseCategoryActionSuccess('Kategoriya muvaffaqiyatli yaratildi'));
      add(const LoadExpenseCategories());
    }
  }

  Future<void> _onUpdateCategory(
    UpdateExpenseCategoryEvent event,
    Emitter<ExpenseCategoryState> emit,
  ) async {
    emit(ExpenseCategoryLoading());
    final (category, failure) =
        await _repository.updateCategory(event.id, event.request);
    if (failure != null) {
      emit(ExpenseCategoryError(failure.message));
    } else {
      emit(const ExpenseCategoryActionSuccess('Kategoriya muvaffaqiyatli yangilandi'));
      add(const LoadExpenseCategories());
    }
  }

  Future<void> _onDeleteCategory(
    DeleteExpenseCategoryEvent event,
    Emitter<ExpenseCategoryState> emit,
  ) async {
    emit(ExpenseCategoryLoading());
    final failure = await _repository.deleteCategory(event.id);
    if (failure != null) {
      emit(ExpenseCategoryError(failure.message));
    } else {
      emit(const ExpenseCategoryActionSuccess('Kategoriya o\'chirildi'));
      add(const LoadExpenseCategories());
    }
  }
}


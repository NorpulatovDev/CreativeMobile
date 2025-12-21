import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/payment_model.dart';
import '../../data/repositories/payment_repository.dart';

// Events
abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class PaymentLoadAll extends PaymentEvent {}

class PaymentLoadByStudent extends PaymentEvent {
  final int studentId;

  const PaymentLoadByStudent(this.studentId);

  @override
  List<Object?> get props => [studentId];
}

class PaymentLoadByGroup extends PaymentEvent {
  final int groupId;

  const PaymentLoadByGroup(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class PaymentCreate extends PaymentEvent {
  final int studentId;
  final int groupId;
  final double amount;
  final String paidForMonth;

  const PaymentCreate({
    required this.studentId,
    required this.groupId,
    required this.amount,
    required this.paidForMonth,
  });

  @override
  List<Object?> get props => [studentId, groupId, amount, paidForMonth];
}

// States
abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentLoaded extends PaymentState {
  final List<PaymentModel> payments;

  const PaymentLoaded(this.payments);

  @override
  List<Object?> get props => [payments];
}

class PaymentError extends PaymentState {
  final String message;

  const PaymentError(this.message);

  @override
  List<Object?> get props => [message];
}

class PaymentActionSuccess extends PaymentState {
  final String message;

  const PaymentActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepository _repository;
  List<PaymentModel> _payments = [];

  PaymentBloc(this._repository) : super(PaymentInitial()) {
    on<PaymentLoadAll>(_onLoadAll);
    on<PaymentLoadByStudent>(_onLoadByStudent);
    on<PaymentLoadByGroup>(_onLoadByGroup);
    on<PaymentCreate>(_onCreate);
  }

  Future<void> _onLoadAll(
    PaymentLoadAll event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());
    final (payments, failure) = await _repository.getAll();
    if (failure != null) {
      emit(PaymentError(failure.message));
    } else {
      _payments = payments ?? [];
      emit(PaymentLoaded(_payments));
    }
  }

  Future<void> _onLoadByStudent(
    PaymentLoadByStudent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());
    final (payments, failure) = await _repository.getByStudentId(event.studentId);
    if (failure != null) {
      emit(PaymentError(failure.message));
    } else {
      _payments = payments ?? [];
      emit(PaymentLoaded(_payments));
    }
  }

  Future<void> _onLoadByGroup(
    PaymentLoadByGroup event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());
    final (payments, failure) = await _repository.getByGroupId(event.groupId);
    if (failure != null) {
      emit(PaymentError(failure.message));
    } else {
      _payments = payments ?? [];
      emit(PaymentLoaded(_payments));
    }
  }

  Future<void> _onCreate(
    PaymentCreate event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());
    final (payment, failure) = await _repository.create(
      PaymentRequest(
        studentId: event.studentId,
        groupId: event.groupId,
        amount: event.amount,
        paidForMonth: event.paidForMonth,
      ),
    );
    if (failure != null) {
      emit(PaymentError(failure.message));
      emit(PaymentLoaded(_payments));
    } else {
      _payments = [payment!, ..._payments];
      emit(const PaymentActionSuccess('Payment recorded successfully'));
      emit(PaymentLoaded(_payments));
    }
  }
}
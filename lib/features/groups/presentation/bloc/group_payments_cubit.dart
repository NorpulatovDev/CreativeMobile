import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../payments/data/models/payment_model.dart';
import '../../../payments/data/repositories/payment_repository.dart';

// States

abstract class GroupPaymentsState extends Equatable {
  const GroupPaymentsState();

  @override
  List<Object?> get props => [];
}

class GroupPaymentsInitial extends GroupPaymentsState {}

class GroupPaymentsLoading extends GroupPaymentsState {}

class GroupPaymentsLoaded extends GroupPaymentsState {
  final List<PaymentModel> payments;

  const GroupPaymentsLoaded(this.payments);

  @override
  List<Object?> get props => [payments];
}

// Cubit

class GroupPaymentsCubit extends Cubit<GroupPaymentsState> {
  final PaymentRepository _repository;

  int? _groupId;
  int? _year;
  int? _month;

  GroupPaymentsCubit(this._repository) : super(GroupPaymentsInitial());

  Future<void> load({
    required int groupId,
    required int year,
    required int month,
  }) async {
    _groupId = groupId;
    _year = year;
    _month = month;
    emit(GroupPaymentsLoading());
    final (payments, _) =
        await _repository.getByGroupIdAndMonth(groupId, year, month);
    emit(GroupPaymentsLoaded(payments ?? []));
  }

  Future<void> reload() async {
    if (_groupId == null) return;
    await load(groupId: _groupId!, year: _year!, month: _month!);
  }
}

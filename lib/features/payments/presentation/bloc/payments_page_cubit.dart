import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'payment_bloc.dart';

class PaymentsPageCubit extends Cubit<String> {
  final PaymentBloc _paymentBloc;
  Timer? _debounce;

  PaymentsPageCubit(this._paymentBloc) : super('');

  void onQueryChanged(String query) {
    emit(query);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!isClosed) _paymentBloc.add(PaymentSearch(query.trim()));
    });
  }

  void clear() {
    _debounce?.cancel();
    emit('');
    _paymentBloc.add(const PaymentSearch(''));
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}

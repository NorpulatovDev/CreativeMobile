import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/sms_queue_processor.dart';
import '../../data/models/sms_message_model.dart';
import '../../data/repositories/sms_repository.dart';

abstract class PendingSmsState extends Equatable {
  const PendingSmsState();
  @override
  List<Object?> get props => [];
}

class PendingSmsLoading extends PendingSmsState {}

class PendingSmsError extends PendingSmsState {
  final String message;
  const PendingSmsError(this.message);
  @override
  List<Object?> get props => [message];
}

class PendingSmsLoaded extends PendingSmsState {
  final List<SmsMessageModel> messages;
  final bool sending;
  final String? actionError;

  const PendingSmsLoaded(this.messages, {this.sending = false, this.actionError});

  PendingSmsLoaded copyWith({
    List<SmsMessageModel>? messages,
    bool? sending,
    String? actionError,
  }) =>
      PendingSmsLoaded(
        messages ?? this.messages,
        sending: sending ?? this.sending,
        actionError: actionError,
      );

  @override
  List<Object?> get props => [messages, sending, actionError];
}

class PendingSmsCubit extends Cubit<PendingSmsState> {
  final SmsRepository _repo;

  PendingSmsCubit(this._repo) : super(PendingSmsLoading());

  Future<void> load() async {
    emit(PendingSmsLoading());
    final (messages, failure) = await _repo.getPending();
    if (isClosed) return;
    if (failure != null) {
      emit(PendingSmsError(failure.message));
    } else {
      emit(PendingSmsLoaded(messages ?? []));
    }
  }

  /// Triggers the device to send all queued messages from the SIM, then reloads.
  /// Successfully sent messages are deleted server-side, so they drop off the list.
  Future<void> sendAll() async {
    final current = state;
    if (current is! PendingSmsLoaded || current.messages.isEmpty || current.sending) {
      return;
    }
    emit(current.copyWith(sending: true, actionError: null));
    await getIt<SmsQueueProcessor>().processQueue();
    if (isClosed) return;
    await load();
  }
}

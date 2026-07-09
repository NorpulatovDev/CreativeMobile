import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/sms_queue_processor.dart';
import '../../data/models/sms_message_model.dart';
import '../../data/repositories/sms_repository.dart';

abstract class FailedSmsState extends Equatable {
  const FailedSmsState();
  @override
  List<Object?> get props => [];
}

class FailedSmsLoading extends FailedSmsState {}

class FailedSmsError extends FailedSmsState {
  final String message;
  const FailedSmsError(this.message);
  @override
  List<Object?> get props => [message];
}

class FailedSmsLoaded extends FailedSmsState {
  final List<SmsMessageModel> messages;
  final Set<int> retryingIds;
  final String? actionError;

  const FailedSmsLoaded(
    this.messages, {
    this.retryingIds = const {},
    this.actionError,
  });

  FailedSmsLoaded copyWith({
    List<SmsMessageModel>? messages,
    Set<int>? retryingIds,
    String? actionError,
  }) =>
      FailedSmsLoaded(
        messages ?? this.messages,
        retryingIds: retryingIds ?? this.retryingIds,
        actionError: actionError,
      );

  @override
  List<Object?> get props => [messages, [...retryingIds]..sort(), actionError];
}

class FailedSmsCubit extends Cubit<FailedSmsState> {
  final SmsRepository _repo;

  FailedSmsCubit(this._repo) : super(FailedSmsLoading());

  Future<void> load() async {
    emit(FailedSmsLoading());
    final (messages, failure) = await _repo.getFailed();
    if (isClosed) return;
    if (failure != null) {
      emit(FailedSmsError(failure.message));
    } else {
      emit(FailedSmsLoaded(messages ?? []));
    }
  }

  Future<void> retry(int id) async {
    final current = state;
    if (current is! FailedSmsLoaded || current.retryingIds.contains(id)) return;

    emit(current.copyWith(
      retryingIds: {...current.retryingIds, id},
      actionError: null,
    ));

    final failure = await _repo.retry(id);
    if (isClosed) return;
    final latest = state;
    if (latest is! FailedSmsLoaded) return;

    final remaining = {...latest.retryingIds}..remove(id);
    if (failure != null) {
      emit(latest.copyWith(retryingIds: remaining, actionError: failure.message));
    } else {
      // Removed from the failed list; nudge the device to send it now.
      emit(latest.copyWith(
        messages: latest.messages.where((m) => m.id != id).toList(),
        retryingIds: remaining,
      ));
      getIt<SmsQueueProcessor>().processQueue();
    }
  }

  Future<void> retryAll() async {
    final current = state;
    if (current is! FailedSmsLoaded || current.messages.isEmpty) return;

    final (count, failure) = await _repo.retryAll();
    if (isClosed) return;
    if (failure != null) {
      final latest = state;
      if (latest is FailedSmsLoaded) {
        emit(latest.copyWith(actionError: failure.message));
      }
      return;
    }
    emit(const FailedSmsLoaded([]));
    if ((count ?? 0) > 0) {
      getIt<SmsQueueProcessor>().processQueue();
    }
  }
}

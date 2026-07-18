import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/sms_queue_processor.dart';
import '../../../../core/services/sms_service.dart';
import '../../data/datasources/sms_log_local_datasource.dart';
import '../../data/models/sms_log_model.dart';
import '../../data/repositories/sms_repository.dart';

abstract class SmsHistoryState extends Equatable {
  const SmsHistoryState();
  @override
  List<Object?> get props => [];
}

class SmsHistoryLoading extends SmsHistoryState {}

class SmsHistoryLoaded extends SmsHistoryState {
  /// Device-local history, newest first (SENT + FAILED outcomes).
  final List<SmsLogModel> entries;

  /// Today's backend-queued messages not yet sent (fallback "send now" surface).
  final int pendingCount;
  final bool sendingPending;

  /// Keys of entries currently being resent (see [SmsHistoryCubit.keyOf]).
  final Set<String> resendingKeys;
  final String? actionError;

  const SmsHistoryLoaded(
    this.entries, {
    this.pendingCount = 0,
    this.sendingPending = false,
    this.resendingKeys = const {},
    this.actionError,
  });

  SmsHistoryLoaded copyWith({
    List<SmsLogModel>? entries,
    int? pendingCount,
    bool? sendingPending,
    Set<String>? resendingKeys,
    String? actionError,
  }) =>
      SmsHistoryLoaded(
        entries ?? this.entries,
        pendingCount: pendingCount ?? this.pendingCount,
        sendingPending: sendingPending ?? this.sendingPending,
        resendingKeys: resendingKeys ?? this.resendingKeys,
        actionError: actionError,
      );

  @override
  List<Object?> get props => [
        entries,
        pendingCount,
        sendingPending,
        [...resendingKeys]..sort(),
        actionError,
      ];
}

/// Backs the SMS History page. The history itself is device-local (Hive); only
/// the pending-count / send-pending fallback touches the backend outbox.
class SmsHistoryCubit extends Cubit<SmsHistoryState> {
  final SmsLogLocalDataSource _log;
  final SmsRepository _repo;
  final SmsService _sms;

  SmsHistoryCubit(this._log, this._repo, this._sms) : super(SmsHistoryLoading());

  /// Stable-ish key for an entry, used to track in-flight resends.
  static String keyOf(SmsLogModel e) =>
      '${e.timestamp.microsecondsSinceEpoch}|${e.recipientPhone}';

  Future<void> load() async {
    final entries = _log.getAll();
    // Best-effort pending count; offline just means 0 (history still shows).
    final (pending, _) = await _repo.getPending();
    if (isClosed) return;
    emit(SmsHistoryLoaded(entries, pendingCount: pending?.length ?? 0));
  }

  /// Send today's still-queued SMS from the SIM, then reload. Covers the case
  /// where auto-send didn't run (app closed/offline at approval time).
  Future<void> sendPending() async {
    final current = state;
    if (current is! SmsHistoryLoaded ||
        current.pendingCount == 0 ||
        current.sendingPending) {
      return;
    }
    emit(current.copyWith(sendingPending: true, actionError: null));
    await getIt<SmsQueueProcessor>().processQueue();
    if (isClosed) return;
    await load();
  }

  /// Resend a failed entry directly from the SIM (local only). Records the new
  /// outcome as a fresh history entry, preserving the original attempt's record.
  Future<void> resend(SmsLogModel entry) async {
    final current = state;
    final key = keyOf(entry);
    if (current is! SmsHistoryLoaded || current.resendingKeys.contains(key)) {
      return;
    }
    emit(current.copyWith(
      resendingKeys: {...current.resendingKeys, key},
      actionError: null,
    ));

    final result = await _sms.send(entry.recipientPhone, entry.body);
    final sent = result == SmsResult.sent;
    await _log.add(SmsLogModel(
      messageId: entry.messageId,
      studentName: entry.studentName,
      recipientPhone: entry.recipientPhone,
      body: entry.body,
      sent: sent,
      error: sent ? null : result.name,
      timestamp: DateTime.now(),
    ));
    if (isClosed) return;

    final entries = _log.getAll();
    final latest = state;
    final remaining = latest is SmsHistoryLoaded
        ? ({...latest.resendingKeys}..remove(key))
        : <String>{};
    emit(SmsHistoryLoaded(
      entries,
      pendingCount: latest is SmsHistoryLoaded ? latest.pendingCount : 0,
      resendingKeys: remaining,
      actionError: sent ? null : _resendError(result),
    ));
  }

  Future<void> clear() async {
    await _log.clear();
    if (isClosed) return;
    await load();
  }

  String _resendError(SmsResult result) => switch (result) {
        SmsResult.permissionDenied ||
        SmsResult.permissionPermanentlyDenied =>
          "SMS ruxsati yo'q",
        SmsResult.notAvailable => 'Bu qurilmada SMS mumkin emas',
        _ => 'SMS yuborilmadi',
      };
}

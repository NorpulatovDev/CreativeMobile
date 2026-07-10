import 'dart:async';

import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../network/connectivity_service.dart';
import '../../features/sms/data/datasources/sms_log_local_datasource.dart';
import '../../features/sms/data/models/sms_log_model.dart';
import 'sms_service.dart';

enum SmsSendPhase { idle, sending, completed }

/// Progress of the current SMS batch, surfaced to a global UI banner so it
/// stays visible even if the admin leaves the approvals screen.
class SmsSendProgress {
  final SmsSendPhase phase;
  final int current; // 1-based index of the message being sent
  final int total;   // batch size
  final int sent;    // completed: delivered count
  final int failed;  // completed: failed count

  const SmsSendProgress._(
    this.phase, {
    this.current = 0,
    this.total = 0,
    this.sent = 0,
    this.failed = 0,
  });

  const SmsSendProgress.idle() : this._(SmsSendPhase.idle);

  const SmsSendProgress.sending(int current, int total)
      : this._(SmsSendPhase.sending, current: current, total: total);

  const SmsSendProgress.completed({required int sent, required int failed})
      : this._(SmsSendPhase.completed, sent: sent, failed: failed);
}

/// Centralized SMS sender for the Admin device.
///
/// Polls the backend SMS outbox (`GET /api/sms/queue`), sends each message from
/// the admin's SIM via the native [SmsService], and reports the outcome back
/// (`POST /api/sms/{id}/result`). This keeps the outgoing number consistent for
/// all parents regardless of which teacher took attendance.
///
/// Runs in the foreground (while the admin app is open). It is driven by:
///   • a periodic timer,
///   • app resume,
///   • an explicit nudge right after an approval.
///
/// NOTE: True app-closed background delivery would require the native SMS
/// MethodChannel handler to move out of `MainActivity` into an Application/plugin
/// registrant so a background isolate can reach it; that is a separate step.
class SmsQueueProcessor {
  final ApiClient _api;
  final SmsService _sms;
  final ConnectivityService _connectivity;
  final SmsLogLocalDataSource _log;

  Timer? _timer;
  Timer? _resetTimer;
  bool _running = false;

  /// Live batch progress for the global SMS banner.
  final ValueNotifier<SmsSendProgress> progress =
      ValueNotifier(const SmsSendProgress.idle());

  /// How long the "completed" summary stays on screen before clearing.
  static const _completedLinger = Duration(seconds: 4);

  static const _pollInterval = Duration(minutes: 1);

  /// Delay between consecutive sends so a burst doesn't trip carrier
  /// rate-limiting / spam filtering on the admin's SIM.
  static const _sendInterval = Duration(seconds: 3);

  SmsQueueProcessor(this._api, this._sms, this._connectivity, this._log);

  /// Begin periodic processing (idempotent). Call when an admin session starts.
  void start() {
    _timer ??= Timer.periodic(_pollInterval, (_) => processQueue());
    processQueue();
  }

  /// Stop periodic processing. Call on logout / when leaving the admin shell.
  void stop() {
    _timer?.cancel();
    _timer = null;
    _resetTimer?.cancel();
    _resetTimer = null;
    progress.value = const SmsSendProgress.idle();
  }

  /// Claim and deliver all currently-queued messages. Safe to call concurrently;
  /// overlapping calls are ignored while one is in flight.
  Future<void> processQueue() async {
    if (_running || !_connectivity.isOnline) return;
    _running = true;
    try {
      final response = await _api.get<List<dynamic>>('/api/sms/queue');
      final messages = response.data ?? const [];
      if (messages.isEmpty) return;

      // A new batch is starting — clear any lingering "completed" summary.
      _resetTimer?.cancel();

      final total = messages.length;
      var sentCount = 0;
      var failedCount = 0;

      for (var i = 0; i < total; i++) {
        // Throttle: wait between consecutive sends (not before the first).
        if (i > 0) {
          await Future<void>.delayed(_sendInterval);
          if (!_connectivity.isOnline) break;
        }

        progress.value = SmsSendProgress.sending(i + 1, total);

        final map = messages[i] as Map<String, dynamic>;
        final id = (map['id'] as num).toInt();
        final phone = map['recipientPhone'] as String;
        final body = map['body'] as String;
        final name = map['studentName'] as String? ?? '';

        final result = await _sms.send(phone, body);
        final sent = result == SmsResult.sent;
        if (sent) {
          sentCount++;
        } else {
          failedCount++;
        }

        // Record the attempt in the device-local log (best-effort).
        try {
          await _log.add(SmsLogModel(
            messageId: id,
            studentName: name,
            recipientPhone: phone,
            body: body,
            sent: sent,
            error: sent ? null : result.name,
            timestamp: DateTime.now(),
          ));
        } catch (e) {
          if (kDebugMode) debugPrint('SMS log write failed for $id: $e');
        }

        try {
          await _api.post<void>(
            '/api/sms/$id/result',
            data: {
              'status': sent ? 'SENT' : 'FAILED',
              'error': sent ? null : result.name,
            },
          );
        } catch (e) {
          // Result report failed — leave message in SENDING; it will be
          // reconciled on a later poll. Avoid resending here.
          if (kDebugMode) debugPrint('SMS result report failed for $id: $e');
        }
      }

      // Show a brief completion summary, then auto-clear.
      progress.value =
          SmsSendProgress.completed(sent: sentCount, failed: failedCount);
      _resetTimer = Timer(_completedLinger, () {
        progress.value = const SmsSendProgress.idle();
      });
    } catch (e) {
      if (kDebugMode) debugPrint('SMS queue poll failed: $e');
      progress.value = const SmsSendProgress.idle();
    } finally {
      _running = false;
    }
  }
}

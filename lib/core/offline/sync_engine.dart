import 'dart:async';

import '../network/connectivity_service.dart';
import 'id_mapping.dart';
import 'sync_queue.dart';

enum SyncStatus { idle, syncing, error }

abstract class SyncOperationHandler {
  String get entityType;

  /// Execute a sync operation against the remote server.
  /// For creates: returns the real server ID.
  /// For updates/deletes: returns null.
  Future<int?> execute(SyncOperation operation, IdMappingService idMapping);
}

class SyncEngine {
  final SyncQueue _queue;
  final ConnectivityService _connectivity;
  final IdMappingService _idMapping;
  final Map<String, SyncOperationHandler> _handlers = {};

  final _statusController = StreamController<SyncStatus>.broadcast();
  StreamSubscription<bool>? _connectivitySubscription;
  bool _isSyncing = false;
  SyncStatus _currentStatus = SyncStatus.idle;

  static const int _maxRetries = 3;

  SyncEngine({
    required SyncQueue queue,
    required ConnectivityService connectivity,
    required IdMappingService idMapping,
  })  : _queue = queue,
        _connectivity = connectivity,
        _idMapping = idMapping;

  Stream<SyncStatus> get statusStream => _statusController.stream.distinct();
  SyncStatus get currentStatus => _currentStatus;
  int get pendingCount => _queue.pendingCount;

  void registerHandler(SyncOperationHandler handler) {
    _handlers[handler.entityType] = handler;
  }

  void start() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((online) {
      if (online) {
        processQueue();
      }
    });
    // Process any pending operations if we're already online
    if (_connectivity.isOnline) {
      processQueue();
    }
  }

  Future<void> processQueue() async {
    if (_isSyncing) return;
    _isSyncing = true;
    _setStatus(SyncStatus.syncing);

    final operations = _queue.getAll();
    bool hadErrors = false;

    for (final op in operations) {
      if (!_connectivity.isOnline) break;

      final handler = _handlers[op.entityType];
      if (handler == null) {
        hadErrors = true;
        continue;
      }

      try {
        final realId = await handler.execute(op, _idMapping);

        // For creates, store the temp→real ID mapping
        if (op.operationType == 'create' && realId != null) {
          await _idMapping.addMapping(op.entityType, op.entityId, realId);
        }

        await _queue.remove(op.id);
      } catch (e) {
        op.retryCount++;
        op.error = e.toString();

        if (op.retryCount >= _maxRetries) {
          // Skip this operation after max retries
          await _queue.remove(op.id);
          hadErrors = true;
        } else {
          await _queue.update(op);
          hadErrors = true;
        }
      }
    }

    _isSyncing = false;
    _setStatus(hadErrors ? SyncStatus.error : SyncStatus.idle);
  }

  void _setStatus(SyncStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _statusController.close();
  }
}

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../network/connectivity_service.dart';
import 'sync_engine.dart';

class SyncStatusState extends Equatable {
  final bool isOnline;
  final SyncStatus syncStatus;
  final int pendingCount;

  const SyncStatusState({
    required this.isOnline,
    required this.syncStatus,
    required this.pendingCount,
  });

  const SyncStatusState.initial()
      : isOnline = true,
        syncStatus = SyncStatus.idle,
        pendingCount = 0;

  SyncStatusState copyWith({
    bool? isOnline,
    SyncStatus? syncStatus,
    int? pendingCount,
  }) {
    return SyncStatusState(
      isOnline: isOnline ?? this.isOnline,
      syncStatus: syncStatus ?? this.syncStatus,
      pendingCount: pendingCount ?? this.pendingCount,
    );
  }

  @override
  List<Object> get props => [isOnline, syncStatus, pendingCount];
}

class SyncStatusCubit extends Cubit<SyncStatusState> {
  final ConnectivityService _connectivity;
  final SyncEngine _syncEngine;
  StreamSubscription<bool>? _connectivitySub;
  StreamSubscription<SyncStatus>? _syncSub;

  SyncStatusCubit({
    required ConnectivityService connectivity,
    required SyncEngine syncEngine,
  })  : _connectivity = connectivity,
        _syncEngine = syncEngine,
        super(SyncStatusState(
          isOnline: connectivity.isOnline,
          syncStatus: syncEngine.currentStatus,
          pendingCount: syncEngine.pendingCount,
        )) {
    _connectivitySub = _connectivity.onConnectivityChanged.listen((online) {
      emit(state.copyWith(
        isOnline: online,
        pendingCount: _syncEngine.pendingCount,
      ));
    });
    _syncSub = _syncEngine.statusStream.listen((status) {
      emit(state.copyWith(
        syncStatus: status,
        pendingCount: _syncEngine.pendingCount,
      ));
    });
  }

  @override
  Future<void> close() {
    _connectivitySub?.cancel();
    _syncSub?.cancel();
    return super.close();
  }
}

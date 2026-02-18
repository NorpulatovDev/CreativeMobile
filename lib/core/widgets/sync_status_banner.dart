import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../offline/sync_engine.dart';
import '../offline/sync_status_cubit.dart';

class SyncStatusBanner extends StatelessWidget {
  const SyncStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SyncStatusCubit, SyncStatusState>(
      builder: (context, state) {
        if (state.isOnline &&
            state.syncStatus == SyncStatus.idle &&
            state.pendingCount == 0) {
          return const SizedBox.shrink();
        }

        Color backgroundColor;
        IconData icon;
        String message;

        if (!state.isOnline) {
          backgroundColor = Colors.red.shade700;
          icon = Icons.cloud_off;
          message = 'Oflayn rejim';
          if (state.pendingCount > 0) {
            message += ' · ${state.pendingCount} ta o\'zgarish kutilmoqda';
          }
        } else if (state.syncStatus == SyncStatus.syncing) {
          backgroundColor = Colors.orange.shade700;
          icon = Icons.sync;
          message = 'Sinxronlanmoqda...';
        } else if (state.pendingCount > 0) {
          backgroundColor = Colors.grey.shade700;
          icon = Icons.cloud_queue;
          message = '${state.pendingCount} ta o\'zgarish kutilmoqda';
        } else {
          return const SizedBox.shrink();
        }

        return Material(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: backgroundColor,
            child: SafeArea(
              bottom: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

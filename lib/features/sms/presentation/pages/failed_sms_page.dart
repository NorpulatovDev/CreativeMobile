import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/sms_message_model.dart';
import '../bloc/failed_sms_cubit.dart';

/// Admin view of SMS that exhausted automatic retries or are stuck, with manual
/// resend. Resending only re-queues that message — already-delivered SMS are
/// never shown here, so a parent is never messaged twice.
class FailedSmsPage extends StatelessWidget {
  const FailedSmsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FailedSmsCubit(getIt())..load(),
      child: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Yuborilmagan SMS',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        actions: [
          BlocBuilder<FailedSmsCubit, FailedSmsState>(
            builder: (context, state) {
              final has = state is FailedSmsLoaded && state.messages.isNotEmpty;
              return TextButton.icon(
                onPressed:
                    has ? () => context.read<FailedSmsCubit>().retryAll() : null,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Hammasi'),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<FailedSmsCubit, FailedSmsState>(
        listenWhen: (p, c) => c is FailedSmsLoaded && c.actionError != null,
        listener: (context, state) {
          if (state is FailedSmsLoaded && state.actionError != null) {
            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(SnackBar(
                content: Text(state.actionError!),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ));
          }
        },
        builder: (context, state) {
          if (state is FailedSmsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is FailedSmsError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: 12),
                  Text(state.message,
                      style: const TextStyle(color: AppColors.neutral600)),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.read<FailedSmsCubit>().load(),
                    child: const Text('Qayta urinish'),
                  ),
                ],
              ),
            );
          }
          if (state is! FailedSmsLoaded) return const SizedBox.shrink();

          if (state.messages.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => context.read<FailedSmsCubit>().load(),
              child: ListView(
                children: [
                  const SizedBox(height: 140),
                  Icon(Icons.mark_email_read_rounded,
                      size: 56, color: AppColors.neutral300),
                  const SizedBox(height: 12),
                  Center(
                    child: Text('Yuborilmagan SMS yo\'q',
                        style: TextStyle(color: AppColors.neutral500)),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<FailedSmsCubit>().load(),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: state.messages.length,
              itemBuilder: (context, i) {
                final m = state.messages[i];
                return _FailedCard(
                  message: m,
                  retrying: state.retryingIds.contains(m.id),
                  onRetry: () => context.read<FailedSmsCubit>().retry(m.id),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _FailedCard extends StatelessWidget {
  final SmsMessageModel message;
  final bool retrying;
  final VoidCallback onRetry;

  const _FailedCard({
    required this.message,
    required this.retrying,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final stuck = message.status == SmsStatus.SENDING;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  stuck ? Icons.hourglass_bottom_rounded : Icons.sms_failed_rounded,
                  color: AppColors.error,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(message.studentName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: AppColors.neutral900)),
                      Text(message.recipientPhone,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.neutral500)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    stuck ? 'OSILIB QOLGAN' : '${message.attempts}/3 urinish',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.error),
                  ),
                ),
              ],
            ),
            if (message.error != null && message.error!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Xato: ${message.error}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.neutral500)),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: retrying ? null : onRetry,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: retrying
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded, size: 18),
                label: Text(retrying ? 'Yuborilmoqda...' : 'Qayta yuborish'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

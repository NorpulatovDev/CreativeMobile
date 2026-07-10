import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/sms_message_model.dart';
import '../bloc/pending_sms_cubit.dart';

/// Today's pending (not-yet-sent) SMS. The admin can send them all from the SIM;
/// sent messages are removed server-side and drop off this list. Failed ones move
/// to the "Yuborilmagan SMS" page for manual retry.
class PendingSmsPage extends StatelessWidget {
  const PendingSmsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PendingSmsCubit(getIt())..load(),
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
        title: const Text('Kutilayotgan SMS',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        actions: [
          IconButton(
            tooltip: 'Yangilash',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<PendingSmsCubit>().load(),
          ),
        ],
      ),
      body: BlocConsumer<PendingSmsCubit, PendingSmsState>(
        listenWhen: (p, c) =>
            c is PendingSmsLoaded && c.actionError != null,
        listener: (context, state) {
          final msg = (state as PendingSmsLoaded).actionError!;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
        },
        builder: (context, state) {
          if (state is PendingSmsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PendingSmsError) {
            return _centered(state.message, context);
          }
          final loaded = state as PendingSmsLoaded;
          if (loaded.messages.isEmpty) {
            return _centered('Kutilayotgan SMS yo\'q', context, icon: Icons.check_circle_outline_rounded);
          }
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: loaded.messages.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _PendingTile(msg: loaded.messages[i]),
                ),
              ),
              _SendBar(loaded: loaded),
            ],
          );
        },
      ),
    );
  }

  Widget _centered(String text, BuildContext context, {IconData? icon}) {
    return RefreshIndicator(
      onRefresh: () => context.read<PendingSmsCubit>().load(),
      child: ListView(
        children: [
          const SizedBox(height: 140),
          Icon(icon ?? Icons.info_outline_rounded, size: 52, color: AppColors.neutral400),
          const SizedBox(height: 12),
          Center(child: Text(text, style: const TextStyle(color: AppColors.neutral500))),
        ],
      ),
    );
  }
}

class _SendBar extends StatelessWidget {
  const _SendBar({required this.loaded});
  final PendingSmsLoaded loaded;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            onPressed: loaded.sending
                ? null
                : () => context.read<PendingSmsCubit>().sendAll(),
            icon: loaded.sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.send_rounded),
            label: Text(loaded.sending
                ? 'Yuborilmoqda…'
                : 'Hammasini yuborish (${loaded.messages.length})'),
          ),
        ),
      ),
    );
  }
}

class _PendingTile extends StatelessWidget {
  const _PendingTile({required this.msg});
  final SmsMessageModel msg;

  @override
  Widget build(BuildContext context) {
    final sending = msg.status == SmsStatus.SENDING;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  msg.studentName.isEmpty ? msg.recipientPhone : msg.studentName,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: AppColors.neutral900),
                ),
              ),
              if (sending)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text('Yuborilmoqda',
                      style: TextStyle(
                          color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(msg.recipientPhone,
              style: const TextStyle(fontSize: 12, color: AppColors.neutral500)),
          const SizedBox(height: 8),
          Text(msg.body,
              style: const TextStyle(fontSize: 13, color: AppColors.neutral700)),
        ],
      ),
    );
  }
}

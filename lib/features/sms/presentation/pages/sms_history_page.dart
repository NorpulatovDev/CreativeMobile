import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/sms_log_model.dart';
import '../bloc/sms_history_cubit.dart';

/// Device-local SMS history: every message this admin's SIM sent or failed to
/// send, newest first. Stored on-device only (not on the backend). Failed
/// entries can be resent directly from the SIM.
class SmsHistoryPage extends StatelessWidget {
  const SmsHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SmsHistoryCubit(getIt(), getIt(), getIt())..load(),
      child: const _Body(),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('SMS tarixi',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        actions: [
          BlocBuilder<SmsHistoryCubit, SmsHistoryState>(
            builder: (context, state) {
              final has = state is SmsHistoryLoaded && state.entries.isNotEmpty;
              if (!has) return const SizedBox.shrink();
              return IconButton(
                tooltip: 'Tozalash',
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: () => _confirmClear(context),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<SmsHistoryCubit, SmsHistoryState>(
        listenWhen: (p, c) => c is SmsHistoryLoaded && c.actionError != null,
        listener: (context, state) {
          if (state is SmsHistoryLoaded && state.actionError != null) {
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
          if (state is! SmsHistoryLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          final cubit = context.read<SmsHistoryCubit>();
          final q = _query.trim().toLowerCase();
          final filtered = q.isEmpty
              ? state.entries
              : state.entries
                  .where((e) => e.studentName.toLowerCase().contains(q))
                  .toList();
          return Column(
            children: [
              if (state.entries.isNotEmpty) _searchBar(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => cubit.load(),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    children: [
                      if (state.pendingCount > 0)
                        _PendingBanner(
                          count: state.pendingCount,
                          sending: state.sendingPending,
                          onSend: () => cubit.sendPending(),
                        ),
                      if (state.entries.isEmpty && state.pendingCount == 0)
                        _emptyState(
                          icon: Icons.sms_outlined,
                          text: 'Hali SMS yuborilmagan',
                        )
                      else if (filtered.isEmpty && q.isNotEmpty)
                        _emptyState(
                          icon: Icons.search_off_rounded,
                          text: 'Bu o\'quvchi bo\'yicha SMS topilmadi',
                        ),
                      for (final e in filtered)
                        _HistoryCard(
                          entry: e,
                          resending: state.resendingKeys
                              .contains(SmsHistoryCubit.keyOf(e)),
                          onResend: () => cubit.resend(e),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _query = v),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'O\'quvchi ismi bo\'yicha qidirish',
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                ),
          isDense: true,
          filled: true,
          fillColor: AppColors.surfaceLight,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.neutral200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.neutral200),
          ),
        ),
      ),
    );
  }

  Widget _emptyState({required IconData icon, required String text}) {
    return Column(
      children: [
        const SizedBox(height: 100),
        Icon(icon, size: 56, color: AppColors.neutral300),
        const SizedBox(height: 12),
        Center(
          child: Text(text,
              style: const TextStyle(color: AppColors.neutral500)),
        ),
      ],
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final cubit = context.read<SmsHistoryCubit>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tarixni tozalash'),
        content: const Text(
            'Qurilmadagi barcha SMS yozuvlari o\'chiriladi. Davom etasizmi?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Bekor qilish')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Tozalash')),
        ],
      ),
    );
    if (ok == true) await cubit.clear();
  }
}

/// Fallback control: today's queued SMS that haven't been sent yet (e.g. approved
/// while the app was closed/offline). Lets the admin push them out from the SIM.
class _PendingBanner extends StatelessWidget {
  final int count;
  final bool sending;
  final VoidCallback onSend;

  const _PendingBanner({
    required this.count,
    required this.sending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.outgoing_mail, color: AppColors.primary, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text('$count ta SMS yuborilishi kutilmoqda',
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: AppColors.neutral900)),
          ),
          FilledButton(
            onPressed: sending ? null : onSend,
            child: sending
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Yuborish'),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final SmsLogModel entry;
  final bool resending;
  final VoidCallback onResend;

  const _HistoryCard({
    required this.entry,
    required this.resending,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    final color = entry.sent ? AppColors.success : AppColors.error;
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
                  entry.sent
                      ? Icons.check_circle_rounded
                      : Icons.sms_failed_rounded,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.studentName.isEmpty
                            ? entry.recipientPhone
                            : entry.studentName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppColors.neutral900),
                      ),
                      Text('${entry.recipientPhone} · ${_formatTs(entry.timestamp)}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.neutral500)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    entry.sent ? 'YUBORILDI' : 'YUBORILMADI',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: color),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(entry.body,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.neutral700)),
            if (!entry.sent && entry.error != null && entry.error!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('Sabab: ${entry.error}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.error)),
            ],
            if (!entry.sent) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: resending ? null : onResend,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: resending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(resending ? 'Yuborilmoqda...' : 'Qayta yuborish'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _formatTs(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(t.day)}.${two(t.month)}.${t.year} ${two(t.hour)}:${two(t.minute)}';
  }
}

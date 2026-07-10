import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/datasources/sms_log_local_datasource.dart';
import '../../data/models/sms_log_model.dart';

/// Device-local SMS history: every message this admin's SIM attempted to send,
/// with its result. Stored on-device only (not on the backend).
class SmsLogPage extends StatefulWidget {
  const SmsLogPage({super.key});

  @override
  State<SmsLogPage> createState() => _SmsLogPageState();
}

class _SmsLogPageState extends State<SmsLogPage> {
  final SmsLogLocalDataSource _log = getIt<SmsLogLocalDataSource>();
  late List<SmsLogModel> _entries;

  @override
  void initState() {
    super.initState();
    _entries = _log.getAll();
  }

  void _refresh() => setState(() => _entries = _log.getAll());

  Future<void> _confirmClear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Jurnalni tozalash'),
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
    if (ok == true) {
      await _log.clear();
      _refresh();
    }
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
        title: const Text('SMS jurnali',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        actions: [
          if (_entries.isNotEmpty)
            IconButton(
              tooltip: 'Tozalash',
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: _confirmClear,
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: _entries.isEmpty
            ? _empty()
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _entries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _SmsLogTile(entry: _entries[i]),
              ),
      ),
    );
  }

  Widget _empty() {
    return ListView(
      children: [
        const SizedBox(height: 120),
        Icon(Icons.sms_outlined, size: 56, color: AppColors.neutral400),
        const SizedBox(height: 12),
        const Center(
          child: Text('Hali SMS yuborilmagan',
              style: TextStyle(color: AppColors.neutral500)),
        ),
      ],
    );
  }
}

class _SmsLogTile extends StatelessWidget {
  const _SmsLogTile({required this.entry});

  final SmsLogModel entry;

  @override
  Widget build(BuildContext context) {
    final color = entry.sent ? AppColors.success : AppColors.error;
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
                  entry.studentName.isEmpty ? entry.recipientPhone : entry.studentName,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: AppColors.neutral900),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  entry.sent ? 'Yuborildi' : 'Xato',
                  style: TextStyle(
                      color: color, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('${entry.recipientPhone} · ${_formatTs(entry.timestamp)}',
              style: const TextStyle(fontSize: 12, color: AppColors.neutral500)),
          const SizedBox(height: 8),
          Text(entry.body,
              style: const TextStyle(fontSize: 13, color: AppColors.neutral700)),
          if (!entry.sent && entry.error != null) ...[
            const SizedBox(height: 6),
            Text('Sabab: ${entry.error}',
                style: const TextStyle(fontSize: 12, color: AppColors.error)),
          ],
        ],
      ),
    );
  }

  static String _formatTs(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(t.day)}.${two(t.month)}.${t.year} ${two(t.hour)}:${two(t.minute)}';
  }
}

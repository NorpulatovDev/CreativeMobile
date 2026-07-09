import 'package:flutter/material.dart';

import '../di/injection.dart';
import '../services/sms_queue_processor.dart';
import '../theme/app_theme.dart';

/// Global banner showing centralized SMS send progress (e.g. "1/3") and a brief
/// success summary. Mounted above the navigator so it stays visible even when
/// the admin leaves the approvals screen mid-send.
class SmsProgressBanner extends StatelessWidget {
  const SmsProgressBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final processor = getIt<SmsQueueProcessor>();
    return ValueListenableBuilder<SmsSendProgress>(
      valueListenable: processor.progress,
      builder: (context, p, _) {
        final Widget content;
        switch (p.phase) {
          case SmsSendPhase.idle:
            return const SizedBox.shrink();
          case SmsSendPhase.sending:
            content = _BannerRow(
              color: AppColors.primary,
              leading: const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              ),
              message: 'SMS yuborilmoqda ${p.current}/${p.total}',
            );
          case SmsSendPhase.completed:
            final hasFailures = p.failed > 0;
            content = _BannerRow(
              color: hasFailures ? AppColors.warning : AppColors.success,
              leading: Icon(
                hasFailures
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_outline,
                color: Colors.white,
                size: 16,
              ),
              message: hasFailures
                  ? '${p.sent} ta yuborildi · ${p.failed} ta xato'
                  : "${p.sent} ta SMS yuborildi",
            );
        }

        return AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topCenter,
          child: content,
        );
      },
    );
  }
}

class _BannerRow extends StatelessWidget {
  final Color color;
  final Widget leading;
  final String message;

  const _BannerRow({
    required this.color,
    required this.leading,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: color,
        child: SafeArea(
          bottom: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              leading,
              const SizedBox(width: 8),
              Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

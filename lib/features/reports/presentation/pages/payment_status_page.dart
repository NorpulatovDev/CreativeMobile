import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/report_models.dart';
import '../widgets/student_payment_card.dart';

enum PaymentStatusType { full, partial, unpaid }

class PaymentStatusPageArgs {
  final PaymentStatusType type;
  final List<StudentPaymentStatus> students;
  final String monthLabel;

  const PaymentStatusPageArgs({
    required this.type,
    required this.students,
    required this.monthLabel,
  });
}

class PaymentStatusPage extends StatelessWidget {
  final PaymentStatusType type;
  final List<StudentPaymentStatus> students;
  final String monthLabel;

  const PaymentStatusPage({
    super.key,
    required this.type,
    required this.students,
    required this.monthLabel,
  });

  String get _title => switch (type) {
        PaymentStatusType.full => 'To\'liq to\'laganlar',
        PaymentStatusType.partial => 'Qisman to\'laganlar',
        PaymentStatusType.unpaid => 'To\'lamaganlar',
      };

  Color get _accentColor => switch (type) {
        PaymentStatusType.full => AppColors.success,
        PaymentStatusType.partial => AppColors.primary,
        PaymentStatusType.unpaid => AppColors.error,
      };

  IconData get _icon => switch (type) {
        PaymentStatusType.full => Icons.check_circle_rounded,
        PaymentStatusType.partial => Icons.timelapse_rounded,
        PaymentStatusType.unpaid => Icons.cancel_rounded,
      };

  bool get _isPartial => type == PaymentStatusType.partial;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _title,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: AppColors.neutral900),
            ),
            Text(
              monthLabel,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.neutral500,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
        ),
      ),
      body: students.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: students.length,
              itemBuilder: (context, index) => StudentPaymentCard(
                student: students[index],
                isPartial: _isPartial,
              ),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: _accentColor.withValues(alpha: 0.1),
                shape: BoxShape.circle),
            child: Icon(_icon, size: 48, color: _accentColor),
          ),
          const SizedBox(height: 24),
          Text(
            'Ma\'lumot yo\'q',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.neutral700, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            '$monthLabel uchun ro\'yxat bo\'sh',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.neutral500),
          ),
        ],
      ),
    );
  }
}

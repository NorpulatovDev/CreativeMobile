import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/number_formatter.dart';
import '../../data/models/report_models.dart';

class StudentPaymentCard extends StatelessWidget {
  final StudentPaymentStatus student;
  final bool isPartial;

  const StudentPaymentCard({
    super.key,
    required this.student,
    required this.isPartial,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPartial ? AppColors.primary : AppColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral900.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12)),
            child: Center(
              child: Text(
                student.studentName.isNotEmpty
                    ? student.studentName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700, color: color),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.studentName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral800)),
                const SizedBox(height: 2),
                Text(student.groupName,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.neutral500)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.phone_outlined,
                        size: 12, color: AppColors.neutral400),
                    const SizedBox(width: 4),
                    Text(student.parentPhoneNumber,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.neutral400)),
                  ],
                ),
                if (isPartial) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.payments_outlined,
                          size: 12, color: AppColors.success),
                      const SizedBox(width: 4),
                      Text(
                        'To\'langan: ${formatAmount(student.amountPaid)} so\'m',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.success),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                Text(
                  formatAmount(student.amountDue),
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: color),
                ),
                Text('qarz',
                    style: TextStyle(fontSize: 10, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

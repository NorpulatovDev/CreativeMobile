import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/attendance_model.dart';

class DateAttendanceCard extends StatelessWidget {
  final String dateKey;
  final List<AttendanceModel> records;
  final VoidCallback onTap;

  const DateAttendanceCard({
    super.key,
    required this.dateKey,
    required this.records,
    required this.onTap,
  });

  String _formatDate(String key) {
    final parts = key.split('-');
    final date = DateTime(
        int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    const days = [
      'Dushanba', 'Seshanba', 'Chorshanba', 'Payshanba',
      'Juma', 'Shanba', 'Yakshanba',
    ];
    const months = [
      'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
      'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr',
    ];
    return '${date.day} ${months[date.month - 1]}, ${days[date.weekday - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final presentCount =
        records.where((r) => r.status == AttendanceStatus.PRESENT).length;
    final absentCount =
        records.where((r) => r.status == AttendanceStatus.ABSENT).length;
    final total = records.length;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: AppColors.neutral200.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: AppColors.neutral900.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF0891B2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Icon(Icons.fact_check_rounded,
                      color: Color(0xFF0891B2)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(dateKey),
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        AttendanceStatusBadge(
                            count: presentCount,
                            total: total,
                            isPresent: true),
                        const SizedBox(width: 8),
                        AttendanceStatusBadge(
                            count: absentCount,
                            total: total,
                            isPresent: false),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.neutral400),
            ],
          ),
        ),
      ),
    );
  }
}

class AttendanceStatusBadge extends StatelessWidget {
  final int count;
  final int total;
  final bool isPresent;

  const AttendanceStatusBadge({
    super.key,
    required this.count,
    required this.total,
    required this.isPresent,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPresent ? AppColors.success : AppColors.error;
    final bg = isPresent ? AppColors.successLight : AppColors.errorLight;
    final icon =
        isPresent ? Icons.check_circle_rounded : Icons.cancel_rounded;
    final label = isPresent ? 'Keldi' : 'Kelmadi';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            '$count $label',
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

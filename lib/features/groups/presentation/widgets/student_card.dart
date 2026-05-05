import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../students/data/models/student_model.dart';

class StudentCard extends StatelessWidget {
  final StudentModel student;
  final GroupInfo groupInfo;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isSelectionMode;
  final bool isSelected;

  const StudentCard({
    super.key,
    required this.student,
    required this.groupInfo,
    required this.onTap,
    this.onLongPress,
    this.isSelectionMode = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final double amountPaid = groupInfo.amountPaidThisMonth ?? 0;
    final double monthlyFee = groupInfo.monthlyFee;

    final bool isFullyPaid = amountPaid >= monthlyFee;
    final bool isUnpaid = amountPaid <= 0;

    final Color statusColor;
    final Color statusLightColor;
    final IconData statusIcon;
    final String statusText;

    if (isFullyPaid) {
      statusColor = AppColors.success;
      statusLightColor = AppColors.successLight;
      statusIcon = Icons.check_circle_rounded;
      statusText = '${amountPaid.toStringAsFixed(0)} so\'m';
    } else if (isUnpaid) {
      statusColor = AppColors.error;
      statusLightColor = AppColors.errorLight;
      statusIcon = Icons.cancel_rounded;
      statusText = 'To\'lanmagan';
    } else {
      statusColor = AppColors.warning;
      statusLightColor = AppColors.warningLight;
      statusIcon = Icons.timelapse_rounded;
      statusText = '${amountPaid.toStringAsFixed(0)} so\'m';
    }

    final borderColor = isSelectionMode && isSelected
        ? AppColors.primary
        : statusColor.withValues(alpha: 0.3);
    final borderWidth = isSelectionMode && isSelected ? 2.0 : 2.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelectionMode && isSelected
                ? AppColors.primary.withValues(alpha: 0.05)
                : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: borderWidth),
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
              if (isSelectionMode)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.neutral400,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check_rounded,
                            size: 14, color: Colors.white)
                        : null,
                  ),
                ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusLightColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    student.fullName.isNotEmpty
                        ? student.fullName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.fullName,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusLightColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 14, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isSelectionMode)
                Icon(Icons.chevron_right_rounded, color: AppColors.neutral400),
            ],
          ),
        ),
      ),
    );
  }
}

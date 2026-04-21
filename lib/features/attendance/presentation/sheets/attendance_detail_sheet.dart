import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/attendance_model.dart';
import '../bloc/attendance_bloc.dart';
import '../widgets/date_attendance_card.dart';

class AttendanceDetailSheet extends StatelessWidget {
  final String dateKey;
  final List<AttendanceModel> records;

  const AttendanceDetailSheet({
    super.key,
    required this.dateKey,
    required this.records,
  });

  String _formatDate() {
    final parts = dateKey.split('-');
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
    return '${date.day} ${months[date.month - 1]} ${date.year}, ${days[date.weekday - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final presentCount =
        records.where((r) => r.status == AttendanceStatus.PRESENT).length;
    final absentCount =
        records.where((r) => r.status == AttendanceStatus.ABSENT).length;

    return BlocListener<AttendanceBloc, AttendanceState>(
      listener: (context, state) {
        if (state is AttendanceError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error),
          );
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.neutral300,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0891B2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.fact_check_rounded,
                        color: Color(0xFF0891B2)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDate(),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            AttendanceStatusBadge(
                                count: presentCount,
                                total: records.length,
                                isPresent: true),
                            const SizedBox(width: 6),
                            AttendanceStatusBadge(
                                count: absentCount,
                                total: records.length,
                                isPresent: false),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            BlocBuilder<AttendanceBloc, AttendanceState>(
              builder: (context, state) {
                final currentRecords = state is AttendanceLoaded
                    ? state.attendances.where((a) {
                        final key =
                            '${a.date.year}-${a.date.month.toString().padLeft(2, '0')}-${a.date.day.toString().padLeft(2, '0')}';
                        return key == dateKey;
                      }).toList()
                    : records;

                return ConstrainedBox(
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.5),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: currentRecords.length,
                    itemBuilder: (context, index) {
                      final record = currentRecords[index];
                      final isPresent =
                          record.status == AttendanceStatus.PRESENT;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isPresent
                              ? AppColors.successLight
                              : AppColors.errorLight,
                          child: Text(
                            record.studentName.isNotEmpty
                                ? record.studentName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: isPresent
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                        ),
                        title: Text(record.studentName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500)),
                        trailing: GestureDetector(
                          onTap: () {
                            context.read<AttendanceBloc>().add(
                                  AttendanceUpdateStatus(
                                    id: record.id,
                                    status: isPresent
                                        ? AttendanceStatus.ABSENT
                                        : AttendanceStatus.PRESENT,
                                  ),
                                );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isPresent
                                  ? AppColors.successLight
                                  : AppColors.errorLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isPresent
                                      ? Icons.check_rounded
                                      : Icons.close_rounded,
                                  size: 14,
                                  color: isPresent
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isPresent ? 'Keldi' : 'Kelmadi',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isPresent
                                        ? AppColors.success
                                        : AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

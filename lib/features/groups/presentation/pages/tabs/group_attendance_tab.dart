import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../attendance/data/models/attendance_model.dart';
import '../../../../attendance/presentation/bloc/attendance_bloc.dart';
import '../../../../attendance/presentation/sheets/attendance_detail_sheet.dart';
import '../../../../attendance/presentation/widgets/date_attendance_card.dart';

class GroupAttendanceTab extends StatefulWidget {
  final AttendanceBloc bloc;
  final int groupId;
  final int year;
  final int month;

  const GroupAttendanceTab({
    super.key,
    required this.bloc,
    required this.groupId,
    required this.year,
    required this.month,
  });

  @override
  State<GroupAttendanceTab> createState() => _GroupAttendanceTabState();
}

class _GroupAttendanceTabState extends State<GroupAttendanceTab> {
  @override
  void didUpdateWidget(GroupAttendanceTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.year != widget.year || oldWidget.month != widget.month) {
      widget.bloc.add(AttendanceLoadByGroupAndMonth(
        groupId: widget.groupId,
        year: widget.year,
        month: widget.month,
      ));
    }
  }

  void _showDetailSheet(
      BuildContext context, String dateKey, List<AttendanceModel> records) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: widget.bloc,
        child: AttendanceDetailSheet(dateKey: dateKey, records: records),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.bloc,
      child: BlocBuilder<AttendanceBloc, AttendanceState>(
        buildWhen: (_, curr) => curr is! AttendanceActionSuccess,
        builder: (context, state) {
          if (state is AttendanceLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0891B2)),
            );
          }

          if (state is AttendanceLoaded) {
            if (state.attendances.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0891B2).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.fact_check_outlined,
                          size: 48, color: Color(0xFF0891B2)),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Davomat olinmagan',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.neutral700,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bu oy uchun davomat hali olinmagan',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.neutral500,
                          ),
                    ),
                  ],
                ),
              );
            }

            final Map<String, List<AttendanceModel>> byDate = {};
            for (final r in state.attendances) {
              final key =
                  '${r.date.year}-${r.date.month.toString().padLeft(2, '0')}-${r.date.day.toString().padLeft(2, '0')}';
              byDate.putIfAbsent(key, () => []).add(r);
            }
            final sortedKeys = byDate.keys.toList()
              ..sort((a, b) => b.compareTo(a));

            return RefreshIndicator(
              color: const Color(0xFF0891B2),
              onRefresh: () async {
                widget.bloc.add(AttendanceLoadByGroupAndMonth(
                  groupId: widget.groupId,
                  year: widget.year,
                  month: widget.month,
                ));
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: sortedKeys.length,
                itemBuilder: (context, index) {
                  final key = sortedKeys[index];
                  final records = byDate[key]!;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: DateAttendanceCard(
                      dateKey: key,
                      records: records,
                      onTap: () => _showDetailSheet(context, key, records),
                    ),
                  );
                },
              ),
            );
          }

          if (state is AttendanceError) {
            return Center(
              child: Text(state.message,
                  style: TextStyle(color: AppColors.error)),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

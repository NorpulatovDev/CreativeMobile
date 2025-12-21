// lib/features/reports/presentation/pages/tabs/daily_report_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../data/models/report_models.dart';
import '../../bloc/report_bloc.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/stat_card.dart';

class DailyReportTab extends StatefulWidget {
  const DailyReportTab({super.key});

  @override
  State<DailyReportTab> createState() => _DailyReportTabState();
}

class _DailyReportTabState extends State<DailyReportTab>
    with AutomaticKeepAliveClientMixin {
  DateTime _selectedDate = DateTime.now();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  void _loadReport() {
    context.read<ReportBloc>().add(
          ReportLoadDaily(
            year: _selectedDate.year,
            month: _selectedDate.month,
            day: _selectedDate.day,
          ),
        );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _loadReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocBuilder<ReportBloc, ReportState>(
      builder: (context, state) {
        if (state is ReportLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ReportDailyLoaded) {
          return RefreshIndicator(
            onRefresh: () async => _loadReport(),
            child: _DailyReportContent(
              report: state.report,
              selectedDate: _selectedDate,
              onDateTap: _selectDate,
            ),
          );
        }

        return EmptyState(
          icon: Icons.calendar_today,
          title: 'Select a date to view report',
          subtitle: 'Choose a date to see attendance and payment details',
          actionText: 'Select Date',
          onAction: _selectDate,
        );
      },
    );
  }
}

class _DailyReportContent extends StatelessWidget {
  final DailyReport report;
  final DateTime selectedDate;
  final VoidCallback onDateTap;

  const _DailyReportContent({
    required this.report,
    required this.selectedDate,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Date Selector
        Card(
          child: ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text(
              DateFormat('EEEE, MMMM dd, yyyy').format(selectedDate),
            ),
            trailing: const Icon(Icons.arrow_drop_down),
            onTap: onDateTap,
          ),
        ),
        const SizedBox(height: 16),

        // Summary Stats
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Present',
                value: '${report.totalStudentsPresent}',
                icon: Icons.check_circle,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StatCard(
                title: 'Absent',
                value: '${report.totalStudentsAbsent}',
                icon: Icons.cancel,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        StatCard(
          title: 'Payments Received',
          value: '${report.totalPaymentsReceived.toStringAsFixed(0)} UZS',
          subtitle: '${report.paymentCount} payment${report.paymentCount != 1 ? 's' : ''}',
          icon: Icons.payments,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 24),

        // Group Attendance
        _SectionHeader(
          title: 'Group Attendance',
          count: report.groupAttendances.length,
        ),
        const SizedBox(height: 8),

        if (report.groupAttendances.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('No attendance records for this day'),
                  ),
                ],
              ),
            ),
          )
        else
          ...report.groupAttendances.map((group) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(group.groupName),
                  subtitle: Text('Teacher: ${group.teacherName}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${group.presentCount}/${group.totalStudents}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${group.absentCount} absent',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              )),

        if (report.payments.isNotEmpty) ...[
          const SizedBox(height: 24),
          _SectionHeader(
            title: 'Payments',
            count: report.payments.length,
          ),
          const SizedBox(height: 8),

          ...report.payments.map((payment) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.payment,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: Text(payment.studentName),
                  subtitle: Text(
                    '${payment.groupName} • ${payment.paidForMonth}',
                  ),
                  trailing: Text(
                    '${payment.amount.toStringAsFixed(0)} UZS',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              )),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int? count;

  const _SectionHeader({
    required this.title,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        if (count != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
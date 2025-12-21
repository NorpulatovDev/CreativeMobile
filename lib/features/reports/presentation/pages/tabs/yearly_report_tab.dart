// lib/features/reports/presentation/pages/tabs/yearly_report_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/report_models.dart';
import '../../bloc/report_bloc.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/stat_card.dart';

class YearlyReportTab extends StatefulWidget {
  const YearlyReportTab({super.key});

  @override
  State<YearlyReportTab> createState() => _YearlyReportTabState();
}

class _YearlyReportTabState extends State<YearlyReportTab>
    with AutomaticKeepAliveClientMixin {
  int _selectedYear = DateTime.now().year;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  void _loadReport() {
    context.read<ReportBloc>().add(ReportLoadYearly(year: _selectedYear));
  }

  void _changeYear(int delta) {
    setState(() => _selectedYear += delta);
    _loadReport();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocBuilder<ReportBloc, ReportState>(
      builder: (context, state) {
        if (state is ReportLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ReportYearlyLoaded) {
          return RefreshIndicator(
            onRefresh: () async => _loadReport(),
            child: _YearlyReportContent(
              report: state.report,
              selectedYear: _selectedYear,
              onPreviousYear: () => _changeYear(-1),
              onNextYear: _selectedYear < DateTime.now().year
                  ? () => _changeYear(1)
                  : null,
            ),
          );
        }

        return const EmptyState(
          icon: Icons.calendar_today,
          title: 'No yearly report loaded',
          subtitle: 'Use the year selector to view a report',
        );
      },
    );
  }
}

class _YearlyReportContent extends StatelessWidget {
  final YearlyReport report;
  final int selectedYear;
  final VoidCallback onPreviousYear;
  final VoidCallback? onNextYear;

  const _YearlyReportContent({
    required this.report,
    required this.selectedYear,
    required this.onPreviousYear,
    this.onNextYear,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Year Selector
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: onPreviousYear,
                  tooltip: 'Previous year',
                ),
                Text(
                  '$selectedYear',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: onNextYear,
                  tooltip: onNextYear != null ? 'Next year' : null,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Total Revenue
        StatCard(
          title: 'Total Revenue',
          value: '${report.totalRevenue.toStringAsFixed(0)} UZS',
          subtitle: '${report.totalPayments} payments',
          icon: Icons.attach_money,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 8),

        // Attendance
        StatCard(
          title: 'Attendance Rate',
          value: '${report.attendanceStats.attendanceRate.toStringAsFixed(1)}%',
          subtitle:
              '${report.attendanceStats.totalPresent} present, ${report.attendanceStats.totalAbsent} absent',
          icon: Icons.fact_check,
          color: Colors.green,
        ),
        const SizedBox(height: 24),

        // Monthly Breakdown
        _SectionHeader(
          title: 'Monthly Revenue',
          count: report.monthlyBreakdown.length,
        ),
        const SizedBox(height: 8),

        if (report.monthlyBreakdown.isEmpty)
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
                    child: Text('No revenue data for this year'),
                  ),
                ],
              ),
            ),
          )
        else
          ...report.monthlyBreakdown.map((month) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      month.month.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(month.monthName),
                  subtitle: Text('${month.paymentCount} payments'),
                  trailing: Text(
                    '${month.revenue.toStringAsFixed(0)} UZS',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              )),

        if (report.teacherStats.isNotEmpty) ...[
          const SizedBox(height: 24),
          _SectionHeader(
            title: 'Teacher Performance',
            count: report.teacherStats.length,
          ),
          const SizedBox(height: 8),

          ...report.teacherStats.map((teacher) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ExpansionTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text(teacher.teacherName),
                  subtitle: Text(
                    '${teacher.groupCount} groups • ${teacher.totalStudents} students',
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatColumn(
                            label: 'Groups',
                            value: '${teacher.groupCount}',
                            icon: Icons.groups,
                          ),
                          _StatColumn(
                            label: 'Students',
                            value: '${teacher.totalStudents}',
                            icon: Icons.people,
                          ),
                          _StatColumn(
                            label: 'Revenue',
                            value: '${(teacher.totalRevenue / 1000000).toStringAsFixed(1)}M',
                            icon: Icons.attach_money,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],

        if (report.topGroups.isNotEmpty) ...[
          const SizedBox(height: 24),
          _SectionHeader(
            title: 'Top Groups by Revenue',
            count: report.topGroups.length,
          ),
          const SizedBox(height: 8),

          ...report.topGroups.asMap().entries.map((entry) {
            final index = entry.key;
            final group = entry.value;
            final rank = index + 1;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getRankColor(rank, context),
                  child: Text(
                    '$rank',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                title: Text(group.groupName),
                subtitle: Text('Teacher: ${group.teacherName}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${group.totalRevenue.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${group.totalPayments} payments',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  Color _getRankColor(int rank, BuildContext context) {
    switch (rank) {
      case 1:
        return Colors.amber.shade700; // Gold
      case 2:
        return Colors.grey.shade600; // Silver
      case 3:
        return Colors.brown.shade600; // Bronze
      default:
        return Theme.of(context).colorScheme.primary;
    }
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

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatColumn({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
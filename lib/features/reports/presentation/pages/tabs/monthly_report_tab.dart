// lib/features/reports/presentation/pages/tabs/monthly_report_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/report_models.dart';
import '../../bloc/report_bloc.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/revenue_row.dart';
import '../../widgets/stat_card.dart';

class MonthlyReportTab extends StatefulWidget {
  const MonthlyReportTab({super.key});

  @override
  State<MonthlyReportTab> createState() => _MonthlyReportTabState();
}

class _MonthlyReportTabState extends State<MonthlyReportTab>
    with AutomaticKeepAliveClientMixin {
  late int _selectedYear;
  late int _selectedMonth;
  MonthlyReport? _cachedReport;

  static const List<String> _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
    _loadReport();
  }

  void _loadReport() {
    context.read<ReportBloc>().add(
          ReportLoadMonthly(
            year: _selectedYear,
            month: _selectedMonth,
          ),
        );
  }

  void _onYearChanged(int? year) {
    if (year != null && year != _selectedYear) {
      setState(() {
        _selectedYear = year;
        // If selected month is in the future for current year, reset to current month
        if (year == DateTime.now().year && _selectedMonth > DateTime.now().month) {
          _selectedMonth = DateTime.now().month;
        }
      });
      _loadReport();
    }
  }

  void _onMonthSelected(int month) {
    if (month != _selectedMonth) {
      setState(() => _selectedMonth = month);
      _loadReport();
    }
  }

  List<int> _getAvailableYears() {
    final currentYear = DateTime.now().year;
    return List.generate(currentYear - 2019, (index) => currentYear - index);
  }

  bool _isMonthEnabled(int month) {
    final now = DateTime.now();
    if (_selectedYear < now.year) return true;
    if (_selectedYear > now.year) return false;
    return month <= now.month;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocConsumer<ReportBloc, ReportState>(
      listenWhen: (previous, current) => current is ReportMonthlyLoaded,
      listener: (context, state) {
        if (state is ReportMonthlyLoaded) {
          _cachedReport = state.report;
        }
      },
      builder: (context, state) {
        // Show loading only when we don't have cached data
        if (state is ReportLoading && _cachedReport == null) {
          return const Center(child: CircularProgressIndicator());
        }

        // Use cached report if current state is not monthly loaded
        final report = state is ReportMonthlyLoaded ? state.report : _cachedReport;

        if (report != null) {
          return RefreshIndicator(
            onRefresh: () async => _loadReport(),
            child: _MonthlyReportContent(
              report: report,
              selectedYear: _selectedYear,
              selectedMonth: _selectedMonth,
              availableYears: _getAvailableYears(),
              onYearChanged: _onYearChanged,
              onMonthSelected: _onMonthSelected,
              isMonthEnabled: _isMonthEnabled,
              isLoading: state is ReportLoading,
            ),
          );
        }

        return EmptyState(
          icon: Icons.calendar_month,
          title: 'Select a month to view report',
          subtitle: 'Choose a month to see revenue and attendance details',
          actionText: 'Load Report',
          onAction: _loadReport,
        );
      },
    );
  }
}

class _MonthlyReportContent extends StatelessWidget {
  final MonthlyReport report;
  final int selectedYear;
  final int selectedMonth;
  final List<int> availableYears;
  final ValueChanged<int?> onYearChanged;
  final ValueChanged<int> onMonthSelected;
  final bool Function(int) isMonthEnabled;
  final bool isLoading;

  static const List<String> _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  const _MonthlyReportContent({
    required this.report,
    required this.selectedYear,
    required this.selectedMonth,
    required this.availableYears,
    required this.onYearChanged,
    required this.onMonthSelected,
    required this.isMonthEnabled,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Year Dropdown
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Year:',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: selectedYear,
                      isExpanded: true,
                      items: availableYears.map((year) {
                        return DropdownMenuItem(
                          value: year,
                          child: Text(
                            '$year',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: onYearChanged,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Month Picker
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Month',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (isLoading) ...[
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    final month = index + 1;
                    final isSelected = month == selectedMonth;
                    final isEnabled = isMonthEnabled(month);

                    return Material(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : isEnabled
                              ? theme.colorScheme.surfaceContainerHighest
                              : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: isEnabled ? () => onMonthSelected(month) : null,
                        borderRadius: BorderRadius.circular(8),
                        child: Center(
                          child: Text(
                            _monthNames[index],
                            style: TextStyle(
                              color: isSelected
                                  ? theme.colorScheme.onPrimary
                                  : isEnabled
                                      ? theme.colorScheme.onSurface
                                      : theme.colorScheme.onSurface.withOpacity(0.38),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Revenue Stats Card
        Card(
          color: theme.colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Revenue Overview',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 16),
                RevenueRow(
                  label: 'Expected Revenue',
                  value: '${report.expectedRevenue.toStringAsFixed(0)} UZS',
                  valueColor: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(height: 8),
                RevenueRow(
                  label: 'Actual Revenue',
                  value: '${report.actualRevenue.toStringAsFixed(0)} UZS',
                  valueColor: theme.colorScheme.primary,
                ),
                const Divider(height: 24),
                RevenueRow(
                  label: 'Collection Rate',
                  value: '${report.collectionRate.toStringAsFixed(1)}%',
                  valueColor: Colors.green.shade700,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Student Payment Stats
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Paid',
                value: '${report.studentsWhoPaid}',
                subtitle: 'students',
                icon: Icons.check_circle,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StatCard(
                title: 'Unpaid',
                value: '${report.studentsWhoDidNotPay}',
                subtitle: 'students',
                icon: Icons.warning,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Attendance Stats
        StatCard(
          title: 'Attendance Rate',
          value: '${report.attendanceStats.attendanceRate.toStringAsFixed(1)}%',
          subtitle:
              '${report.attendanceStats.totalPresent} present, ${report.attendanceStats.totalAbsent} absent',
          icon: Icons.fact_check,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 24),

        // Group Statistics
        _SectionHeader(
          title: 'Group Statistics',
          count: report.groupStats.length,
        ),
        const SizedBox(height: 8),

        if (report.groupStats.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('No group data for this month'),
                  ),
                ],
              ),
            ),
          )
        else
          ...report.groupStats.map((group) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ExpansionTile(
                  title: Text(group.groupName),
                  subtitle: Text('Teacher: ${group.teacherName}'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          InfoRow(
                            label: 'Active Students',
                            value: '${group.activeStudents}',
                          ),
                          const SizedBox(height: 8),
                          InfoRow(
                            label: 'Expected Revenue',
                            value: '${group.expectedRevenue.toStringAsFixed(0)} UZS',
                          ),
                          const SizedBox(height: 8),
                          InfoRow(
                            label: 'Actual Revenue',
                            value: '${group.actualRevenue.toStringAsFixed(0)} UZS',
                            valueColor: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 8),
                          InfoRow(
                            label: 'Collection Rate',
                            value: '${group.collectionRate.toStringAsFixed(1)}%',
                            valueColor: Colors.green,
                          ),
                          const Divider(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _SmallStatCard(
                                  label: 'Paid',
                                  value: '${group.paidStudents}',
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _SmallStatCard(
                                  label: 'Unpaid',
                                  value: '${group.unpaidStudents}',
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),

        if (report.unpaidStudents.isNotEmpty) ...[
          const SizedBox(height: 24),
          _SectionHeader(
            title: 'Unpaid Students',
            count: report.unpaidStudents.length,
          ),
          const SizedBox(height: 8),

          ...report.unpaidStudents.map((student) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.red,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(student.studentName),
                  subtitle: Text(
                    '${student.groupName}\n${student.parentPhoneNumber}',
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${student.amountDue.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Text(
                        'UZS',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  isThreeLine: true,
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

class _SmallStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SmallStatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
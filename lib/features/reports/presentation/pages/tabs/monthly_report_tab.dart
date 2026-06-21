import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/utils/number_formatter.dart';
import '../../../../../core/router/routes.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../data/models/report_models.dart';
import '../../bloc/monthly_report_cubit.dart';
import '../../widgets/report_stat_card.dart';
import '../payment_status_page.dart';

class MonthlyReportTab extends StatelessWidget {
  const MonthlyReportTab({super.key});

  static const List<String> _fullMonthNames = [
    'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
    'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final now = DateTime.now();
        return MonthlyReportCubit(getIt())
          ..load(year: now.year, month: now.month);
      },
      child: BlocBuilder<MonthlyReportCubit, MonthlyReportState>(
        builder: (context, state) {
          final cubit = context.read<MonthlyReportCubit>();
          final year = _yearOf(state);
          final month = _monthOf(state);
          final isLoading = state is MonthlyReportLoading;

          return RefreshIndicator(
            onRefresh: () => cubit.load(year: year, month: month),
            color: AppColors.primary,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _YearSelector(
                  selectedYear: year,
                  onChanged: cubit.changeYear,
                ),
                const SizedBox(height: 16),
                _MonthSelector(
                  selectedMonth: month,
                  selectedYear: year,
                  isLoading: isLoading,
                  onMonthSelected: cubit.changeMonth,
                ),
                const SizedBox(height: 24),
                if (state is MonthlyReportError)
                  _ErrorState(
                    message: state.message,
                    onRetry: () => cubit.load(year: year, month: month),
                  )
                else if (state is MonthlyReportLoaded)
                  _ReportContent(
                    report: state.report,
                    monthLabel:
                        '${_fullMonthNames[state.month - 1].toUpperCase()} ${state.year}',
                  )
                else if (state is MonthlyReportInitial)
                  _EmptyState(
                    onLoad: () => cubit.load(year: year, month: month),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  static int _yearOf(MonthlyReportState s) {
    if (s is MonthlyReportLoading) return s.year;
    if (s is MonthlyReportLoaded) return s.year;
    if (s is MonthlyReportError) return s.year;
    return DateTime.now().year;
  }

  static int _monthOf(MonthlyReportState s) {
    if (s is MonthlyReportLoading) return s.month;
    if (s is MonthlyReportLoaded) return s.month;
    if (s is MonthlyReportError) return s.month;
    return DateTime.now().month;
  }
}

// ── Year selector ────────────────────────────────────────────────────────────

class _YearSelector extends StatelessWidget {
  // Computed once at class-load time — the app never spans a year boundary
  // in a single session, so this list never goes stale.
  static final _years = List.generate(
    DateTime.now().year - 2019,
    (i) => DateTime.now().year - i,
  );

  final int selectedYear;
  final ValueChanged<int> onChanged;

  const _YearSelector({required this.selectedYear, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral200.withValues(alpha: 0.5)),
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.calendar_today_rounded,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Text('Yil:',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral700)),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: selectedYear,
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppColors.neutral400),
                items: _years
                    .map((y) => DropdownMenuItem(
                          value: y,
                          child: Text('$y',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.neutral800)),
                        ))
                    .toList(),
                onChanged: (y) {
                  if (y != null) onChanged(y);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Month selector ───────────────────────────────────────────────────────────

class _MonthSelector extends StatelessWidget {
  final int selectedMonth;
  final int selectedYear;
  final bool isLoading;
  final ValueChanged<int> onMonthSelected;

  static const List<String> _labels = [
    'Yan', 'Fev', 'Mar', 'Apr', 'May', 'Iyun',
    'Iyul', 'Avg', 'Sen', 'Okt', 'Noy', 'Dek',
  ];

  const _MonthSelector({
    required this.selectedMonth,
    required this.selectedYear,
    required this.isLoading,
    required this.onMonthSelected,
  });

  bool _isEnabled(int month) {
    final now = DateTime.now();
    if (selectedYear < now.year) return true;
    if (selectedYear > now.year) return false;
    return month <= now.month;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral200.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral900.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month_rounded,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Oy',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral600)),
              if (isLoading) ...[
                const SizedBox(width: 8),
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.primary),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              childAspectRatio: 1.6,
              crossAxisSpacing: 6,
              mainAxisSpacing: 8,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              final month = index + 1;
              final isSelected = month == selectedMonth;
              final isEnabled = _isEnabled(month);
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isEnabled ? () => onMonthSelected(month) : null,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : (isEnabled
                              ? AppColors.neutral50
                              : AppColors.neutral100),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.neutral200,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _labels[index],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : (isEnabled
                                  ? AppColors.neutral700
                                  : AppColors.neutral400),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Report content ───────────────────────────────────────────────────────────

class _ReportContent extends StatelessWidget {
  final MonthlyReport report;
  final String monthLabel;

  const _ReportContent({required this.report, required this.monthLabel});

  void _openStatusPage(
    BuildContext context,
    PaymentStatusType type,
    List<StudentPaymentStatus> students,
  ) {
    context.push(
      Routes.reportPaymentStatus,
      extra: PaymentStatusPageArgs(
        type: type,
        students: students,
        monthLabel: monthLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ReportStatCard(
                title: 'Kutilgan',
                value: formatAmount(report.expectedRevenue),
                subtitle: 'so\'m',
                icon: Icons.trending_up_rounded,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ReportStatCard(
                title: 'Haqiqiy',
                value: formatAmount(report.actualRevenue),
                subtitle: 'so\'m',
                icon: Icons.account_balance_wallet_rounded,
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ReportStatCard(
                title: 'To\'liq',
                value: '${report.studentsWhoFullyPaid}',
                subtitle: 'o\'quvchi',
                icon: Icons.check_circle_rounded,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ReportStatCard(
                title: 'Qisman',
                value: '${report.studentsWhoPartiallyPaid}',
                subtitle: 'o\'quvchi',
                icon: Icons.timelapse_rounded,
                color: AppColors.primary,
                onTap: () => _openStatusPage(
                  context,
                  PaymentStatusType.partial,
                  report.partialPaymentStudents,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ReportStatCard(
                title: 'Yo\'q',
                value: '${report.studentsWhoDidNotPay}',
                subtitle: 'o\'quvchi',
                icon: Icons.cancel_rounded,
                color: AppColors.error,
                onTap: () => _openStatusPage(
                  context,
                  PaymentStatusType.unpaid,
                  report.unpaidStudents,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ReportStatCard(
          title: 'Davomat',
          value:
              '${report.attendanceStats.attendanceRate.toStringAsFixed(1)}%',
          subtitle:
              '${report.attendanceStats.totalPresent} kelgan, ${report.attendanceStats.totalAbsent} kelmagan',
          icon: Icons.fact_check_rounded,
          color: const Color(0xFF06B6D4),
        ),
        const SizedBox(height: 24),
        SectionHeader(
            title: 'Guruhlar statistikasi',
            count: report.groupStats.length),
        const SizedBox(height: 12),
        if (report.groupStats.isEmpty)
          const NoDataCard(
              message: 'Bu oy uchun guruh ma\'lumotlari yo\'q')
        else
          ...report.groupStats.map((g) => _GroupStatsCard(group: g)),
      ],
    );
  }
}

// ── Group stats card ─────────────────────────────────────────────────────────

class _GroupStatsCard extends StatelessWidget {
  final GroupMonthlyStats group;

  const _GroupStatsCard({required this.group});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral200.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral900.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding:
              const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                group.groupName.isNotEmpty
                    ? group.groupName[0].toUpperCase()
                    : 'G',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary),
              ),
            ),
          ),
          title: Text(group.groupName,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral800)),
          subtitle: Text('O\'qituvchi: ${group.teacherName}',
              style: TextStyle(
                  fontSize: 12, color: AppColors.neutral500)),
          children: [
            const Divider(),
            const SizedBox(height: 8),
            InfoRow(
                label: 'Faol o\'quvchilar',
                value: '${group.activeStudents}'),
            InfoRow(
                label: 'Kutilgan daromad',
                value:
                    '${formatAmount(group.expectedRevenue)} so\'m'),
            InfoRow(
              label: 'Haqiqiy daromad',
              value: '${formatAmount(group.actualRevenue)} so\'m',
              valueColor: AppColors.primary,
            ),
            InfoRow(
              label: 'Yig\'ish foizi',
              value: '${group.collectionRate.toStringAsFixed(1)}%',
              valueColor: AppColors.success,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: MiniStatCard(
                      label: 'To\'lagan',
                      value: '${group.paidStudents}',
                      color: AppColors.success),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: MiniStatCard(
                      label: 'To\'lamagan',
                      value: '${group.unpaidStudents}',
                      color: AppColors.warning),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error state ──────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline_rounded,
                size: 40, color: AppColors.error),
          ),
          const SizedBox(height: 20),
          Text('Xatolik yuz berdi',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error)),
          const SizedBox(height: 8),
          Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.neutral600)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Qayta urinish'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onLoad;

  const _EmptyState({required this.onLoad});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.calendar_month_rounded,
                size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          Text('Hisobot tanlang',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral700)),
          const SizedBox(height: 8),
          Text('Oy va yilni tanlang',
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: 14, color: AppColors.neutral500)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onLoad,
            icon: const Icon(Icons.download_rounded),
            label: const Text('Hisobotni yuklash'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

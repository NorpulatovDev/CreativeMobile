import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../data/models/report_models.dart';
import '../../bloc/report_bloc.dart';

class MonthlyReportTab extends StatefulWidget {
  const MonthlyReportTab({super.key});

  @override
  State<MonthlyReportTab> createState() => _MonthlyReportTabState();
}

class _MonthlyReportTabState extends State<MonthlyReportTab> with AutomaticKeepAliveClientMixin {
  late int _selectedYear;
  late int _selectedMonth;
  MonthlyReport? _cachedReport;
  String? _errorMessage;

  static const List<String> _monthNames = ['Yan', 'Fev', 'Mar', 'Apr', 'May', 'Iyun', 'Iyul', 'Avg', 'Sen', 'Okt', 'Noy', 'Dek'];

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
    setState(() => _errorMessage = null);
    context.read<ReportBloc>().add(ReportLoadMonthly(year: _selectedYear, month: _selectedMonth));
  }

  void _onYearChanged(int? year) {
    if (year != null && year != _selectedYear) {
      setState(() {
        _selectedYear = year;
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
      listenWhen: (previous, current) => current is ReportMonthlyLoaded || current is ReportError,
      listener: (context, state) {
        if (state is ReportMonthlyLoaded) {
          setState(() {
            _cachedReport = state.report;
            _errorMessage = null;
          });
        } else if (state is ReportError) {
          setState(() => _errorMessage = state.message);
        }
      },
      builder: (context, state) {
        if (state is ReportLoading && _cachedReport == null) {
          return Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        return RefreshIndicator(
          onRefresh: () async => _loadReport(),
          color: AppColors.primary,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildYearSelector(),
              const SizedBox(height: 16),
              _buildMonthSelector(state is ReportLoading),
              const SizedBox(height: 24),
              if (_errorMessage != null)
                _buildErrorState()
              else if (_cachedReport != null)
                _buildReportContent(_cachedReport!)
              else
                _buildEmptyState(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildYearSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral200.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: AppColors.neutral900.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Text('Yil:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.neutral700)),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedYear,
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.neutral400),
                items: _getAvailableYears().map((year) => DropdownMenuItem(value: year, child: Text('$year', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.neutral800)))).toList(),
                onChanged: _onYearChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector(bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral200.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: AppColors.neutral900.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Oy', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.neutral600)),
              if (isLoading) ...[
                const SizedBox(width: 8),
                SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
              ],
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6, childAspectRatio: 1.5, crossAxisSpacing: 8, mainAxisSpacing: 8),
            itemCount: 12,
            itemBuilder: (context, index) {
              final month = index + 1;
              final isSelected = month == _selectedMonth;
              final isEnabled = _isMonthEnabled(month);
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isEnabled ? () => _onMonthSelected(month) : null,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : (isEnabled ? AppColors.neutral50 : AppColors.neutral100),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSelected ? AppColors.primary : AppColors.neutral200),
                    ),
                    child: Center(
                      child: Text(
                        _monthNames[index],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : (isEnabled ? AppColors.neutral700 : AppColors.neutral400),
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

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.error.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.error_outline_rounded, size: 40, color: AppColors.error),
          ),
          const SizedBox(height: 20),
          Text('Xatolik yuz berdi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.error)),
          const SizedBox(height: 8),
          Text(_errorMessage ?? 'Noma\'lum xatolik', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColors.neutral600)),
          const SizedBox(height: 8),
          Text('Server bilan bog\'lanishda muammo bo\'lishi mumkin', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppColors.neutral500)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadReport,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Qayta urinish'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.calendar_month_rounded, size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          Text('Hisobot tanlang', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.neutral700)),
          const SizedBox(height: 8),
          Text('Oy va yilni tanlang', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColors.neutral500)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadReport,
            icon: const Icon(Icons.download_rounded),
            label: const Text('Hisobotni yuklash'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent(MonthlyReport report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Cards
        Row(
          children: [
            Expanded(child: _StatCard(title: 'Kutilgan', value: '${report.expectedRevenue.toStringAsFixed(0)}', subtitle: 'so\'m', icon: Icons.trending_up_rounded, color: AppColors.primary)),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(title: 'Haqiqiy', value: '${report.actualRevenue.toStringAsFixed(0)}', subtitle: 'so\'m', icon: Icons.account_balance_wallet_rounded, color: AppColors.success)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _StatCard(title: 'To\'lagan', value: '${report.studentsWhoPaid}', subtitle: 'o\'quvchi', icon: Icons.check_circle_rounded, color: AppColors.success)),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(title: 'To\'lamagan', value: '${report.studentsWhoDidNotPay}', subtitle: 'o\'quvchi', icon: Icons.schedule_rounded, color: AppColors.warning)),
          ],
        ),
        const SizedBox(height: 12),
        _StatCard(
          title: 'Davomat',
          value: '${report.attendanceStats.attendanceRate.toStringAsFixed(1)}%',
          subtitle: '${report.attendanceStats.totalPresent} kelgan, ${report.attendanceStats.totalAbsent} kelmagan',
          icon: Icons.fact_check_rounded,
          color: const Color(0xFF06B6D4),
        ),
        const SizedBox(height: 24),

        // Group Statistics
        _SectionHeader(title: 'Guruhlar statistikasi', count: report.groupStats.length),
        const SizedBox(height: 12),
        if (report.groupStats.isEmpty)
          _buildNoDataCard('Bu oy uchun guruh ma\'lumotlari yo\'q')
        else
          ...report.groupStats.map((group) => _GroupStatsCard(group: group)),

        if (report.unpaidStudents.isNotEmpty) ...[
          const SizedBox(height: 24),
          _SectionHeader(title: 'To\'lamagan o\'quvchilar', count: report.unpaidStudents.length),
          const SizedBox(height: 12),
          ...report.unpaidStudents.map((student) => _UnpaidStudentCard(student: student)),
        ],
      ],
    );
  }

  Widget _buildNoDataCard(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.neutral400),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: TextStyle(color: AppColors.neutral500))),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.subtitle, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral200.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: AppColors.neutral900.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 10),
              Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.neutral500)),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.neutral800)),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.neutral500)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int? count;

  const _SectionHeader({required this.title, this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.neutral800)),
        if (count != null) ...[
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(12)),
            child: Text('$count', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
          ),
        ],
      ],
    );
  }
}

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
        border: Border.all(color: AppColors.neutral200.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: AppColors.neutral900.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(group.groupName.isNotEmpty ? group.groupName[0].toUpperCase() : 'G', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary))),
          ),
          title: Text(group.groupName, style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.neutral800)),
          subtitle: Text('O\'qituvchi: ${group.teacherName}', style: TextStyle(fontSize: 12, color: AppColors.neutral500)),
          children: [
            const Divider(),
            const SizedBox(height: 8),
            _InfoRow(label: 'Faol o\'quvchilar', value: '${group.activeStudents}'),
            _InfoRow(label: 'Kutilgan daromad', value: '${group.expectedRevenue.toStringAsFixed(0)} so\'m'),
            _InfoRow(label: 'Haqiqiy daromad', value: '${group.actualRevenue.toStringAsFixed(0)} so\'m', valueColor: AppColors.primary),
            _InfoRow(label: 'Yig\'ish foizi', value: '${group.collectionRate.toStringAsFixed(1)}%', valueColor: AppColors.success),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _MiniStatCard(label: 'To\'lagan', value: '${group.paidStudents}', color: AppColors.success)),
                const SizedBox(width: 8),
                Expanded(child: _MiniStatCard(label: 'To\'lamagan', value: '${group.unpaidStudents}', color: AppColors.warning)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: AppColors.neutral500)),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: valueColor ?? AppColors.neutral700)),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.3))),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: color)),
        ],
      ),
    );
  }
}

class _UnpaidStudentCard extends StatelessWidget {
  final StudentPaymentStatus student;

  const _UnpaidStudentCard({required this.student});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: AppColors.neutral900.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(student.studentName.isNotEmpty ? student.studentName[0].toUpperCase() : '?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.error))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.studentName, style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.neutral800)),
                const SizedBox(height: 2),
                Text(student.groupName, style: TextStyle(fontSize: 12, color: AppColors.neutral500)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.phone_outlined, size: 12, color: AppColors.neutral400),
                    const SizedBox(width: 4),
                    Text(student.parentPhoneNumber, style: TextStyle(fontSize: 11, color: AppColors.neutral400)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: AppColors.errorLight, borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                Text('${student.amountDue.toStringAsFixed(0)}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.error)),
                Text('so\'m', style: TextStyle(fontSize: 10, color: AppColors.error)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
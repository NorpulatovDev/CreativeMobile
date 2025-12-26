import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../data/models/report_models.dart';
import '../../bloc/report_bloc.dart';

class YearlyReportTab extends StatefulWidget {
  const YearlyReportTab({super.key});

  @override
  State<YearlyReportTab> createState() => _YearlyReportTabState();
}

class _YearlyReportTabState extends State<YearlyReportTab> with AutomaticKeepAliveClientMixin {
  int _selectedYear = DateTime.now().year;
  YearlyReport? _cachedReport;
  String? _errorMessage;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  void _loadReport() {
    setState(() => _errorMessage = null);
    context.read<ReportBloc>().add(ReportLoadYearly(year: _selectedYear));
  }

  void _changeYear(int delta) {
    setState(() => _selectedYear += delta);
    _loadReport();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocConsumer<ReportBloc, ReportState>(
      listenWhen: (previous, current) => current is ReportYearlyLoaded || current is ReportError,
      listener: (context, state) {
        if (state is ReportYearlyLoaded) {
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
              _buildYearSelector(state is ReportLoading),
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

  Widget _buildYearSelector(bool isLoading) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral200.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: AppColors.neutral900.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.neutral100, borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.chevron_left_rounded, color: AppColors.neutral600),
            ),
            onPressed: () => _changeYear(-1),
            tooltip: 'Oldingi yil',
          ),
          Row(
            children: [
              if (isLoading) ...[
                SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                const SizedBox(width: 12),
              ],
              Text('$_selectedYear', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.neutral800)),
              const SizedBox(width: 8),
              Text('yil', style: TextStyle(fontSize: 14, color: AppColors.neutral500)),
            ],
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _selectedYear < DateTime.now().year ? AppColors.neutral100 : AppColors.neutral50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.chevron_right_rounded, color: _selectedYear < DateTime.now().year ? AppColors.neutral600 : AppColors.neutral300),
            ),
            onPressed: _selectedYear < DateTime.now().year ? () => _changeYear(1) : null,
            tooltip: 'Keyingi yil',
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
      decoration: BoxDecoration(color: AppColors.neutral50, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.calendar_today_rounded, size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          Text('Hisobot tanlang', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.neutral700)),
          const SizedBox(height: 8),
          Text('Yilni tanlang va hisobotni yuklang', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColors.neutral500)),
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

  Widget _buildReportContent(YearlyReport report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Total Revenue Card
        _TotalRevenueCard(report: report),
        const SizedBox(height: 12),

        // Attendance Card
        _StatCard(
          title: 'Davomat',
          value: '${report.attendanceStats.attendanceRate.toStringAsFixed(1)}%',
          subtitle: '${report.attendanceStats.totalPresent} kelgan, ${report.attendanceStats.totalAbsent} kelmagan',
          icon: Icons.fact_check_rounded,
          color: AppColors.success,
        ),
        const SizedBox(height: 24),

        // Monthly Breakdown
        _SectionHeader(title: 'Oylik daromad', count: report.monthlyBreakdown.length),
        const SizedBox(height: 12),
        if (report.monthlyBreakdown.isEmpty)
          _buildNoDataCard('Bu yil uchun daromad ma\'lumotlari yo\'q')
        else
          ...report.monthlyBreakdown.map((month) => _MonthlyRevenueCard(month: month)),

        // Teacher Performance
        if (report.teacherStats.isNotEmpty) ...[
          const SizedBox(height: 24),
          _SectionHeader(title: 'O\'qituvchilar natijasi', count: report.teacherStats.length),
          const SizedBox(height: 12),
          ...report.teacherStats.map((teacher) => _TeacherStatsCard(teacher: teacher)),
        ],

        // Top Groups
        if (report.topGroups.isNotEmpty) ...[
          const SizedBox(height: 24),
          _SectionHeader(title: 'Eng yaxshi guruhlar', count: report.topGroups.length),
          const SizedBox(height: 12),
          ...report.topGroups.asMap().entries.map((entry) => _TopGroupCard(rank: entry.key + 1, group: entry.value)),
        ],
      ],
    );
  }

  Widget _buildNoDataCard(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.neutral50, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.neutral200)),
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

class _TotalRevenueCard extends StatelessWidget {
  final YearlyReport report;

  const _TotalRevenueCard({required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.gradientStart, AppColors.gradientEnd]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Text('Jami daromad', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9))),
            ],
          ),
          const SizedBox(height: 16),
          Text('${report.totalRevenue.toStringAsFixed(0)}', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white)),
          Text('so\'m', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8))),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: Text('${report.totalPayments} ta to\'lov', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white)),
          ),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13, color: AppColors.neutral500)),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.neutral800)),
                Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.neutral500)),
              ],
            ),
          ),
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

class _MonthlyRevenueCard extends StatelessWidget {
  final MonthlyRevenueSummary month;

  const _MonthlyRevenueCard({required this.month});

  static const List<String> _monthNames = ['', 'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun', 'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr'];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.neutral200.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: AppColors.neutral900.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text('${month.month}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_monthNames[month.month], style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.neutral800)),
                const SizedBox(height: 2),
                Text('${month.paymentCount} ta to\'lov', style: TextStyle(fontSize: 12, color: AppColors.neutral500)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(10)),
            child: Text('${month.revenue.toStringAsFixed(0)} so\'m', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.success)),
          ),
        ],
      ),
    );
  }
}

class _TeacherStatsCard extends StatelessWidget {
  final TeacherYearlyStats teacher;

  const _TeacherStatsCard({required this.teacher});

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
            decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.person_rounded, color: const Color(0xFF8B5CF6)),
          ),
          title: Text(teacher.teacherName, style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.neutral800)),
          subtitle: Text('${teacher.groupCount} guruh • ${teacher.totalStudents} o\'quvchi', style: TextStyle(fontSize: 12, color: AppColors.neutral500)),
          children: [
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _MiniStatCard(label: 'Guruhlar', value: '${teacher.groupCount}', icon: Icons.groups_rounded, color: AppColors.primary)),
                const SizedBox(width: 8),
                Expanded(child: _MiniStatCard(label: 'O\'quvchilar', value: '${teacher.totalStudents}', icon: Icons.people_rounded, color: AppColors.success)),
                const SizedBox(width: 8),
                Expanded(child: _MiniStatCard(label: 'Daromad', value: '${(teacher.totalRevenue / 1000000).toStringAsFixed(1)}M', icon: Icons.payments_rounded, color: const Color(0xFF8B5CF6))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniStatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, color: color), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _TopGroupCard extends StatelessWidget {
  final int rank;
  final GroupYearlyStats group;

  const _TopGroupCard({required this.rank, required this.group});

  Color _getRankColor() {
    switch (rank) {
      case 1: return const Color(0xFFFFB800); // Gold
      case 2: return const Color(0xFF94A3B8); // Silver
      case 3: return const Color(0xFFCD7F32); // Bronze
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: rank <= 3 ? _getRankColor().withOpacity(0.3) : AppColors.neutral200.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: AppColors.neutral900.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: _getRankColor().withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Center(
              child: rank <= 3
                  ? Icon(Icons.emoji_events_rounded, color: _getRankColor(), size: 22)
                  : Text('$rank', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _getRankColor())),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(group.groupName, style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.neutral800)),
                const SizedBox(height: 2),
                Text('O\'qituvchi: ${group.teacherName}', style: TextStyle(fontSize: 12, color: AppColors.neutral500)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${group.totalRevenue.toStringAsFixed(0)}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
              Text('${group.totalPayments} to\'lov', style: TextStyle(fontSize: 11, color: AppColors.neutral500)),
            ],
          ),
        ],
      ),
    );
  }
}
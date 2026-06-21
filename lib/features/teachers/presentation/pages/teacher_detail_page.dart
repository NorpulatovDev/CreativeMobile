import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../data/models/teacher_monthly_report_model.dart';
import '../../data/repositories/teacher_repository.dart';
import '../utils/teacher_report_exporter.dart';

class TeacherDetailPage extends StatefulWidget {
  final int teacherId;

  const TeacherDetailPage({super.key, required this.teacherId});

  @override
  State<TeacherDetailPage> createState() => _TeacherDetailPageState();
}

class _TeacherDetailPageState extends State<TeacherDetailPage>
    with SingleTickerProviderStateMixin {
  static final _dayFormat = DateFormat('dd.MM');
  static final _numberFormat = NumberFormat('#,###');

  late TabController _tabController;
  late DateTime _selectedMonth;

  TeacherMonthlyReport? _report;
  bool _loading = true;
  bool _exporting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
    _loadReport();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReport() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final (report, error) = await getIt<TeacherRepository>().getMonthlyReport(
      widget.teacherId,
      _selectedMonth.year,
      _selectedMonth.month,
    );
    if (mounted) {
      setState(() {
        _report = report;
        _error = error;
        _loading = false;
      });
    }
  }

  void _previousMonth() {
    setState(() => _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1));
    _loadReport();
  }

  void _nextMonth() {
    if (_isCurrentMonth) return;
    setState(() => _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1));
    _loadReport();
  }

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return _selectedMonth.year == now.year && _selectedMonth.month == now.month;
  }

  String get _monthLabel => DateFormat('MMMM yyyy').format(_selectedMonth);

  String _formatAmount(double amount) => '${_numberFormat.format(amount)} so\'m';

  Future<void> _exportPdf() async {
    if (_report == null) return;
    setState(() => _exporting = true);
    try {
      await TeacherReportExporter.sharePdf(_report!);
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final teacherName = _report?.teacherName ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(teacherName.isNotEmpty ? teacherName : 'Teacher'),
        actions: [
          if (_report != null)
            _exporting
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : IconButton(
                    icon: const Icon(Icons.share),
                    tooltip: 'PDF ulashish',
                    onPressed: _exportPdf,
                  ),
        ],
        bottom: _loading
            ? null
            : TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Guruhlar', icon: Icon(Icons.groups)),
                  Tab(text: "To'lovlar", icon: Icon(Icons.payment)),
                ],
              ),
      ),
      body: Column(
        children: [
          _buildMonthSelector(),
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_error != null)
            Expanded(child: Center(child: Text(_error!)))
          else ...[
            _buildSummaryCard(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildGroupsTab(),
                  _buildPaymentsTab(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _loading ? null : _previousMonth,
          ),
          SizedBox(
            width: 160,
            child: Text(
              _monthLabel,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              color: _isCurrentMonth ? Theme.of(context).disabledColor : null,
            ),
            onPressed: (_loading || _isCurrentMonth) ? null : _nextMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final report = _report!;
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                report.teacherName[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(report.teacherName, style: Theme.of(context).textTheme.titleMedium),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 13),
                      const SizedBox(width: 4),
                      Text(report.phoneNumber, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatAmount(report.totalAmount),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${report.totalPaymentsCount} ta to'lov • ${report.groups.length} guruh",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupsTab() {
    final groups = _report!.groups;
    if (groups.isEmpty) {
      return const Center(child: Text('Bu oy uchun guruhlar topilmadi'));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        final progress = group.expectedRevenue > 0
            ? (group.actualRevenue / group.expectedRevenue).clamp(0.0, 1.0)
            : 0.0;

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () => context.push('${Routes.groups}/${group.groupId}'),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          group.groupName,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      _PaymentStatusChip(paid: group.paidStudents, unpaid: group.unpaidStudents),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InfoColumn(label: "O'quvchilar", value: '${group.activeStudents}'),
                      InfoColumn(label: "To'ladi", value: '${group.paidStudents}'),
                      InfoColumn(label: 'Qoldi', value: '${group.unpaidStudents}'),
                      InfoColumn(
                        label: "Yig'ildi",
                        value: _formatAmount(group.actualRevenue),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor:
                              Theme.of(context).colorScheme.surfaceContainerHighest,
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${group.collectionRate.toStringAsFixed(0)}%',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentsTab() {
    final payments = _report!.payments;
    if (payments.isEmpty) {
      return const Center(child: Text("Bu oy uchun to'lovlar topilmadi"));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final p = payments[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          leading: CircleAvatar(
            radius: 18,
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
          ),
          title: Text(p.studentName, style: const TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text(p.groupName, style: Theme.of(context).textTheme.bodySmall),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatAmount(p.amount),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Text(
                _dayFormat.format(p.paidAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PaymentStatusChip extends StatelessWidget {
  final int paid;
  final int unpaid;

  const _PaymentStatusChip({required this.paid, required this.unpaid});

  @override
  Widget build(BuildContext context) {
    final total = paid + unpaid;
    final color = unpaid == 0
        ? Colors.green
        : unpaid < paid
            ? Colors.orange
            : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$paid/$total',
        style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

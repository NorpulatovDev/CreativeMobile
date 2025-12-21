import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/routes.dart';
import '../../../groups/data/models/group_model.dart';
import '../../../groups/data/repositories/group_repository.dart';
import '../../../payments/data/models/payment_model.dart';
import '../../../payments/data/repositories/payment_repository.dart';
import '../../data/models/teacher_model.dart';
import '../../data/repositories/teacher_repository.dart';

class TeacherDetailPage extends StatefulWidget {
  final int teacherId;

  const TeacherDetailPage({super.key, required this.teacherId});

  @override
  State<TeacherDetailPage> createState() => _TeacherDetailPageState();
}

class _TeacherDetailPageState extends State<TeacherDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TeacherModel? _teacher;
  List<GroupModel> _groups = [];
  Map<int, List<PaymentModel>> _groupPayments = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final (teacher, _) =
        await getIt<TeacherRepository>().getById(widget.teacherId);
    final (groups, _) =
        await getIt<GroupRepository>().getByTeacherId(widget.teacherId);

    // Load payments for each group
    final groupPayments = <int, List<PaymentModel>>{};
    for (final group in groups ?? []) {
      final (payments, _) =
          await getIt<PaymentRepository>().getByGroupId(group.id);
      groupPayments[group.id] = payments ?? [];
    }

    if (mounted) {
      setState(() {
        _teacher = teacher;
        _groups = groups ?? [];
        _groupPayments = groupPayments;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  double get _totalPayments {
    double total = 0;
    for (final payments in _groupPayments.values) {
      for (final payment in payments) {
        total += payment.amount;
      }
    }
    return total;
  }

  int get _totalStudents {
    return _groups.fold(0, (sum, g) => sum + g.studentsCount);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_teacher == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Teacher not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_teacher!.fullName),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Groups', icon: Icon(Icons.groups)),
            Tab(text: 'Payments', icon: Icon(Icons.payment)),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildTeacherInfo(),
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
      ),
    );
  }

  Widget _buildTeacherInfo() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    _teacher!.fullName[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 24,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _teacher!.fullName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 16,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _teacher!.phoneNumber,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _InfoColumn(
                  label: 'Groups',
                  value: '${_groups.length}',
                ),
                _InfoColumn(
                  label: 'Students',
                  value: '$_totalStudents',
                ),
                _InfoColumn(
                  label: 'Total Income',
                  value: '${_totalPayments.toStringAsFixed(0)}',
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupsTab() {
    if (_groups.isEmpty) {
      return const Center(child: Text('No groups assigned'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _groups.length,
      itemBuilder: (context, index) {
        final group = _groups[index];
        final payments = _groupPayments[group.id] ?? [];
        final totalPaid = payments.fold(0.0, (sum, p) => sum + p.amount);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => context.push('${Routes.groups}/${group.id}'),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondaryContainer,
                        child: Icon(
                          Icons.groups,
                          color:
                              Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              group.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${group.studentsCount} students • ${group.monthlyFee.toStringAsFixed(0)} UZS/mo',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Collected: ${totalPaid.toStringAsFixed(0)} UZS',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: group.totalAmountToPay > 0
                                  ? (totalPaid / group.totalAmountToPay)
                                      .clamp(0.0, 1.0)
                                  : 0,
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${payments.length} payments',
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
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
    // Flatten all payments with group info
    final allPayments = <_PaymentWithGroup>[];
    for (final group in _groups) {
      final payments = _groupPayments[group.id] ?? [];
      for (final payment in payments) {
        allPayments.add(_PaymentWithGroup(payment: payment, group: group));
      }
    }

    // Sort by date, newest first
    allPayments.sort((a, b) => b.payment.paidAt.compareTo(a.payment.paidAt));

    if (allPayments.isEmpty) {
      return const Center(child: Text('No payments recorded'));
    }

    // Group by month
    final byMonth = <String, List<_PaymentWithGroup>>{};
    for (final pw in allPayments) {
      final key = DateFormat('yyyy-MM').format(pw.payment.paidAt);
      byMonth.putIfAbsent(key, () => []).add(pw);
    }

    final sortedMonths = byMonth.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedMonths.length,
      itemBuilder: (context, index) {
        final monthKey = sortedMonths[index];
        final payments = byMonth[monthKey]!;
        final monthTotal =
            payments.fold(0.0, (sum, pw) => sum + pw.payment.amount);
        final monthDate = DateTime.parse('$monthKey-01');

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            title: Text(
              DateFormat('MMMM yyyy').format(monthDate),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${payments.length} payments • ${monthTotal.toStringAsFixed(0)} UZS',
            ),
            children: payments
                .map((pw) => ListTile(
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor:
                            Theme.of(context).colorScheme.tertiaryContainer,
                        child: Icon(
                          Icons.payment,
                          size: 16,
                          color:
                              Theme.of(context).colorScheme.onTertiaryContainer,
                        ),
                      ),
                      title: Text(pw.payment.studentName),
                      subtitle: Text(
                        '${pw.group.name} • ${pw.payment.paidForMonth}',
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${pw.payment.amount.toStringAsFixed(0)} UZS',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          Text(
                            DateFormat('dd MMM').format(pw.payment.paidAt),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        );
      },
    );
  }
}

class _PaymentWithGroup {
  final PaymentModel payment;
  final GroupModel group;

  _PaymentWithGroup({required this.payment, required this.group});
}

class _InfoColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _InfoColumn({
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/routes.dart';
import '../../../enrollments/data/models/enrollment_model.dart';
import '../../../enrollments/data/repositories/enrollment_repository.dart';
import '../../../payments/data/models/payment_model.dart';
import '../../../payments/data/repositories/payment_repository.dart';
import '../../../payments/presentation/pages/payments_page.dart';
import '../../../students/data/models/student_model.dart';
import '../../../students/data/repositories/student_repository.dart';
import '../../data/models/group_model.dart';
import '../../data/repositories/group_repository.dart';

class GroupDetailPage extends StatefulWidget {
  final int groupId;

  const GroupDetailPage({super.key, required this.groupId});

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  GroupModel? _group;
  List<EnrollmentModel> _enrollments = [];
  List<PaymentModel> _payments = [];
  List<StudentModel> _allStudents = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final (group, _) = await getIt<GroupRepository>().getById(widget.groupId);
    final (enrollments, _) =
        await getIt<EnrollmentRepository>().getGroupStudents(widget.groupId);
    final (payments, _) =
        await getIt<PaymentRepository>().getByGroupId(widget.groupId);
    final (students, _) = await getIt<StudentRepository>().getAll();

    if (mounted) {
      setState(() {
        _group = group;
        _enrollments = enrollments ?? [];
        _payments = payments ?? [];
        _allStudents = students ?? [];
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_group == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Group not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_group!.name),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Students', icon: Icon(Icons.people)),
            Tab(text: 'Payments', icon: Icon(Icons.payment)),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildGroupInfo(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStudentsTab(),
                _buildPaymentsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            _showEnrollStudentDialog();
          } else {
            _showAddPaymentDialog();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGroupInfo() {
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
                  child: Icon(
                    Icons.groups,
                    size: 30,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _group!.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        'Teacher: ${_group!.teacherName}',
                        style: Theme.of(context).textTheme.bodyMedium,
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
                  label: 'Students',
                  value: '${_group!.studentsCount}',
                ),
                _InfoColumn(
                  label: 'Monthly Fee',
                  value: '${_group!.monthlyFee.toStringAsFixed(0)}',
                ),
                _InfoColumn(
                  label: 'Total Paid',
                  value: '${_group!.totalPaid.toStringAsFixed(0)}',
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsTab() {
    if (_enrollments.isEmpty) {
      return const Center(child: Text('No students enrolled'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _enrollments.length,
      itemBuilder: (context, index) {
        final enrollment = _enrollments[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Text(enrollment.studentName[0].toUpperCase()),
            ),
            title: Text(enrollment.studentName),
            subtitle: Text('Enrolled: ${enrollment.enrolledAt.toString().split(' ')[0]}'),
            trailing: IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              color: Theme.of(context).colorScheme.error,
              onPressed: () => _showRemoveStudentDialog(enrollment),
            ),
            onTap: () => context.push('${Routes.students}/${enrollment.studentId}'),
          ),
        );
      },
    );
  }

  Widget _buildPaymentsTab() {
    if (_payments.isEmpty) {
      return const Center(child: Text('No payments recorded'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _payments.length,
      itemBuilder: (context, index) {
        final payment = _payments[index];
        return Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.payment)),
            title: Text(payment.studentName),
            subtitle: Text('For: ${payment.paidForMonth}'),
            trailing: Text(
              '${payment.amount.toStringAsFixed(0)} UZS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEnrollStudentDialog() {
    final enrolledIds = _enrollments.map((e) => e.studentId).toSet();
    final availableStudents =
        _allStudents.where((s) => !enrolledIds.contains(s.id)).toList();

    if (availableStudents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All students are already enrolled')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => _EnrollStudentDialog(
        availableStudents: availableStudents,
        groupId: widget.groupId,
        onEnrolled: _loadData,
      ),
    );
  }

  void _showRemoveStudentDialog(EnrollmentModel enrollment) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove Student'),
        content: Text(
            'Remove ${enrollment.studentName} from ${_group!.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await getIt<EnrollmentRepository>()
                  .removeStudentFromGroup(enrollment.studentId, widget.groupId);
              _loadData();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showAddPaymentDialog() {
    if (_enrollments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No students enrolled in this group')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => PaymentFormDialog(
        preselectedGroupId: widget.groupId,
      ),
    ).then((_) => _loadData());
  }
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

class _EnrollStudentDialog extends StatefulWidget {
  final List<StudentModel> availableStudents;
  final int groupId;
  final VoidCallback onEnrolled;

  const _EnrollStudentDialog({
    required this.availableStudents,
    required this.groupId,
    required this.onEnrolled,
  });

  @override
  State<_EnrollStudentDialog> createState() => _EnrollStudentDialogState();
}

class _EnrollStudentDialogState extends State<_EnrollStudentDialog> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<StudentModel> get _filteredStudents {
    if (_searchQuery.isEmpty) {
      return widget.availableStudents;
    }
    return widget.availableStudents.where((s) {
      return s.fullName.toLowerCase().contains(_searchQuery) ||
          s.parentName.toLowerCase().contains(_searchQuery) ||
          s.parentPhoneNumber.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enroll Student'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
            ),
            const SizedBox(height: 16),
            // Student List
            Expanded(
              child: _filteredStudents.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 48,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No students found',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredStudents.length,
                      itemBuilder: (context, index) {
                        final student = _filteredStudents[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              child: Text(
                                student.fullName[0].toUpperCase(),
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                ),
                              ),
                            ),
                            title: Text(
                              student.fullName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(student.parentPhoneNumber),
                            trailing: const Icon(Icons.add_circle_outline),
                            onTap: () async {
                              Navigator.pop(context);
                              await getIt<EnrollmentRepository>()
                                  .addStudentToGroup(
                                      student.id, widget.groupId);
                              widget.onEnrolled();
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
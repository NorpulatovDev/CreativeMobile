import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../enrollments/data/models/enrollment_model.dart';
import '../../../enrollments/data/repositories/enrollment_repository.dart';
import '../../../groups/data/models/group_model.dart';
import '../../../groups/data/repositories/group_repository.dart';
import '../../data/models/payment_model.dart';
import '../bloc/payment_bloc.dart';

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PaymentBloc>()..add(PaymentLoadAll()),
      child: const PaymentsView(),
    );
  }
}

class PaymentsView extends StatelessWidget {
  const PaymentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
      ),
      body: BlocConsumer<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state is PaymentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
          if (state is PaymentActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is PaymentLoading && state is! PaymentLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PaymentLoaded) {
            if (state.payments.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.payment_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No payments yet',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () => _showPaymentDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Payment'),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<PaymentBloc>().add(PaymentLoadAll());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.payments.length,
                itemBuilder: (context, index) {
                  final payment = state.payments[index];
                  return _PaymentCard(payment: payment);
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPaymentDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<PaymentBloc>(),
        child: const PaymentFormDialog(),
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final PaymentModel payment;

  const _PaymentCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.payment,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payment.studentName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${payment.groupName} • ${payment.paidForMonth}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateFormat.format(payment.paidAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ],
              ),
            ),
            Text(
              '${payment.amount.toStringAsFixed(0)} UZS',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentFormDialog extends StatefulWidget {
  final int? preselectedStudentId;
  final int? preselectedGroupId;

  const PaymentFormDialog({
    super.key,
    this.preselectedStudentId,
    this.preselectedGroupId,
  });

  @override
  State<PaymentFormDialog> createState() => _PaymentFormDialogState();
}

class _PaymentFormDialogState extends State<PaymentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  List<GroupModel> _groups = [];
  List<EnrollmentModel> _groupStudents = [];
  bool _loadingGroups = true;
  bool _loadingStudents = false;

  int? _selectedGroupId;
  int? _selectedStudentId;
  String _selectedMonth = DateFormat('yyyy-MM').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _selectedGroupId = widget.preselectedGroupId;
    _selectedStudentId = widget.preselectedStudentId;
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final (groups, _) = await getIt<GroupRepository>().getAll();
    if (mounted) {
      setState(() {
        _groups = groups ?? [];
        _loadingGroups = false;
      });

      // If group is preselected, load its students
      if (_selectedGroupId != null) {
        _loadStudentsForGroup(_selectedGroupId!);
        // Pre-fill amount
        final group = _groups.firstWhere((g) => g.id == _selectedGroupId);
        _amountController.text = group.monthlyFee.toStringAsFixed(0);
      }
    }
  }

  Future<void> _loadStudentsForGroup(int groupId) async {
    setState(() {
      _loadingStudents = true;
      _groupStudents = [];
      // Reset student selection if not preselected
      if (widget.preselectedStudentId == null) {
        _selectedStudentId = null;
      }
    });

    final (enrollments, _) =
        await getIt<EnrollmentRepository>().getGroupStudents(groupId);

    if (mounted) {
      setState(() {
        _groupStudents = (enrollments ?? []).where((e) => e.active).toList();
        _loadingStudents = false;

        // If student was preselected, verify they're in this group
        if (_selectedStudentId != null) {
          final exists =
              _groupStudents.any((e) => e.studentId == _selectedStudentId);
          if (!exists) {
            _selectedStudentId = null;
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Payment'),
      content: _loadingGroups
          ? const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Step 1: Select Group
                    DropdownButtonFormField<int>(
                      value: _selectedGroupId,
                      decoration: const InputDecoration(
                        labelText: 'Group',
                        prefixIcon: Icon(Icons.group_outlined),
                      ),
                      items: _groups
                          .map((g) => DropdownMenuItem(
                                value: g.id,
                                child: Text(
                                    '${g.name} (${g.monthlyFee.toStringAsFixed(0)} UZS)'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedGroupId = value;
                            final group =
                                _groups.firstWhere((g) => g.id == value);
                            _amountController.text =
                                group.monthlyFee.toStringAsFixed(0);
                          });
                          _loadStudentsForGroup(value);
                        }
                      },
                      validator: (value) {
                        if (value == null) return 'Please select a group';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Step 2: Select Student from Group
                    if (_selectedGroupId != null) ...[
                      if (_loadingStudents)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        )
                      else if (_groupStudents.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .errorContainer
                                .withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_outlined,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text('No students enrolled in this group'),
                              ),
                            ],
                          ),
                        )
                      else
                        DropdownButtonFormField<int>(
                          value: _selectedStudentId,
                          decoration: const InputDecoration(
                            labelText: 'Student',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          items: _groupStudents
                              .map((e) => DropdownMenuItem(
                                    value: e.studentId,
                                    child: Text(e.studentName),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() => _selectedStudentId = value);
                          },
                          validator: (value) {
                            if (value == null) return 'Please select a student';
                            return null;
                          },
                        ),
                      const SizedBox(height: 16),
                    ],

                    // Step 3: Amount
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount (UZS)',
                        prefixIcon: Icon(Icons.payments_outlined),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter amount';
                        }
                        if (double.tryParse(value) == null ||
                            double.parse(value) <= 0) {
                          return 'Please enter a valid amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Step 4: Month
                    DropdownButtonFormField<String>(
                      value: _selectedMonth,
                      decoration: const InputDecoration(
                        labelText: 'Paid For Month',
                        prefixIcon: Icon(Icons.calendar_month_outlined),
                      ),
                      items: _generateMonths()
                          .map((m) => DropdownMenuItem(
                                value: m,
                                child: Text(m),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedMonth = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _loadingGroups ||
                  _loadingStudents ||
                  _selectedGroupId == null ||
                  _groupStudents.isEmpty
              ? null
              : _submit,
          child: const Text('Create'),
        ),
      ],
    );
  }

  List<String> _generateMonths() {
    final now = DateTime.now();
    final months = <String>[];
    for (var i = -3; i <= 3; i++) {
      final date = DateTime(now.year, now.month + i, 1);
      months.add(DateFormat('yyyy-MM').format(date));
    }
    return months;
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<PaymentBloc>().add(PaymentCreate(
            studentId: _selectedStudentId!,
            groupId: _selectedGroupId!,
            amount: double.parse(_amountController.text.trim()),
            paidForMonth: _selectedMonth,
          ));
      Navigator.pop(context);
    }
  }
}
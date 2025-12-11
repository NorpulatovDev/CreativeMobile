import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../data/models/models.dart';
import '../../../groups/data/models/models.dart';
import '../../../students/data/models/models.dart';
import '../bloc/payment_bloc.dart';
import '../widgets/payment_form_dialog.dart';

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PaymentBloc>()..add(const PaymentLoadAll()),
      child: const PaymentsView(),
    );
  }
}

class PaymentsView extends StatefulWidget {
  const PaymentsView({super.key});

  @override
  State<PaymentsView> createState() => _PaymentsViewState();
}

class _PaymentsViewState extends State<PaymentsView> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Payment> _filterPayments(List<Payment> payments) {
    if (_searchQuery.isEmpty) return payments;
    
    final query = _searchQuery.toLowerCase();
    return payments.where((payment) {
      return payment.studentName.toLowerCase().contains(query) ||
          payment.groupName.toLowerCase().contains(query) ||
          payment.paidForMonth.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
      ),
      floatingActionButton: BlocBuilder<PaymentBloc, PaymentState>(
        builder: (context, state) {
          if (state is PaymentLoaded && state.students.isNotEmpty && state.groups.isNotEmpty) {
            return FloatingActionButton(
              onPressed: () => _showAddDialog(context, state.students, state.groups),
              child: const Icon(Icons.add),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      body: BlocConsumer<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state is PaymentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is PaymentSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payment recorded successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const Center(child: CircularProgressIndicator()),
            loaded: (payments, filteredPayments, students, groups, 
                    selectedStudentId, selectedGroupId) =>
                _buildContent(
              context,
              payments,
              filteredPayments,
              students,
              groups,
              selectedStudentId,
              selectedGroupId,
            ),
            saving: () => const Center(child: CircularProgressIndicator()),
            saved: () => const SizedBox.shrink(),
            error: (message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(message),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () =>
                        context.read<PaymentBloc>().add(const PaymentLoadAll()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<Payment> allPayments,
    List<Payment> filteredPayments,
    List<Student> students,
    List<Group> groups,
    int? selectedStudentId,
    int? selectedGroupId,
  ) {
    final totalAmount = filteredPayments.fold<double>(
      0,
      (sum, payment) => sum + payment.amount,
    );

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by student, group, or month...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),

        // Filter chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int?>(
                  value: selectedStudentId,
                  decoration: const InputDecoration(
                    labelText: 'Filter by Student',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Students'),
                    ),
                    ...students.map((student) {
                      return DropdownMenuItem(
                        value: student.id,
                        child: Text(student.fullName, overflow: TextOverflow.ellipsis),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    context.read<PaymentBloc>().add(
                          PaymentFilterByStudent(studentId: value),
                        );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int?>(
                  value: selectedGroupId,
                  decoration: const InputDecoration(
                    labelText: 'Filter by Group',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Groups'),
                    ),
                    ...groups.map((group) {
                      return DropdownMenuItem(
                        value: group.id,
                        child: Text(group.name, overflow: TextOverflow.ellipsis),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    context.read<PaymentBloc>().add(
                          PaymentFilterByGroup(groupId: value),
                        );
                  },
                ),
              ),
            ],
          ),
        ),

        // Total summary
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.teal.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Payments',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '${_filterPayments(filteredPayments).length} records',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total Amount',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '${NumberFormat('#,###').format(totalAmount)} so\'m',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.teal,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Payments list
        Expanded(
          child: _buildPaymentsList(_filterPayments(filteredPayments)),
        ),
      ],
    );
  }

  Widget _buildPaymentsList(List<Payment> payments) {
    if (payments.isEmpty) {
      return const Center(child: Text('No payments found'));
    }

    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.teal,
              child: Text(
                payment.studentName[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(payment.studentName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${payment.groupName} • ${payment.paidForMonth}'),
                Text(
                  dateFormat.format(payment.paidAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
            trailing: Text(
              '${NumberFormat('#,###').format(payment.amount)} so\'m',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  void _showAddDialog(
    BuildContext context,
    List<Student> students,
    List<Group> groups,
  ) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => PaymentFormDialog(students: students, groups: groups),
    );

    if (result != null && context.mounted) {
      context.read<PaymentBloc>().add(PaymentCreate(
            studentId: result['studentId'],
            groupId: result['groupId'],
            amount: result['amount'],
            paidForMonth: result['paidForMonth'],
          ));
    }
  }
}
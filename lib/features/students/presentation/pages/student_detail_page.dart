import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/student.dart';
import '../../data/models/student_group.dart';
import '../bloc/student_bloc.dart';
import '../bloc/student_event.dart';
import '../bloc/student_state.dart';
import '../widgets/add_group_dialog.dart';

class StudentDetailPage extends StatefulWidget {
  final int studentId;

  const StudentDetailPage({super.key, required this.studentId});

  @override
  State<StudentDetailPage> createState() => _StudentDetailPageState();
}

class _StudentDetailPageState extends State<StudentDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<StudentBloc>().add(LoadStudentDetail(widget.studentId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<StudentBloc>().add(LoadStudentDetail(widget.studentId));
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddToGroupDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add to Group'),
      ),
      body: BlocConsumer<StudentBloc, StudentState>(
        listener: (context, state) {
          if (state is StudentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is StudentOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is StudentLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is StudentDetailLoaded) {
            return _buildContent(context, state.student, state.enrollments);
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    Student student,
    List<StudentGroup> enrollments,
  ) {
    final activeEnrollments = enrollments.where((e) => e.active).toList();
    final pastEnrollments = enrollments.where((e) => !e.active).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    child: Text(
                      student.fullName[0].toUpperCase(),
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    student.fullName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (student.smsLinked)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'SMS Linked',
                            style: TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  _InfoRow(icon: Icons.person, label: 'Parent', value: student.parentName),
                  _InfoRow(icon: Icons.phone, label: 'Phone', value: student.parentPhoneNumber),
                  _InfoRow(
                    icon: Icons.payment,
                    label: 'Total Paid',
                    value: '\$${student.totalPaid.toStringAsFixed(2)}',
                  ),
                  _InfoRow(
                    icon: Icons.group,
                    label: 'Active Groups',
                    value: '${student.activeGroupsCount}',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Active Groups
          Text(
            'Active Groups (${activeEnrollments.length})',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (activeEnrollments.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text('Not enrolled in any group'),
                ),
              ),
            )
          else
            ...activeEnrollments.map(
              (e) => _EnrollmentCard(
                enrollment: e,
                onRemove: () => _confirmRemove(context, e),
              ),
            ),

          // Past Groups
          if (pastEnrollments.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Past Groups (${pastEnrollments.length})',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            ...pastEnrollments.map(
              (e) => _EnrollmentCard(enrollment: e, isPast: true),
            ),
          ],

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _showAddToGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AddToGroupDialog(studentId: widget.studentId),
    ).then((groupId) {
      if (groupId != null) {
        context.read<StudentBloc>().add(
              AddStudentToGroup(widget.studentId, groupId),
            );
      }
    });
  }

  void _confirmRemove(BuildContext context, StudentGroup enrollment) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove from Group'),
        content: Text(
          'Remove this student from "${enrollment.groupName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<StudentBloc>().add(
                    RemoveStudentFromGroup(
                      enrollment.studentId,
                      enrollment.groupId,
                    ),
                  );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text('$label:', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _EnrollmentCard extends StatelessWidget {
  final StudentGroup enrollment;
  final VoidCallback? onRemove;
  final bool isPast;

  const _EnrollmentCard({
    required this.enrollment,
    this.onRemove,
    this.isPast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isPast ? Colors.grey[100] : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isPast ? Colors.grey : Colors.blue,
          child: const Icon(Icons.school, color: Colors.white),
        ),
        title: Text(
          enrollment.groupName,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isPast ? Colors.grey[600] : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Teacher: ${enrollment.teacherName}'),
            Text('Fee: \$${enrollment.monthlyFee.toStringAsFixed(2)}/month'),
            Text(
              isPast
                  ? 'Left: ${enrollment.leftAt ?? "N/A"}'
                  : 'Enrolled: ${enrollment.enrolledAt}',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
        trailing: isPast
            ? null
            : IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                onPressed: onRemove,
              ),
        isThreeLine: true,
      ),
    );
  }
}
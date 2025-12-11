import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../data/models/models.dart';
import '../../../groups/data/models/models.dart';
import '../bloc/student_bloc.dart';
import '../widgets/student_form_dialog.dart';
import '../widgets/assign_group_dialog.dart';

class StudentsPage extends StatelessWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<StudentBloc>()..add(const StudentLoadAll()),
      child: const StudentsView(),
    );
  }
}

class StudentsView extends StatefulWidget {
  const StudentsView({super.key});

  @override
  State<StudentsView> createState() => _StudentsViewState();
}

class _StudentsViewState extends State<StudentsView> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Student> _filterStudents(List<Student> students) {
    if (_searchQuery.isEmpty) return students;
    
    final query = _searchQuery.toLowerCase();
    return students.where((student) {
      return student.fullName.toLowerCase().contains(query) ||
          student.parentName.toLowerCase().contains(query) ||
          student.parentPhoneNumber.contains(query) ||
          student.smsLinkCode.toLowerCase().contains(query) ||
          (student.activeGroupName?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
      ),
      floatingActionButton: BlocBuilder<StudentBloc, StudentState>(
        builder: (context, state) {
          if (state is StudentLoaded) {
            return FloatingActionButton(
              onPressed: () => _showAddDialog(context, state.groups),
              child: const Icon(Icons.add),
            );
          }
          return const SizedBox.shrink();
        },
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
        },
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const Center(child: CircularProgressIndicator()),
            loaded: (students, groups) => Column(
              children: [
                _buildSearchBar(),
                Expanded(
                  child: _buildList(context, _filterStudents(students), groups),
                ),
              ],
            ),
            error: (message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(message),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () =>
                        context.read<StudentBloc>().add(const StudentLoadAll()),
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by name, phone, group, or code...',
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
    );
  }

  Widget _buildList(
    BuildContext context,
    List<Student> students,
    List<Group> groups,
  ) {
    if (students.isEmpty) {
      return const Center(child: Text('No students yet'));
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      child: Text(student.fullName[0].toUpperCase()),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.fullName,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            student.activeGroupName ?? 'No group',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: student.activeGroupName != null
                                      ? Colors.teal
                                      : Colors.grey,
                                ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            _showEditDialog(context, student, groups);
                            break;
                          case 'assign':
                            _showAssignDialog(context, student, groups);
                            break;
                          case 'copy_code':
                            _copyCode(context, student.smsLinkCode);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'assign',
                          child: Row(
                            children: [
                              Icon(Icons.group_add),
                              SizedBox(width: 8),
                              Text('Assign Group'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'copy_code',
                          child: Row(
                            children: [
                              Icon(Icons.copy),
                              SizedBox(width: 8),
                              Text('Copy SMS Code'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        context,
                        Icons.person_outline,
                        'Parent',
                        student.parentName,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        context,
                        Icons.phone_outlined,
                        'Phone',
                        student.parentPhoneNumber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatusChip(
                      context,
                      student.smsLinked ? Icons.check_circle : Icons.cancel,
                      'SMS ${student.smsLinked ? "Linked" : "Not Linked"}',
                      student.smsLinked ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    _buildStatusChip(
                      context,
                      Icons.attach_money,
                      '${student.totalPaid.toStringAsFixed(0)} so\'m',
                      Colors.teal,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Code: ${student.smsLinkCode}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                            ),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () => _copyCode(context, student.smsLinkCode),
                        child: const Icon(Icons.copy, size: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
        ),
        Flexible(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  void _copyCode(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Code $code copied to clipboard'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAddDialog(BuildContext context, List<Group> groups) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => StudentFormDialog(groups: groups),
    );

    if (result != null && context.mounted) {
      context.read<StudentBloc>().add(StudentCreate(
            fullName: result['fullName'],
            parentName: result['parentName'],
            parentPhoneNumber: result['parentPhoneNumber'],
            activeGroupId: result['activeGroupId'],
          ));
    }
  }

  void _showEditDialog(
    BuildContext context,
    Student student,
    List<Group> groups,
  ) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => StudentFormDialog(student: student, groups: groups),
    );

    if (result != null && context.mounted) {
      context.read<StudentBloc>().add(StudentUpdate(
            id: student.id,
            fullName: result['fullName'],
            parentName: result['parentName'],
            parentPhoneNumber: result['parentPhoneNumber'],
            activeGroupId: result['activeGroupId'],
          ));
    }
  }

  void _showAssignDialog(
    BuildContext context,
    Student student,
    List<Group> groups,
  ) async {
    final result = await showDialog<int?>(
      context: context,
      builder: (_) => AssignGroupDialog(student: student, groups: groups),
    );

    if (context.mounted) {
      if (result != null) {
        context.read<StudentBloc>().add(StudentAssignToGroup(
              studentId: student.id,
              groupId: result,
            ));
      } else if (result == null && student.activeGroupId != null) {
        context.read<StudentBloc>().add(StudentRemoveFromGroup(
              studentId: student.id,
            ));
      }
    }
  }
}
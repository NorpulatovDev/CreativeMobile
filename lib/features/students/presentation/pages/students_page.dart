import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/routes.dart';
import '../../../enrollments/data/repositories/enrollment_repository.dart';
import '../../../groups/data/models/group_model.dart';
import '../../../groups/data/repositories/group_repository.dart';
import '../../data/models/student_model.dart';
import '../bloc/student_bloc.dart';

class StudentsPage extends StatelessWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<StudentBloc>()..add(StudentLoadAll()),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search students...',
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
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
            ),
          ),
          // Student List
          Expanded(
            child: BlocConsumer<StudentBloc, StudentState>(
              listener: (context, state) {
                if (state is StudentError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
                if (state is StudentActionSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              builder: (context, state) {
                if (state is StudentLoading && state is! StudentLoaded) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is StudentLoaded) {
                  final filteredStudents = _searchQuery.isEmpty
                      ? state.students
                      : state.students.where((s) {
                          return s.fullName.toLowerCase().contains(_searchQuery) ||
                              s.parentName.toLowerCase().contains(_searchQuery) ||
                              s.parentPhoneNumber.contains(_searchQuery);
                        }).toList();

                  if (state.students.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_off_outlined,
                            size: 64,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No students yet',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => _showStudentDialog(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Student'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (filteredStudents.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No students found for "$_searchQuery"',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<StudentBloc>().add(StudentLoadAll());
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredStudents.length,
                      itemBuilder: (context, index) {
                        final student = filteredStudents[index];
                        return _StudentCard(student: student);
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showStudentDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showStudentDialog(BuildContext context, [StudentModel? student]) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<StudentBloc>(),
        child: StudentFormDialog(student: student),
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final StudentModel student;

  const _StudentCard({required this.student});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('${Routes.students}/${student.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: student.paidForCurrentMonth
                        ? Colors.green.withOpacity(0.2)
                        : Colors.orange.withOpacity(0.2),
                    child: Icon(
                      student.paidForCurrentMonth
                          ? Icons.check_circle
                          : Icons.warning,
                      color: student.paidForCurrentMonth
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.fullName,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          student.parentName,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditDialog(context);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _StatusChip(
                    icon: Icons.phone_outlined,
                    label: student.parentPhoneNumber,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  _StatusChip(
                    icon: Icons.group,
                    label: '${student.activeGroupsCount} groups',
                    color: Colors.blue,
                  ),
                  _StatusChip(
                    icon: Icons.payment,
                    label: '${student.totalPaid.toStringAsFixed(0)} UZS',
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  if (student.groupsPaidCount > 0)
                    _StatusChip(
                      icon: Icons.check_circle,
                      label: '${student.groupsPaidCount} paid',
                      color: Colors.green,
                    ),
                  if (student.groupsUnpaidCount > 0)
                    _StatusChip(
                      icon: Icons.warning,
                      label: '${student.groupsUnpaidCount} unpaid',
                      color: Colors.orange,
                    ),
                ],
              ),
              if (student.activeGroups.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: student.activeGroups
                      .map((g) => Chip(
                            label: Text(g.groupName),
                            visualDensity: VisualDensity.compact,
                            labelStyle: Theme.of(context).textTheme.bodySmall,
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<StudentBloc>(),
        child: StudentFormDialog(student: student),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatusChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class StudentFormDialog extends StatefulWidget {
  final StudentModel? student;

  const StudentFormDialog({super.key, this.student});

  @override
  State<StudentFormDialog> createState() => _StudentFormDialogState();
}

class _StudentFormDialogState extends State<StudentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _parentNameController;
  late final TextEditingController _phoneController;

  List<GroupModel> _groups = [];
  int? _selectedGroupId;
  bool _loadingGroups = true;
  bool _submitting = false;

  bool get isEditing => widget.student != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student?.fullName);
    _parentNameController =
        TextEditingController(text: widget.student?.parentName);
    _phoneController =
        TextEditingController(text: widget.student?.parentPhoneNumber);

    // Only load groups when creating new student
    if (!isEditing) {
      _loadGroups();
    } else {
      _loadingGroups = false;
    }
  }

  Future<void> _loadGroups() async {
    final (groups, _) = await getIt<GroupRepository>().getAll();
    if (mounted) {
      setState(() {
        _groups = groups ?? [];
        _loadingGroups = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _parentNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditing ? 'Edit Student' : 'Add Student'),
      content: _loadingGroups
          ? const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Student Full Name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter student name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _parentNameController,
                      decoration: const InputDecoration(
                        labelText: 'Parent Name',
                        prefixIcon: Icon(Icons.family_restroom_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter parent name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Parent Phone Number',
                        prefixIcon: Icon(Icons.phone_outlined),
                        hintText: '+998XXXXXXXXX',
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter phone number';
                        }
                        if (!RegExp(r'^\+998[0-9]{9}$').hasMatch(value)) {
                          return 'Format: +998XXXXXXXXX';
                        }
                        return null;
                      },
                    ),
                    // Optional Group Selection (only for new students)
                    if (!isEditing && _groups.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int?>(
                        value: _selectedGroupId,
                        decoration: const InputDecoration(
                          labelText: 'Enroll in Group (Optional)',
                          prefixIcon: Icon(Icons.group_outlined),
                        ),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('No group'),
                          ),
                          ..._groups.map((g) => DropdownMenuItem<int?>(
                                value: g.id,
                                child: Text(g.name),
                              )),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedGroupId = value);
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _loadingGroups || _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Update' : 'Create'),
        ),
      ],
    );
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _submitting = true);

      final bloc = context.read<StudentBloc>();
      if (isEditing) {
        bloc.add(StudentUpdate(
          id: widget.student!.id,
          fullName: _nameController.text.trim(),
          parentName: _parentNameController.text.trim(),
          parentPhoneNumber: _phoneController.text.trim(),
        ));
        Navigator.pop(context);
      } else {
        // Create student and optionally enroll in group
        bloc.add(StudentCreateWithGroup(
          fullName: _nameController.text.trim(),
          parentName: _parentNameController.text.trim(),
          parentPhoneNumber: _phoneController.text.trim(),
          groupId: _selectedGroupId,
        ));
        Navigator.pop(context);
      }
    }
  }
}
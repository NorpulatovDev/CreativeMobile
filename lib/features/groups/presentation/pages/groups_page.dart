import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/routes.dart';
import '../../../teachers/data/models/teacher_model.dart';
import '../../../teachers/data/repositories/teacher_repository.dart';
import '../../data/models/group_model.dart';
import '../bloc/group_bloc.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<GroupBloc>()..add(GroupLoadAll()),
      child: const GroupsView(),
    );
  }
}

class GroupsView extends StatelessWidget {
  const GroupsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
      ),
      body: BlocConsumer<GroupBloc, GroupState>(
        listener: (context, state) {
          if (state is GroupError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
          if (state is GroupActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is GroupLoading && state is! GroupLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is GroupLoaded) {
            if (state.groups.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.groups_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No groups yet',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () => _showGroupDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Group'),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<GroupBloc>().add(GroupLoadAll());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.groups.length,
                itemBuilder: (context, index) {
                  final group = state.groups[index];
                  return _GroupCard(group: group);
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showGroupDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showGroupDialog(BuildContext context, [GroupModel? group]) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<GroupBloc>(),
        child: GroupFormDialog(group: group),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final GroupModel group;

  const _GroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final debt = group.totalAmountToPay - group.totalPaid;
    final isDebt = debt > 0;

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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          group.teacherName,
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
                      } else if (value == 'delete') {
                        _showDeleteDialog(context);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(
                          value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.people_outline,
                    label: '${group.studentsCount} students',
                  ),
                  const SizedBox(width: 12),
                  _InfoChip(
                    icon: Icons.payments_outlined,
                    label: '${group.monthlyFee.toStringAsFixed(0)} UZS/mo',
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
                          'Paid: ${group.totalPaid.toStringAsFixed(0)} UZS',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: group.totalAmountToPay > 0
                              ? (group.totalPaid / group.totalAmountToPay)
                                  .clamp(0.0, 1.0)
                              : 0,
                          backgroundColor:
                              Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDebt
                          ? Theme.of(context)
                              .colorScheme
                              .errorContainer
                              .withOpacity(0.5)
                          : Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isDebt
                          ? '-${debt.toStringAsFixed(0)}'
                          : '+${(-debt).toStringAsFixed(0)}',
                      style: TextStyle(
                        color: isDebt
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
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
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<GroupBloc>(),
        child: GroupFormDialog(group: group),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Group'),
        content: Text(
            'Are you sure you want to delete ${group.name}? This will also delete all related attendance and payment records.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<GroupBloc>().add(GroupDelete(group.id));
              Navigator.pop(dialogContext);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class GroupFormDialog extends StatefulWidget {
  final GroupModel? group;

  const GroupFormDialog({super.key, this.group});

  @override
  State<GroupFormDialog> createState() => _GroupFormDialogState();
}

class _GroupFormDialogState extends State<GroupFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _feeController;
  int? _selectedTeacherId;
  List<TeacherModel> _teachers = [];
  bool _loadingTeachers = true;

  bool get isEditing => widget.group != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.group?.name);
    _feeController = TextEditingController(
      text: widget.group?.monthlyFee.toStringAsFixed(0),
    );
    _selectedTeacherId = widget.group?.teacherId;
    _loadTeachers();
  }

  Future<void> _loadTeachers() async {
    final (teachers, _) = await getIt<TeacherRepository>().getAll();
    if (mounted) {
      setState(() {
        _teachers = teachers ?? [];
        _loadingTeachers = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditing ? 'Edit Group' : 'Add Group'),
      content: _loadingTeachers
          ? const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
          : Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Group Name',
                      prefixIcon: Icon(Icons.group_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter group name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: _selectedTeacherId,
                    decoration: const InputDecoration(
                      labelText: 'Teacher',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    items: _teachers
                        .map((t) => DropdownMenuItem(
                              value: t.id,
                              child: Text(t.fullName),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedTeacherId = value);
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a teacher';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _feeController,
                    decoration: const InputDecoration(
                      labelText: 'Monthly Fee (UZS)',
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter monthly fee';
                      }
                      if (double.tryParse(value) == null ||
                          double.parse(value) <= 0) {
                        return 'Please enter a valid amount';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _loadingTeachers ? null : _submit,
          child: Text(isEditing ? 'Update' : 'Create'),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final bloc = context.read<GroupBloc>();
      if (isEditing) {
        bloc.add(GroupUpdate(
          id: widget.group!.id,
          name: _nameController.text.trim(),
          teacherId: _selectedTeacherId!,
          monthlyFee: double.parse(_feeController.text.trim()),
        ));
      } else {
        bloc.add(GroupCreate(
          name: _nameController.text.trim(),
          teacherId: _selectedTeacherId!,
          monthlyFee: double.parse(_feeController.text.trim()),
        ));
      }
      Navigator.pop(context);
    }
  }
}
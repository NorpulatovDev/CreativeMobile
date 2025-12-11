import 'package:flutter/material.dart';
import '../../data/models/models.dart';
import '../../../groups/data/models/models.dart';

class AssignGroupDialog extends StatefulWidget {
  final Student student;
  final List<Group> groups;

  const AssignGroupDialog({
    super.key,
    required this.student,
    required this.groups,
  });

  @override
  State<AssignGroupDialog> createState() => _AssignGroupDialogState();
}

class _AssignGroupDialogState extends State<AssignGroupDialog> {
  int? _selectedGroupId;

  @override
  void initState() {
    super.initState();
    _selectedGroupId = widget.student.activeGroupId;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Assign ${widget.student.fullName}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Select a group:'),
          const SizedBox(height: 16),
          DropdownButtonFormField<int?>(
            value: _selectedGroupId,
            decoration: const InputDecoration(
              labelText: 'Group',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('Remove from group'),
              ),
              ...widget.groups.map((group) {
                return DropdownMenuItem(
                  value: group.id,
                  child: Text('${group.name} (${group.teacherName})'),
                );
              }),
            ],
            onChanged: (value) {
              setState(() {
                _selectedGroupId = value;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_selectedGroupId),
          child: const Text('Assign'),
        ),
      ],
    );
  }
}
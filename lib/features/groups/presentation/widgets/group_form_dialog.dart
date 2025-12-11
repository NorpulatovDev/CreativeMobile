import 'package:flutter/material.dart';
import '../../data/models/models.dart';
import '../../../teachers/data/models/models.dart';

class GroupFormDialog extends StatefulWidget {
  final Group? group;
  final List<Teacher> teachers;

  const GroupFormDialog({
    super.key,
    this.group,
    required this.teachers,
  });

  @override
  State<GroupFormDialog> createState() => _GroupFormDialogState();
}

class _GroupFormDialogState extends State<GroupFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _feeController;
  int? _selectedTeacherId;

  bool get isEditing => widget.group != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.group?.name);
    _feeController = TextEditingController(
      text: widget.group?.monthlyFee.toStringAsFixed(0),
    );
    _selectedTeacherId = widget.group?.teacherId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop({
        'name': _nameController.text.trim(),
        'teacherId': _selectedTeacherId,
        'monthlyFee': double.parse(_feeController.text.trim()),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditing ? 'Edit Group' : 'Add Group'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
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
                border: OutlineInputBorder(),
              ),
              items: widget.teachers.map((teacher) {
                return DropdownMenuItem(
                  value: teacher.id,
                  child: Text(teacher.fullName),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTeacherId = value;
                });
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
                labelText: 'Monthly Fee',
                border: OutlineInputBorder(),
                suffixText: 'so\'m',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter monthly fee';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}
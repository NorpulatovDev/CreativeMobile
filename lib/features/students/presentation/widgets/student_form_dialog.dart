import 'package:flutter/material.dart';
import '../../data/models/models.dart';
import '../../../groups/data/models/models.dart';

class StudentFormDialog extends StatefulWidget {
  final Student? student;
  final List<Group> groups;

  const StudentFormDialog({
    super.key,
    this.student,
    required this.groups,
  });

  @override
  State<StudentFormDialog> createState() => _StudentFormDialogState();
}

class _StudentFormDialogState extends State<StudentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _parentNameController;
  late final TextEditingController _phoneController;
  int? _selectedGroupId;

  bool get isEditing => widget.student != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student?.fullName);
    _parentNameController = TextEditingController(text: widget.student?.parentName);
    _phoneController = TextEditingController(text: widget.student?.parentPhoneNumber);
    _selectedGroupId = widget.student?.activeGroupId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _parentNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop({
        'fullName': _nameController.text.trim(),
        'parentName': _parentNameController.text.trim(),
        'parentPhoneNumber': _phoneController.text.trim(),
        'activeGroupId': _selectedGroupId,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditing ? 'Edit Student' : 'Add Student'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _parentNameController,
                decoration: const InputDecoration(
                  labelText: 'Parent Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter parent name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Parent Phone',
                  hintText: '+998XXXXXXXXX',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  if (!RegExp(r'^\+998[0-9]{9}$').hasMatch(value)) {
                    return 'Format: +998XXXXXXXXX';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int?>(
                value: _selectedGroupId,
                decoration: const InputDecoration(
                  labelText: 'Group (Optional)',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('No Group'),
                  ),
                  ...widget.groups.map((group) {
                    return DropdownMenuItem(
                      value: group.id,
                      child: Text(group.name),
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
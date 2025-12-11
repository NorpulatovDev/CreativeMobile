import 'package:flutter/material.dart';
import '../../../groups/data/models/models.dart';
import '../../../students/data/models/models.dart';

class PaymentFormDialog extends StatefulWidget {
  final List<Student> students;
  final List<Group> groups;

  const PaymentFormDialog({
    super.key,
    required this.students,
    required this.groups,
  });

  @override
  State<PaymentFormDialog> createState() => _PaymentFormDialogState();
}

class _PaymentFormDialogState extends State<PaymentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  
  int? _selectedStudentId;
  int? _selectedGroupId;
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  List<Student> get _filteredStudents {
    if (_selectedGroupId == null) return widget.students;
    return widget.students
        .where((s) => s.activeGroupId == _selectedGroupId)
        .toList();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onGroupChanged(int? groupId) {
    setState(() {
      _selectedGroupId = groupId;
      _selectedStudentId = null;
      
      // Auto-fill amount with group's monthly fee
      if (groupId != null) {
        final group = widget.groups.firstWhere((g) => g.id == groupId);
        _amountController.text = group.monthlyFee.toStringAsFixed(0);
      }
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final monthStr = '$_selectedYear-${_selectedMonth.toString().padLeft(2, '0')}';
      Navigator.of(context).pop({
        'studentId': _selectedStudentId,
        'groupId': _selectedGroupId,
        'amount': double.parse(_amountController.text.trim()),
        'paidForMonth': monthStr,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Record Payment'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Group dropdown
              DropdownButtonFormField<int>(
                value: _selectedGroupId,
                decoration: const InputDecoration(
                  labelText: 'Group',
                  border: OutlineInputBorder(),
                ),
                items: widget.groups.map((group) {
                  return DropdownMenuItem(
                    value: group.id,
                    child: Text('${group.name} (${group.monthlyFee.toStringAsFixed(0)} so\'m)'),
                  );
                }).toList(),
                onChanged: _onGroupChanged,
                validator: (value) {
                  if (value == null) return 'Please select a group';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Student dropdown
              DropdownButtonFormField<int>(
                value: _selectedStudentId,
                decoration: const InputDecoration(
                  labelText: 'Student',
                  border: OutlineInputBorder(),
                ),
                items: _filteredStudents.map((student) {
                  return DropdownMenuItem(
                    value: student.id,
                    child: Text(student.fullName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStudentId = value;
                  });
                },
                validator: (value) {
                  if (value == null) return 'Please select a student';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Amount
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                  suffixText: 'so\'m',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Month/Year selection
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedMonth,
                      decoration: const InputDecoration(
                        labelText: 'Month',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(12, (index) {
                        final month = index + 1;
                        return DropdownMenuItem(
                          value: month,
                          child: Text(_getMonthName(month)),
                        );
                      }),
                      onChanged: (value) {
                        setState(() {
                          _selectedMonth = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedYear,
                      decoration: const InputDecoration(
                        labelText: 'Year',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(5, (index) {
                        final year = DateTime.now().year - 2 + index;
                        return DropdownMenuItem(
                          value: year,
                          child: Text(year.toString()),
                        );
                      }),
                      onChanged: (value) {
                        setState(() {
                          _selectedYear = value!;
                        });
                      },
                    ),
                  ),
                ],
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
          child: const Text('Save'),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}
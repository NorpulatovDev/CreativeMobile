import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/expense_models.dart';
import '../bloc/expense_category_bloc.dart';

class ExpenseCategoryFormDialog extends StatefulWidget {
  final ExpenseCategoryModel? category;

  const ExpenseCategoryFormDialog({super.key, this.category});

  @override
  State<ExpenseCategoryFormDialog> createState() =>
      _ExpenseCategoryFormDialogState();
}

class _ExpenseCategoryFormDialogState extends State<ExpenseCategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late String _selectedColor;

  static const List<String> _availableColors = [
    '#EF4444', // Red
    '#F59E0B', // Amber
    '#10B981', // Green
    '#3B82F6', // Blue
    '#8B5CF6', // Purple
    '#EC4899', // Pink
    '#06B6D4', // Cyan
    '#F97316', // Orange
    '#64748B', // Slate
  ];

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.category?.name ?? '');
    _selectedColor = widget.category?.color ?? _availableColors[0];
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Color _parseHex(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('0xFF$clean'));
    } catch (_) {
      return AppColors.primary;
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final request = ExpenseCategoryRequest(
      name: _nameController.text.trim(),
      color: _selectedColor,
    );

    if (widget.category == null) {
      context
          .read<ExpenseCategoryBloc>()
          .add(CreateExpenseCategoryEvent(request));
    } else {
      context.read<ExpenseCategoryBloc>().add(
            UpdateExpenseCategoryEvent(widget.category!.id, request),
          );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        isEditing ? 'Kategoriyani tahrirlash' : 'Yangi kategoriya',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Kategoriya nomi',
                  hintText: 'Masalan: Ijara, Kanselyariya, Reklama',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Kategoriya nomini kiriting';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Belgilangan rang:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral600,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _availableColors.map((hex) {
                  final isSelected = _selectedColor == hex;
                  final color = _parseHex(hex);
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = hex),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.black87 : Colors.transparent,
                          width: 2.5,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: color.withValues(alpha: 0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Bekor qilish', style: TextStyle(color: AppColors.neutral500)),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(isEditing ? 'Saqlash' : 'Yaratish'),
        ),
      ],
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../data/models/expense_models.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_category_bloc.dart';
import 'expense_category_form_dialog.dart';

class ExpenseFormDialog extends StatefulWidget {
  final ExpenseModel? expense;

  const ExpenseFormDialog({super.key, this.expense});

  @override
  State<ExpenseFormDialog> createState() => _ExpenseFormDialogState();
}

class _ExpenseFormDialogState extends State<ExpenseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late DateTime _selectedDate;
  int? _selectedCategoryId;

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final DateFormat _displayDateFormat = DateFormat('dd.MM.yyyy');

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.expense?.title ?? '');
    _amountController = TextEditingController(
      text: widget.expense != null
          ? formatAmount(widget.expense!.amount)
          : '',
    );
    _selectedDate = widget.expense?.expenseDate ?? DateTime.now();
    _selectedCategoryId = widget.expense?.categoryId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _showAddCategory() {
    showDialog(
      context: context,
      builder: (ctx) => BlocProvider(
        create: (_) => getIt<ExpenseCategoryBloc>(),
        child: const ExpenseCategoryFormDialog(),
      ),
    ).then((_) {
      // Reload categories
      if (mounted) {
        context.read<ExpenseCategoryBloc>().add(const LoadExpenseCategories());
      }
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Iltimos, xarajat kategoriyasini tanlang'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final rawAmountStr = amountDigits(_amountController.text);
    final amount = double.tryParse(rawAmountStr) ?? 0.0;

    final request = ExpenseRequest(
      title: _titleController.text.trim(),
      amount: amount,
      expenseDate: _dateFormat.format(_selectedDate),
      categoryId: _selectedCategoryId!,
    );

    if (widget.expense == null) {
      context.read<ExpenseBloc>().add(CreateExpenseEvent(request));
    } else {
      context.read<ExpenseBloc>().add(
            UpdateExpenseEvent(widget.expense!.id, request),
          );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.expense != null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        isEditing ? 'Xarajatni tahrirlash' : 'Yangi xarajat',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Xarajat nomi',
                  hintText: 'Masalan: Ofis ijarasi, Suv apparati...',
                  prefixIcon: const Icon(Icons.edit_note_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Xarajat nomini kiriting';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Amount with ThousandsSeparatorInputFormatter
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  ThousandsSeparatorInputFormatter(),
                ],
                decoration: InputDecoration(
                  labelText: 'Summasi (so\'m)',
                  hintText: '300 000',
                  prefixIcon: const Icon(Icons.payments_outlined),
                  suffixText: "so'm",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Summani kiriting';
                  }
                  final digits = amountDigits(val);
                  final parsed = double.tryParse(digits);
                  if (parsed == null || parsed <= 0) {
                    return 'Summa 0 dan katta bo\'lishi kerak';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Category dropdown
              BlocBuilder<ExpenseCategoryBloc, ExpenseCategoryState>(
                builder: (context, state) {
                  List<ExpenseCategoryModel> categories = [];
                  if (state is ExpenseCategoryLoaded) {
                    categories = state.categories;
                  }

                  return Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _selectedCategoryId,
                          decoration: InputDecoration(
                            labelText: 'Kategoriya',
                            prefixIcon: const Icon(Icons.category_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: categories.map((c) {
                            return DropdownMenuItem<int>(
                              value: c.id,
                              child: Text(
                                c.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() => _selectedCategoryId = val);
                          },
                          validator: (val) {
                            if (val == null) {
                              return 'Kategoriyani tanlang';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _showAddCategory,
                        tooltip: 'Yangi kategoriya',
                        icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 14),

              // Date picker
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.neutral300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 20, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Xarajat sanasi',
                            style: TextStyle(fontSize: 11, color: AppColors.neutral500),
                          ),
                          Text(
                            _displayDateFormat.format(_selectedDate),
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.edit_calendar_rounded, size: 18, color: AppColors.neutral400),
                    ],
                  ),
                ),
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
          child: Text(isEditing ? 'Saqlash' : 'Qo\'shish'),
        ),
      ],
    );
  }
}


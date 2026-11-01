import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../data/models/expense_models.dart';
import '../../data/repositories/expense_repository.dart';
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
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _amountFocusNode = FocusNode();
  late DateTime _selectedDate;
  int? _selectedCategoryId;

  String? _toastMessage;
  Timer? _toastTimer;
  bool _isSubmitting = false;

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
    _toastTimer?.cancel();
    _titleController.dispose();
    _amountController.dispose();
    _titleFocusNode.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  Color _parseHex(String? hex) {
    if (hex == null || hex.isEmpty) return AppColors.primary;
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('0xFF$clean'));
    } catch (_) {
      return AppColors.primary;
    }
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
              surface: Colors.white,
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

  Future<void> _openCategoryPicker(List<ExpenseCategoryModel> categories) async {
    final selected = await showModalBottomSheet<int?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _CategoryPickerBottomSheet(
          categories: categories,
          selectedCategoryId: _selectedCategoryId,
          onAddNewCategory: () async {
            final newCategory = await showDialog<ExpenseCategoryModel>(
              context: sheetContext,
              builder: (ctx) => const ExpenseCategoryFormDialog(),
            );
            if (newCategory != null && mounted) {
              // Reload categories in parent bloc
              try {
                context
                    .read<ExpenseCategoryBloc>()
                    .add(const LoadExpenseCategories());
              } catch (_) {}
              // Auto-select newly created category and close picker
              Navigator.of(sheetContext).pop(newCategory.id);
            }
          },
        );
      },
    );

    if (selected != null && mounted) {
      setState(() {
        _selectedCategoryId = selected == -1 ? null : selected;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
      );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final rawAmountStr = amountDigits(_amountController.text);
    final amount = double.tryParse(rawAmountStr) ?? 0.0;

    setState(() {
      _isSubmitting = true;
      _toastMessage = null;
    });

    final request = ExpenseRequest(
      title: _titleController.text.trim(),
      amount: amount,
      expenseDate: _dateFormat.format(_selectedDate),
      categoryId: _selectedCategoryId, // null = defaults to "Boshqa" (Others)
    );

    final repository = getIt<ExpenseRepository>();

    if (widget.expense == null) {
      // CREATE NEW EXPENSE
      final (expense, failure) = await repository.createExpense(request);
      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (failure != null) {
        _showError(failure.message);
      } else {
        // Notify parent bloc if available
        try {
          context.read<ExpenseBloc>().add(const LoadExpensesEvent());
        } catch (_) {}

        // Reset and clear all fields explicitly
        _titleController.clear();
        _amountController.clear();
        _formKey.currentState?.reset();

        setState(() {
          _selectedDate = DateTime.now();
          _selectedCategoryId = null;
          _toastMessage = 'Xarajat muvaffaqiyatli saqlandi!';
        });

        _toastTimer?.cancel();
        _toastTimer = Timer(const Duration(seconds: 4), () {
          if (mounted) {
            setState(() => _toastMessage = null);
          }
        });

        // Re-focus title for immediate next entry
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _titleFocusNode.requestFocus();
        });

        // Floating snackbar feedback
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Xarajat muvaffaqiyatli saqlandi!',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          );
      }
    } else {
      // UPDATE EXISTING EXPENSE
      final (expense, failure) =
          await repository.updateExpense(widget.expense!.id, request);
      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (failure != null) {
        _showError(failure.message);
      } else {
        try {
          context.read<ExpenseBloc>().add(const LoadExpensesEvent());
        } catch (_) {}
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.expense != null;
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 400;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: isCompact ? 12 : 20,
        vertical: 24,
      ),
      backgroundColor: AppColors.surfaceLight,
      elevation: 10,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            isCompact ? 18 : 26,
            22,
            isCompact ? 18 : 26,
            26,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Bar: Icon, Title and Close Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFF59E0B),
                                  const Color(0xFFF59E0B).withValues(alpha: 0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFF59E0B)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.payments_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEditing ? 'Xarajatni tahrirlash' : 'Yangi xarajat',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.4,
                                  color: AppColors.neutral900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isEditing
                                    ? 'Ma\'lumotlarni o\'zgartiring'
                                    : 'Xarajat tafsilotlarini kiriting',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.neutral500,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.neutral100,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: AppColors.neutral600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Success Feedback Banner (Inside Dialog)
                  if (_toastMessage != null) ...[
                    const SizedBox(height: 16),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              const Color(0xFF10B981).withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _toastMessage!,
                              style: const TextStyle(
                                color: Color(0xFF065F46),
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 22),

                  // 1. Title Input
                  const Text(
                    'Xarajat nomi',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _titleController,
                    focusNode: _titleFocusNode,
                    autofocus: !isEditing,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: 'Masalan: Ofis ijarasi, Suv, Kanselyariya...',
                      hintStyle: const TextStyle(
                        color: AppColors.neutral400,
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                      prefixIcon: const Icon(Icons.edit_note_rounded,
                          color: AppColors.primary, size: 22),
                      filled: true,
                      fillColor: AppColors.neutral50,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                            const BorderSide(color: AppColors.neutral200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                            const BorderSide(color: AppColors.neutral200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 2),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Xarajat nomini kiriting';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => _amountFocusNode.requestFocus(),
                  ),

                  const SizedBox(height: 18),

                  // 2. Amount Input
                  const Text(
                    'Summasi',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _amountController,
                    focusNode: _amountFocusNode,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.neutral900,
                      letterSpacing: 0.5,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      ThousandsSeparatorInputFormatter(),
                    ],
                    decoration: InputDecoration(
                      hintText: '300 000',
                      hintStyle: const TextStyle(
                        color: AppColors.neutral400,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      prefixIcon: const Icon(Icons.attach_money_rounded,
                          color: AppColors.primary, size: 22),
                      suffixText: "so'm",
                      suffixStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral700,
                      ),
                      filled: true,
                      fillColor: AppColors.neutral50,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                            const BorderSide(color: AppColors.neutral200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                            const BorderSide(color: AppColors.neutral200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 2),
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
                    onFieldSubmitted: (_) => _submit(),
                  ),

                  const SizedBox(height: 18),

                  // 3. Category Selector
                  const Text(
                    'Kategoriya',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  BlocBuilder<ExpenseCategoryBloc, ExpenseCategoryState>(
                    builder: (context, state) {
                      List<ExpenseCategoryModel> categories = [];
                      if (state is ExpenseCategoryLoaded) {
                        categories = state.categories;
                      }

                      ExpenseCategoryModel? selectedCategory;
                      if (_selectedCategoryId != null) {
                        for (final cat in categories) {
                          if (cat.id == _selectedCategoryId) {
                            selectedCategory = cat;
                            break;
                          }
                        }
                      }

                      final selectedColor = selectedCategory != null
                          ? _parseHex(selectedCategory.color)
                          : const Color(0xFF64748B);

                      final categoryTitle = selectedCategory != null
                          ? selectedCategory.name
                          : 'Boshqa (standart)';

                      return InkWell(
                        onTap: () => _openCategoryPicker(categories),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.neutral50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.neutral200),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: selectedColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  selectedCategory != null
                                      ? Icons.label_rounded
                                      : Icons.category_rounded,
                                  size: 16,
                                  color: selectedColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  categoryTitle,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: selectedCategory != null
                                        ? AppColors.neutral900
                                        : AppColors.neutral600,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Tanlash',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 18),

                  // 4. Date Picker
                  const Text(
                    'Xarajat sanasi',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.neutral50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.neutral200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.calendar_month_rounded,
                              size: 16,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _displayDateFormat.format(_selectedDate),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.neutral900,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.neutral200.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'O\'zgartirish',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.neutral700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: OutlinedButton(
                          onPressed: _isSubmitting
                              ? null
                              : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: AppColors.neutral300),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text(
                            'Yopish',
                            style: TextStyle(
                              color: AppColors.neutral700,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          onPressed: _isSubmitting ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            elevation: 2,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isEditing
                                          ? Icons.check_rounded
                                          : Icons.add_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isEditing ? 'Saqlash' : 'Qo\'shish',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A modern bottom sheet that lets users select or create categories
class _CategoryPickerBottomSheet extends StatelessWidget {
  final List<ExpenseCategoryModel> categories;
  final int? selectedCategoryId;
  final VoidCallback onAddNewCategory;

  const _CategoryPickerBottomSheet({
    required this.categories,
    required this.selectedCategoryId,
    required this.onAddNewCategory,
  });

  Color _parseHex(String? hex) {
    if (hex == null || hex.isEmpty) return AppColors.primary;
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('0xFF$clean'));
    } catch (_) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.neutral300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Kategoriyani tanlang',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                TextButton.icon(
                  onPressed: onAddNewCategory,
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                  label: const Text(
                    'Yangi qo\'shish',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Default Category: "Boshqa" (Others)
            ListTile(
              onTap: () => Navigator.of(context).pop(-1), // -1 means null / Boshqa
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              tileColor: selectedCategoryId == null
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : AppColors.neutral50,
              leading: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF64748B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.category_rounded,
                    color: Color(0xFF64748B), size: 20),
              ),
              title: const Text(
                'Boshqa (standart)',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              subtitle: const Text(
                'Kategoriya tanlanmasa avtomatik biriktiriladi',
                style: TextStyle(fontSize: 12, color: AppColors.neutral500),
              ),
              trailing: selectedCategoryId == null
                  ? const Icon(Icons.check_circle_rounded,
                      color: AppColors.primary, size: 22)
                  : null,
            ),

            const SizedBox(height: 10),

            // Categories list
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.45,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = cat.id == selectedCategoryId;
                  final color = _parseHex(cat.color);

                  return ListTile(
                    onTap: () => Navigator.of(context).pop(cat.id),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    tileColor: isSelected
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : AppColors.neutral50,
                    leading: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.label_rounded, color: color, size: 20),
                    ),
                    title: Text(
                      cat.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: isSelected ? AppColors.primary : AppColors.neutral900,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded,
                            color: AppColors.primary, size: 22)
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';

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
  final FocusNode _titleFocusNode = FocusNode();
  late DateTime _selectedDate;
  int? _selectedCategoryId;

  String? _toastMessage;
  Timer? _toastTimer;

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
      if (mounted) {
        context.read<ExpenseCategoryBloc>().add(const LoadExpenseCategories());
      }
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final rawAmountStr = amountDigits(_amountController.text);
    final amount = double.tryParse(rawAmountStr) ?? 0.0;

    final request = ExpenseRequest(
      title: _titleController.text.trim(),
      amount: amount,
      expenseDate: _dateFormat.format(_selectedDate),
      categoryId: _selectedCategoryId, // null = defaults to "Boshqa" (Others)
    );

    if (widget.expense == null) {
      context.read<ExpenseBloc>().add(CreateExpenseEvent(request));
    } else {
      context.read<ExpenseBloc>().add(
            UpdateExpenseEvent(widget.expense!.id, request),
          );
    }
  }

  void _onSuccess(String message) {
    if (widget.expense != null) {
      // If editing existing expense, dismiss dialog
      Navigator.of(context).pop();
      return;
    }

    // Adding new expense: keep dialog open, clear inputs, show success toast
    _titleController.clear();
    _amountController.clear();
    _formKey.currentState?.reset();

    setState(() {
      _selectedDate = DateTime.now();
      _selectedCategoryId = null;
      _toastMessage = message;
    });

    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() => _toastMessage = null);
      }
    });

    // Re-focus title for instant next input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _titleFocusNode.requestFocus();
    });

    // Show floating snackbar
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.expense != null;

    return BlocListener<ExpenseBloc, ExpenseState>(
      listener: (context, state) {
        if (state is ExpenseActionSuccess) {
          _onSuccess(state.message);
        } else if (state is ExpenseError) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.white),
                    const SizedBox(width: 10),
                    Expanded(child: Text(state.message)),
                  ],
                ),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        backgroundColor: AppColors.surfaceLight,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header with title and close 'X'
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.payments_rounded,
                                color: Color(0xFFF59E0B),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              isEditing ? 'Xarajatni tahrirlash' : 'Yangi xarajat',
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          tooltip: 'Yopish',
                          icon: const Icon(Icons.close_rounded, color: AppColors.neutral500),
                        ),
                      ],
                    ),

                    // In-dialog success toast
                    if (_toastMessage != null) ...[
                      const SizedBox(height: 12),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.success,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _toastMessage!,
                                style: const TextStyle(
                                  color: AppColors.successDark,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // 1. Title Input
                    TextFormField(
                      controller: _titleController,
                      focusNode: _titleFocusNode,
                      autofocus: !isEditing,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        labelText: 'Xarajat nomi *',
                        hintText: 'Masalan: Ofis ijarasi, Suv, Kanselyariya...',
                        prefixIcon: const Icon(Icons.edit_note_rounded, color: AppColors.primary),
                        filled: true,
                        fillColor: AppColors.neutral50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.neutral300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: AppColors.neutral300.withValues(alpha: 0.8)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Xarajat nomini kiriting';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // 2. Amount Input (formatted with space: 300 000)
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral900,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        ThousandsSeparatorInputFormatter(),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Summasi *',
                        hintText: '300 000',
                        prefixIcon: const Icon(Icons.payments_outlined, color: AppColors.primary),
                        suffixText: "so'm",
                        suffixStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutral600,
                        ),
                        filled: true,
                        fillColor: AppColors.neutral50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.neutral300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: AppColors.neutral300.withValues(alpha: 0.8)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
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

                    const SizedBox(height: 16),

                    // 3. Category Dropdown (optional, defaults to "Boshqa")
                    BlocBuilder<ExpenseCategoryBloc, ExpenseCategoryState>(
                      builder: (context, state) {
                        List<ExpenseCategoryModel> categories = [];
                        if (state is ExpenseCategoryLoaded) {
                          categories = state.categories;
                        }

                        return Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<int?>(
                                value: _selectedCategoryId,
                                decoration: InputDecoration(
                                  labelText: 'Kategoriya (ixtiyoriy)',
                                  hintText: 'Boshqa (standart)',
                                  prefixIcon: const Icon(Icons.category_outlined, color: AppColors.primary),
                                  filled: true,
                                  fillColor: AppColors.neutral50,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: AppColors.neutral300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(color: AppColors.neutral300.withValues(alpha: 0.8)),
                                  ),
                                ),
                                items: [
                                  const DropdownMenuItem<int?>(
                                    value: null,
                                    child: Text(
                                      'Boshqa (standart)',
                                      style: TextStyle(
                                        color: AppColors.neutral600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  ...categories.map((c) {
                                    return DropdownMenuItem<int?>(
                                      value: c.id,
                                      child: Text(
                                        c.name,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                    );
                                  }),
                                ],
                                onChanged: (val) {
                                  setState(() => _selectedCategoryId = val);
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: _showAddCategory,
                              tooltip: 'Yangi kategoriya yaratish',
                              icon: const Icon(
                                Icons.add_circle_outline_rounded,
                                color: AppColors.primary,
                                size: 26,
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // 4. Date Picker
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                        decoration: BoxDecoration(
                          color: AppColors.neutral50,
                          border: Border.all(color: AppColors.neutral300.withValues(alpha: 0.8)),
                          borderRadius: BorderRadius.circular(14),
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
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                ),
                              ],
                            ),
                            const Spacer(),
                            const Icon(Icons.edit_calendar_rounded, size: 18, color: AppColors.neutral400),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: AppColors.neutral300),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Text(
                              'Yopish',
                              style: TextStyle(
                                color: AppColors.neutral700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: FilledButton(
                            onPressed: _submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                                const SizedBox(width: 6),
                                Text(
                                  isEditing ? 'Saqlash' : 'Qo\'shish',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
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
      ),
    );
  }
}

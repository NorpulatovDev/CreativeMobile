import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../data/models/expense_models.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_category_bloc.dart';
import '../dialogs/expense_form_dialog.dart';
import '../widgets/category_breakdown_card.dart';

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<ExpenseBloc>()
            ..add(const LoadExpensesEvent(period: 'monthly')),
        ),
        BlocProvider(
          create: (_) =>
              getIt<ExpenseCategoryBloc>()..add(const LoadExpenseCategories()),
        ),
      ],
      child: const _ExpensesView(),
    );
  }
}

class _ExpensesView extends StatefulWidget {
  const _ExpensesView();

  @override
  State<_ExpensesView> createState() => _ExpensesViewState();
}

class _ExpensesViewState extends State<_ExpensesView> {
  final DateFormat _dayFormat = DateFormat('dd.MM.yyyy');
  final DateFormat _monthFormat = DateFormat('MMMM yyyy');

  final Set<int> _selectedIds = {};
  bool get _isSelectionMode => _selectedIds.isNotEmpty;

  Color _parseHex(String? hex) {
    if (hex == null || hex.isEmpty) return AppColors.primary;
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('0xFF$clean'));
    } catch (_) {
      return AppColors.primary;
    }
  }

  void _toggleSelection(int id) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _clearSelection() {
    setState(() => _selectedIds.clear());
  }

  void _selectAll(List<ExpenseModel> expenses) {
    HapticFeedback.mediumImpact();
    setState(() {
      if (_selectedIds.length == expenses.length) {
        _selectedIds.clear();
      } else {
        _selectedIds.addAll(expenses.map((e) => e.id));
      }
    });
  }

  void _confirmDeleteSelected(BuildContext context) {
    final bloc = context.read<ExpenseBloc>();
    final count = _selectedIds.length;
    final idsToDelete = _selectedIds.toList();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.error, size: 22),
            ),
            const SizedBox(width: 12),
            const Text(
              'Xarajatlarni o\'chirish',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          'Tanlangan $count ta xarajatni o\'chirmoqchimisiz? Bu amalni ortga qaytarib bo\'lmaydi.',
          style: const TextStyle(
            color: AppColors.neutral700,
            fontSize: 15,
            height: 1.4,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text(
              'Bekor qilish',
              style: TextStyle(
                color: AppColors.neutral600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _clearSelection();
              bloc.add(DeleteMultipleExpensesEvent(idsToDelete));
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              '$count tani o\'chirish',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddExpense(BuildContext context) {
    final expenseBloc = context.read<ExpenseBloc>();
    final categoryBloc = context.read<ExpenseCategoryBloc>();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: expenseBloc),
          BlocProvider.value(value: categoryBloc),
        ],
        child: const ExpenseFormDialog(),
      ),
    );
  }

  void _showEditExpense(BuildContext context, ExpenseModel expense) {
    final expenseBloc = context.read<ExpenseBloc>();
    final categoryBloc = context.read<ExpenseCategoryBloc>();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: expenseBloc),
          BlocProvider.value(value: categoryBloc),
        ],
        child: ExpenseFormDialog(expense: expense),
      ),
    );
  }

  void _confirmDeleteExpense(BuildContext context, ExpenseModel expense) {
    final bloc = context.read<ExpenseBloc>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.error, size: 22),
            ),
            const SizedBox(width: 12),
            const Text(
              'Xarajatni o\'chirish',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          '"${expense.title}" (${formatAmount(expense.amount)} so\'m) xarajatini o\'chirmoqchimisiz?',
          style: const TextStyle(
            color: AppColors.neutral700,
            fontSize: 15,
            height: 1.4,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text(
              'Bekor qilish',
              style: TextStyle(
                color: AppColors.neutral600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              bloc.add(DeleteExpenseEvent(expense.id));
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'O\'chirish',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _onPrevious(BuildContext context, String period, DateTime current) {
    if (_isSelectionMode) _clearSelection();
    DateTime nextDate;
    if (period == 'daily') {
      nextDate = current.subtract(const Duration(days: 1));
    } else if (period == 'weekly') {
      nextDate = current.subtract(const Duration(days: 7));
    } else {
      nextDate = DateTime(current.year, current.month - 1, 1);
    }
    context.read<ExpenseBloc>().add(ChangeExpenseDateEvent(nextDate));
  }

  void _onNext(BuildContext context, String period, DateTime current) {
    if (_isSelectionMode) _clearSelection();
    DateTime nextDate;
    if (period == 'daily') {
      nextDate = current.add(const Duration(days: 1));
    } else if (period == 'weekly') {
      nextDate = current.add(const Duration(days: 7));
    } else {
      nextDate = DateTime(current.year, current.month + 1, 1);
    }
    context.read<ExpenseBloc>().add(ChangeExpenseDateEvent(nextDate));
  }

  void _onToday(BuildContext context, String period) {
    if (_isSelectionMode) _clearSelection();
    context.read<ExpenseBloc>().add(ChangeExpenseDateEvent(DateTime.now()));
  }

  bool _isCurrentDate(String period, DateTime date) {
    final now = DateTime.now();
    if (period == 'daily') {
      return date.year == now.year && date.month == now.month && date.day == now.day;
    } else if (period == 'monthly') {
      return date.year == now.year && date.month == now.month;
    }
    return false;
  }

  String _formatDateTitle(String period, DateTime date) {
    if (period == 'daily') {
      final now = DateTime.now();
      if (date.year == now.year && date.month == now.month && date.day == now.day) {
        return 'Bugun, ${_dayFormat.format(date)}';
      }
      return _dayFormat.format(date);
    } else if (period == 'weekly') {
      final monday = date.subtract(Duration(days: date.weekday - 1));
      final sunday = monday.add(const Duration(days: 6));
      return '${DateFormat('dd.MM').format(monday)} – ${DateFormat('dd.MM.yyyy').format(sunday)}';
    } else {
      return _monthFormat.format(date);
    }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, List<ExpenseModel> expenses) {
    if (_isSelectionMode) {
      final allSelected = _selectedIds.length == expenses.length && expenses.isNotEmpty;

      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.neutral800),
          tooltip: 'Bekor qilish',
          onPressed: _clearSelection,
        ),
        title: Text(
          '${_selectedIds.length} ta tanlandi',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppColors.neutral900,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              allSelected
                  ? Icons.deselect_rounded
                  : Icons.select_all_rounded,
              color: AppColors.primary,
            ),
            tooltip: allSelected ? 'Tanlovni bekor qilish' : 'Barchasini tanlash',
            onPressed: () => _selectAll(expenses),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.error,
            ),
            tooltip: 'Tanlanganlarni o\'chirish',
            onPressed: () => _confirmDeleteSelected(context),
          ),
          const SizedBox(width: 4),
        ],
        backgroundColor: AppColors.surfaceLight,
        elevation: 1,
      );
    }

    return AppBar(
      titleSpacing: 0,
      title: Row(
        children: [
          const Text(
            'Xarajatlar',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFEC4899).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Super Admin',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Color(0xFFEC4899),
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            tooltip: 'Kategoriyalar',
            icon: const Icon(Icons.category_rounded,
                color: AppColors.primary, size: 22),
            onPressed: () {
              context.push(Routes.expenseCategories);
            },
          ),
        ),
      ],
      backgroundColor: AppColors.surfaceLight,
      elevation: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ExpenseBloc, ExpenseState>(
      listener: (context, state) {
        if (state is ExpenseActionSuccess) {
          _clearSelection();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        } else if (state is ExpenseError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      },
      builder: (context, state) {
        String currentPeriod = 'monthly';
        DateTime selectedDate = DateTime.now();
        List<ExpenseModel> expenses = [];
        ExpenseSummaryModel? summary;

        if (state is ExpenseLoaded) {
          currentPeriod = state.currentPeriod;
          selectedDate = state.selectedDate;
          expenses = state.expenses;
          summary = state.summary;
        }

        final isToday = _isCurrentDate(currentPeriod, selectedDate);

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: _buildAppBar(context, expenses),
          floatingActionButton: _isSelectionMode
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => _showAddExpense(context),
                  backgroundColor: AppColors.primary,
                  elevation: 3,
                  icon: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                  label: const Text(
                    'Xarajat qo\'shish',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
          body: RefreshIndicator(
            onRefresh: () async {
              _clearSelection();
              context.read<ExpenseBloc>().add(
                    LoadExpensesEvent(
                        period: currentPeriod, date: selectedDate),
                  );
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Period Tab Capsule (Kunlik / Haftalik / Oylik)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.neutral200.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              _PeriodTab(
                                label: 'Kunlik',
                                isSelected: currentPeriod == 'daily',
                                onTap: () {
                                  if (_isSelectionMode) _clearSelection();
                                  context.read<ExpenseBloc>().add(
                                        const ChangeExpensePeriodEvent('daily'),
                                      );
                                },
                              ),
                              _PeriodTab(
                                label: 'Haftalik',
                                isSelected: currentPeriod == 'weekly',
                                onTap: () {
                                  if (_isSelectionMode) _clearSelection();
                                  context.read<ExpenseBloc>().add(
                                        const ChangeExpensePeriodEvent('weekly'),
                                      );
                                },
                              ),
                              _PeriodTab(
                                label: 'Oylik',
                                isSelected: currentPeriod == 'monthly',
                                onTap: () {
                                  if (_isSelectionMode) _clearSelection();
                                  context.read<ExpenseBloc>().add(
                                        const ChangeExpensePeriodEvent('monthly'),
                                      );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Date Navigator Card
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.neutral200.withValues(alpha: 0.8),
                            ),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left_rounded,
                                    size: 26),
                                color: AppColors.neutral700,
                                onPressed: () => _onPrevious(
                                    context, currentPeriod, selectedDate),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    _formatDateTitle(
                                        currentPeriod, selectedDate),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.neutral900,
                                    ),
                                  ),
                                ),
                              ),
                              if (!isToday) ...[
                                InkWell(
                                  onTap: () => _onToday(context, currentPeriod),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Bugun',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                              ],
                              IconButton(
                                icon: const Icon(Icons.chevron_right_rounded,
                                    size: 26),
                                color: AppColors.neutral700,
                                onPressed: () => _onNext(
                                    context, currentPeriod, selectedDate),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Summary Breakdown Card
                        if (summary != null)
                          CategoryBreakdownCard(summary: summary),

                        const SizedBox(height: 18),

                        // List Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Xarajatlar ro\'yxati',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.neutral900,
                                letterSpacing: -0.2,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.neutral200.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${expenses.length} ta',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.neutral700,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),

                // Expense Items List
                if (state is ExpenseLoading && expenses.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (expenses.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: AppColors.neutral100,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.receipt_long_rounded,
                                size: 36,
                                color: AppColors.neutral400,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Bu davr uchun xarajatlar yo\'q',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppColors.neutral800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Yangi xarajat kiritish uchun pastdagi tugmani bosing.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.neutral500,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 18),
                            FilledButton.tonalIcon(
                              onPressed: () => _showAddExpense(context),
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: const Text('Xarajat qo\'shish'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final expense = expenses[index];
                          final color = _parseHex(expense.categoryColor);
                          final isSelected = _selectedIds.contains(expense.id);

                          return _ExpenseItemCard(
                            expense: expense,
                            categoryColor: color,
                            isSelected: isSelected,
                            isSelectionMode: _isSelectionMode,
                            onTap: () {
                              if (_isSelectionMode) {
                                _toggleSelection(expense.id);
                              }
                            },
                            onLongPress: () {
                              _toggleSelection(expense.id);
                            },
                            onEdit: () => _showEditExpense(context, expense),
                            onDelete: () =>
                                _confirmDeleteExpense(context, expense),
                          );
                        },
                        childCount: expenses.length,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PeriodTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.neutral600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Robust, beautiful Expense card with zero overflow, multi-selection & long-press support
class _ExpenseItemCard extends StatelessWidget {
  final ExpenseModel expense;
  final Color categoryColor;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExpenseItemCard({
    required this.expense,
    required this.categoryColor,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onLongPress,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.06)
            : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : AppColors.neutral200.withValues(alpha: 0.7),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: isSelected ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Selection checkbox icon (when in selection mode)
                if (isSelectionMode) ...[
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.neutral400,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check_rounded,
                            size: 16, color: Colors.white)
                        : null,
                  ),
                ],

                // Category Icon Badge
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.payments_rounded,
                    color: categoryColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),

                // Left side details (Title + Category Badge + Date)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        expense.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.neutral900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: categoryColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                expense.categoryName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: categoryColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '•  ${DateFormat('dd.MM.yyyy').format(expense.expenseDate)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.neutral500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Right side details (Amount)
                Text(
                  '${formatAmount(expense.amount)} so\'m',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppColors.neutral900,
                    letterSpacing: -0.3,
                  ),
                ),

                // More Menu Button (only when not in selection mode)
                if (!isSelectionMode) ...[
                  SizedBox(
                    width: 32,
                    child: PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.more_vert_rounded,
                        size: 20,
                        color: AppColors.neutral400,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      onSelected: (action) {
                        if (action == 'edit') {
                          onEdit();
                        } else if (action == 'delete') {
                          onDelete();
                        }
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined,
                                  size: 18, color: AppColors.neutral700),
                              SizedBox(width: 10),
                              Text('Tahrirlash',
                                  style: TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline_rounded,
                                  size: 18, color: AppColors.error),
                              SizedBox(width: 10),
                              Text(
                                'O\'chirish',
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

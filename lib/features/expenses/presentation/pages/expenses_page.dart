import 'package:flutter/material.dart';
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

  Color _parseHex(String? hex) {
    if (hex == null || hex.isEmpty) return AppColors.primary;
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('0xFF$clean'));
    } catch (_) {
      return AppColors.primary;
    }
  }

  void _showAddExpense(BuildContext context) {
    final expenseBloc = context.read<ExpenseBloc>();
    final categoryBloc = context.read<ExpenseCategoryBloc>();

    showDialog(
      context: context,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Xarajatni o\'chirish',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text(
          '"${expense.title}" (${formatAmount(expense.amount)} so\'m) xarajatini o\'chirmoqchimisiz?',
          style: const TextStyle(color: AppColors.neutral600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Bekor qilish',
                style: TextStyle(color: AppColors.neutral500)),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              bloc.add(DeleteExpenseEvent(expense.id));
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('O\'chirish'),
          ),
        ],
      ),
    );
  }

  void _onPrevious(BuildContext context, String period, DateTime current) {
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

  String _formatDateTitle(String period, DateTime date) {
    if (period == 'daily') {
      return _dayFormat.format(date);
    } else if (period == 'weekly') {
      final monday = date.subtract(Duration(days: date.weekday - 1));
      final sunday = monday.add(const Duration(days: 6));
      return '${DateFormat('dd.MM').format(monday)} – ${DateFormat('dd.MM.yyyy').format(sunday)}';
    } else {
      return _monthFormat.format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              'Xarajatlar',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFEC4899).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Super Admin',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFEC4899),
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Kategoriyalar',
            icon: const Icon(Icons.category_rounded, color: AppColors.primary),
            onPressed: () {
              context.push(Routes.expenseCategories);
            },
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddExpense(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Xarajat qo\'shish',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: BlocConsumer<ExpenseBloc, ExpenseState>(
        listener: (context, state) {
          if (state is ExpenseActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          } else if (state is ExpenseError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
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

          return RefreshIndicator(
            onRefresh: () async {
              context
                  .read<ExpenseBloc>()
                  .add(LoadExpensesEvent(period: currentPeriod, date: selectedDate));
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Period Selector SegmentedButton
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(
                              value: 'daily',
                              label: Text('Kunlik'),
                              icon: Icon(Icons.view_day_rounded, size: 16),
                            ),
                            ButtonSegment(
                              value: 'weekly',
                              label: Text('Haftalik'),
                              icon: Icon(Icons.view_week_rounded, size: 16),
                            ),
                            ButtonSegment(
                              value: 'monthly',
                              label: Text('Oylik'),
                              icon: Icon(Icons.calendar_month_rounded, size: 16),
                            ),
                          ],
                          selected: {currentPeriod},
                          onSelectionChanged: (newSelection) {
                            context.read<ExpenseBloc>().add(
                                  ChangeExpensePeriodEvent(newSelection.first),
                                );
                          },
                          style: ButtonStyle(
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Date Navigator
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left_rounded),
                                onPressed: () => _onPrevious(
                                    context, currentPeriod, selectedDate),
                              ),
                              Text(
                                _formatDateTitle(currentPeriod, selectedDate),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.chevron_right_rounded),
                                onPressed: () => _onNext(
                                    context, currentPeriod, selectedDate),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Summary Breakdown Card
                        if (summary != null)
                          CategoryBreakdownCard(summary: summary),

                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Xarajatlar ro\'yxati',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.neutral800,
                              ),
                            ),
                            Text(
                              '${expenses.length} ta',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.neutral500,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),

                // Expense List
                if (state is ExpenseLoading && expenses.isEmpty)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
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
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: AppColors.neutral200,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.receipt_long_rounded,
                                  size: 32, color: AppColors.neutral500),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Bu davr uchun xarajatlar yo\'q',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Yangi xarajat kiritish uchun pastdagi tugmani bosing.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.neutral500),
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

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              leading: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(Icons.payments_rounded,
                                    color: color, size: 22),
                              ),
                              title: Text(
                                expense.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              subtitle: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      expense.categoryName,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: color,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    DateFormat('dd.MM.yyyy')
                                        .format(expense.expenseDate),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.neutral500,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${formatAmount(expense.amount)} so\'m',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      color: AppColors.neutral900,
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert_rounded,
                                        size: 20, color: AppColors.neutral500),
                                    onSelected: (action) {
                                      if (action == 'edit') {
                                        _showEditExpense(context, expense);
                                      } else if (action == 'delete') {
                                        _confirmDeleteExpense(context, expense);
                                      }
                                    },
                                    itemBuilder: (ctx) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit_outlined,
                                                size: 18,
                                                color: AppColors.neutral700),
                                            SizedBox(width: 8),
                                            Text('Tahrirlash'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete_outline_rounded,
                                                size: 18,
                                                color: AppColors.error),
                                            SizedBox(width: 8),
                                            Text('O\'chirish',
                                                style: TextStyle(
                                                    color: AppColors.error)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: expenses.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}


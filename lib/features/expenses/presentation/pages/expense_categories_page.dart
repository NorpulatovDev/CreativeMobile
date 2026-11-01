import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/expense_models.dart';
import '../bloc/expense_category_bloc.dart';
import '../dialogs/expense_category_form_dialog.dart';

class ExpenseCategoriesPage extends StatelessWidget {
  const ExpenseCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ExpenseCategoryBloc>()..add(const LoadExpenseCategories()),
      child: const _ExpenseCategoriesView(),
    );
  }
}

class _ExpenseCategoriesView extends StatelessWidget {
  const _ExpenseCategoriesView();

  Color _parseHex(String? hex) {
    if (hex == null || hex.isEmpty) return AppColors.primary;
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('0xFF$clean'));
    } catch (_) {
      return AppColors.primary;
    }
  }

  void _showAddCategory(BuildContext context) {
    final bloc = context.read<ExpenseCategoryBloc>();
    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: bloc,
        child: const ExpenseCategoryFormDialog(),
      ),
    );
  }

  void _showEditCategory(BuildContext context, ExpenseCategoryModel category) {
    final bloc = context.read<ExpenseCategoryBloc>();
    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: bloc,
        child: ExpenseCategoryFormDialog(category: category),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ExpenseCategoryModel category) {
    final bloc = context.read<ExpenseCategoryBloc>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Kategoriyani o\'chirish', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text(
          '"${category.name}" kategoriyasini o\'chirmoqchimisiz? Agar unga bog\'langan xarajatlar bo\'lsa, o\'chirib bo\'lmaydi.',
          style: const TextStyle(color: AppColors.neutral600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Bekor qilish', style: TextStyle(color: AppColors.neutral500)),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              bloc.add(DeleteExpenseCategoryEvent(category.id));
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('O\'chirish'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Xarajat kategoriyalari',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCategory(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Yangi kategoriya', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: BlocConsumer<ExpenseCategoryBloc, ExpenseCategoryState>(
        listener: (context, state) {
          if (state is ExpenseCategoryActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          } else if (state is ExpenseCategoryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ExpenseCategoryLoading && state is! ExpenseCategoryLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ExpenseCategoryLoaded) {
            if (state.categories.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.category_rounded, size: 36, color: AppColors.primary),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Kategoriyalar mavjud emas',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Xarajatlarni toifalash uchun avval yangi kategoriya qo\'shing.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.neutral500),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: state.categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final category = state.categories[index];
                final color = _parseHex(category.color);

                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.label_rounded, color: color, size: 22),
                    ),
                    title: Text(
                      category.name,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: AppColors.neutral600),
                          onPressed: () => _showEditCategory(context, category),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                          onPressed: () => _confirmDelete(context, category),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}


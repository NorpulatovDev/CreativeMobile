import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/payment_model.dart';
import '../bloc/payment_bloc.dart';
import '../dialogs/payment_form_dialog.dart';

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PaymentBloc>()..add(const PaymentSearch('')),
      child: const PaymentsView(),
    );
  }
}

class PaymentsView extends StatefulWidget {
  const PaymentsView({super.key});

  @override
  State<PaymentsView> createState() => _PaymentsViewState();
}

class _PaymentsViewState extends State<PaymentsView> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      final state = context.read<PaymentBloc>().state;
      if (state is PaymentLoaded && state.hasMore && !state.isLoadingMore) {
        context.read<PaymentBloc>().add(PaymentLoadMore());
      }
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) context.read<PaymentBloc>().add(PaymentSearch(value.trim()));
    });
  }

  void _showSnackBar(String message, Color backgroundColor, IconData icon) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.surfaceLight,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: const Text('To\'lovlar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.neutral900)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [const Color(0xFF8B5CF6).withOpacity(0.1), AppColors.surfaceLight]),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.neutral200),
                  boxShadow: [BoxShadow(color: AppColors.neutral900.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2))],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'To\'lovlarni qidirish...',
                    hintStyle: TextStyle(color: AppColors.neutral400, fontWeight: FontWeight.w400),
                    prefixIcon: Icon(Icons.search_rounded, color: AppColors.neutral400),
                    suffixIcon: _searchController.text.isNotEmpty ? IconButton(icon: Icon(Icons.close_rounded, color: AppColors.neutral400), onPressed: () { _searchController.clear(); context.read<PaymentBloc>().add(const PaymentSearch('')); setState(() {}); }) : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),
          ),
          BlocConsumer<PaymentBloc, PaymentState>(
            listener: (context, state) {
              if (state is PaymentError) {
                _showSnackBar(state.message, AppColors.error, Icons.error_outline);
              }
              if (state is PaymentActionSuccess) {
                _showSnackBar(state.message, AppColors.success, Icons.check_circle_outline);
              }
            },
            builder: (context, state) {
              if (state is PaymentLoading && state is! PaymentLoaded) {
                return const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6))));
              }
              if (state is PaymentLoaded) {
                if (state.payments.isEmpty) {
                  return SliverFillRemaining(
                    child: _searchController.text.isEmpty
                        ? _buildEmptyState(context)
                        : _buildNoResultsState(context),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == state.payments.length) {
                          if (state.isLoadingMore) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6), strokeWidth: 2)),
                            );
                          }
                          if (!state.hasMore) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Text('Hammasi yuklandi', style: TextStyle(color: AppColors.neutral400, fontSize: 13)),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _PaymentCard(payment: state.payments[index]),
                        );
                      },
                      childCount: state.payments.length + 1,
                    ),
                  ),
                );
              }
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPaymentDialog(context),
        backgroundColor: const Color(0xFF8B5CF6),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_card_rounded),
        label: const Text('To\'lov qo\'shish', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.payment_rounded, size: 48, color: const Color(0xFF8B5CF6)),
          ),
          const SizedBox(height: 24),
          Text('To\'lovlar yo\'q', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.neutral700, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Birinchi to\'lovni qo\'shing', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.neutral500)),
        ],
      ),
    );
  }


  Widget _buildNoResultsState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppColors.neutral100, shape: BoxShape.circle),
            child: Icon(Icons.search_off_rounded, size: 48, color: AppColors.neutral400),
          ),
          const SizedBox(height: 24),
          Text('Natija topilmadi', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.neutral700, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showPaymentDialog(BuildContext context) {
    showDialog(context: context, builder: (dialogContext) => BlocProvider.value(value: context.read<PaymentBloc>(), child: const PaymentFormDialog()));
  }
}

class _PaymentCard extends StatelessWidget {
  final PaymentModel payment;
  const _PaymentCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.neutral200.withOpacity(0.5)),
          boxShadow: [BoxShadow(color: AppColors.neutral900.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _getPaymentColor(payment.studentName).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  payment.studentName.isNotEmpty ? payment.studentName[0].toUpperCase() : 'T',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _getPaymentColor(payment.studentName)),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(payment.studentName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: AppColors.primaryContainer.withOpacity(0.5), borderRadius: BorderRadius.circular(6)),
                        child: Text(payment.groupName, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.primary)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: AppColors.neutral100, borderRadius: BorderRadius.circular(6)),
                        child: Text(payment.paidForMonth, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.neutral600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 12, color: AppColors.neutral400),
                      const SizedBox(width: 4),
                      Text(dateFormat.format(payment.paidAt), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.neutral400, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${payment.amount.toStringAsFixed(0)} so\'m',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.success),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                      onPressed: () => _showEditDialog(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      tooltip: 'Tahrirlash',
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                      onPressed: () => _showDeleteDialog(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      tooltip: 'O\'chirish',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getPaymentColor(String name) {
    final colors = [AppColors.primary, AppColors.success, AppColors.warning, const Color(0xFF8B5CF6), const Color(0xFF06B6D4), const Color(0xFFF97316), AppColors.secondary];
    return colors[name.hashCode.abs() % colors.length];
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<PaymentBloc>(),
        child: PaymentFormDialog(payment: payment),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.errorLight, shape: BoxShape.circle),
                child: Icon(Icons.delete_outline_rounded, size: 32, color: AppColors.error),
              ),
              const SizedBox(height: 20),
              Text('To\'lovni o\'chirish', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Text('${payment.studentName}ning ${payment.paidForMonth} oyi uchun to\'lovini o\'chirishni xohlaysizmi?', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.neutral500)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(dialogContext), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: BorderSide(color: AppColors.neutral300)), child: const Text('Bekor qilish'))),
                  const SizedBox(width: 12),
                  Expanded(child: ElevatedButton(onPressed: () { context.read<PaymentBloc>().add(PaymentDelete(payment.id)); Navigator.pop(dialogContext); }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)), child: const Text('O\'chirish'))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
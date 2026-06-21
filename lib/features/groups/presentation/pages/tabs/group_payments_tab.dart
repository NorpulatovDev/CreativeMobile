import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../payments/data/models/payment_model.dart';
import '../../bloc/group_payments_cubit.dart';
import '../../widgets/payment_item_card.dart';

class GroupPaymentsTab extends StatelessWidget {
  const GroupPaymentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupPaymentsCubit, GroupPaymentsState>(
      buildWhen: (prev, curr) => prev.runtimeType != curr.runtimeType || curr is GroupPaymentsLoaded,
      builder: (context, state) {
        if (state is GroupPaymentsInitial || state is GroupPaymentsLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
          );
        }

        if (state is GroupPaymentsLoaded && state.payments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.payment_rounded,
                      size: 48, color: Color(0xFF8B5CF6)),
                ),
                const SizedBox(height: 24),
                Text('To\'lovlar yo\'q',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.neutral700,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('Hali to\'lov qilinmagan',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.neutral500)),
              ],
            ),
          );
        }

        final payments =
            state is GroupPaymentsLoaded ? state.payments : <PaymentModel>[];

        return RefreshIndicator(
          onRefresh: context.read<GroupPaymentsCubit>().reload,
          color: const Color(0xFF8B5CF6),
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: payments.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PaymentItemCard(payment: payments[index]),
              );
            },
          ),
        );
      },
    );
  }
}

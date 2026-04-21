import 'package:flutter/material.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../payments/data/models/payment_model.dart';
import '../../../../payments/data/repositories/payment_repository.dart';
import '../../widgets/payment_item_card.dart';

class GroupPaymentsTab extends StatefulWidget {
  final int groupId;
  final int year;
  final int month;

  const GroupPaymentsTab({
    super.key,
    required this.groupId,
    required this.year,
    required this.month,
  });

  @override
  State<GroupPaymentsTab> createState() => _GroupPaymentsTabState();
}

class _GroupPaymentsTabState extends State<GroupPaymentsTab> {
  List<PaymentModel> _payments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final (payments, _) = await getIt<PaymentRepository>()
        .getByGroupIdAndMonth(widget.groupId, widget.year, widget.month);
    if (mounted) {
      setState(() {
        _payments = payments ?? [];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
      );
    }

    if (_payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  shape: BoxShape.circle),
              child: const Icon(Icons.payment_rounded,
                  size: 48, color: Color(0xFF8B5CF6)),
            ),
            const SizedBox(height: 24),
            Text('To\'lovlar yo\'q',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.neutral700, fontWeight: FontWeight.w600)),
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

    return RefreshIndicator(
      onRefresh: _load,
      color: const Color(0xFF8B5CF6),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _payments.length,
        itemBuilder: (context, index) {
          final payment = _payments[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PaymentItemCard(payment: payment),
          );
        },
      ),
    );
  }
}

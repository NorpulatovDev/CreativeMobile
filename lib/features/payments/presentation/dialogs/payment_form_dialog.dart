import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/sms_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../enrollments/data/models/enrollment_model.dart';
import '../../../groups/data/models/group_model.dart';
import '../../data/models/payment_model.dart';
import '../bloc/payment_bloc.dart';
import '../bloc/payment_form_cubit.dart';

class PaymentFormDialog extends StatelessWidget {
  final int? preselectedStudentId;
  final int? preselectedGroupId;
  final PaymentModel? payment;

  const PaymentFormDialog({
    super.key,
    this.preselectedStudentId,
    this.preselectedGroupId,
    this.payment,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final initialMonth =
        '${now.year}-${now.month.toString().padLeft(2, '0')}';

    return BlocProvider(
      create: (_) => PaymentFormCubit(
        groupRepo: getIt(),
        groupLocal: getIt(),
        enrollmentRepo: getIt(),
        enrollmentLocal: getIt(),
        studentRepo: getIt(),
        smsService: getIt(),
        paymentBloc: context.read<PaymentBloc>(),
        initialMonth: initialMonth,
        preselectedGroupId: preselectedGroupId,
        preselectedStudentId: preselectedStudentId,
        editing: payment,
      )..loadGroups(
          prefillAmount: payment?.amount,
        ),
      child: _PaymentFormBody(payment: payment),
    );
  }
}

class _PaymentFormBody extends StatefulWidget {
  final PaymentModel? payment;

  const _PaymentFormBody({this.payment});

  @override
  State<_PaymentFormBody> createState() => _PaymentFormBodyState();
}

class _PaymentFormBodyState extends State<_PaymentFormBody> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;

  bool get isEditing => widget.payment != null;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.payment != null
          ? widget.payment!.amount.toStringAsFixed(0)
          : '',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('SMS ruxsati'),
        content: const Text(
            'SMS yuborish uchun ilova sozlamalarida ruxsat bering.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Bekor qilish'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: const Text('Sozlamalar'),
          ),
        ],
      ),
    );
  }

  void _submit(PaymentFormReady state) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (state.selectedGroupId == null || state.selectedStudentId == null) {
      return;
    }
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) return;

    context.read<PaymentFormCubit>().submit(
          isEditing: isEditing,
          paymentId: widget.payment?.id,
          amount: amount,
        );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<PaymentBloc, PaymentState>(
          listener: (context, state) {
            if (state is PaymentActionSuccess) {
              context.read<PaymentFormCubit>().onPaymentSuccess();
            } else if (state is PaymentError) {
              context.read<PaymentFormCubit>().onPaymentError();
            }
          },
        ),
        BlocListener<PaymentFormCubit, PaymentFormState>(
          listenWhen: (prev, curr) {
            if (curr is! PaymentFormReady || prev is! PaymentFormReady) {
              return false;
            }
            return curr.smsNotification != prev.smsNotification ||
                curr.done != prev.done;
          },
          listener: (context, state) {
            if (state is! PaymentFormReady) return;
            if (state.smsNotification == SmsResult.permissionPermanentlyDenied) {
              _showSettingsDialog(context);
            }
            if (state.done) {
              Navigator.pop(context, state.smsNotification);
            }
          },
        ),
      ],
      child: BlocBuilder<PaymentFormCubit, PaymentFormState>(
        builder: (context, formState) {
          final loading = formState is PaymentFormLoading;
          final ready =
              formState is PaymentFormReady ? formState : null;

          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(context),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: loading || ready == null
                          ? const SizedBox(
                              height: 200,
                              child: Center(
                                  child: CircularProgressIndicator()),
                            )
                          : _buildForm(context, ready),
                    ),
                  ),
                  _buildFooter(context, ready),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isEditing ? Icons.edit_rounded : Icons.add_card_rounded,
              color: const Color(0xFF8B5CF6),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'To\'lovni tahrirlash' : 'Yangi to\'lov',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  isEditing
                      ? 'To\'lov ma\'lumotlarini yangilash'
                      : 'To\'lov ma\'lumotlarini kiriting',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.neutral500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context, PaymentFormReady state) {
    final selectedGroup = state.selectedGroupId != null
        ? state.groups
            .where((g) => g.id == state.selectedGroupId)
            .firstOrNull
        : null;
    final selectedStudent = state.selectedStudentId != null
        ? state.groupStudents
            .where((e) => e.studentId == state.selectedStudentId)
            .firstOrNull
        : null;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Group picker
          _FormField(
            label: 'Guruh',
            child: _PickerTile(
              icon: Icons.group_outlined,
              placeholder: 'Guruhni tanlang',
              value: selectedGroup?.name,
              subtitle: selectedGroup != null
                  ? '${selectedGroup.monthlyFee.toStringAsFixed(0)} so\'m/oy'
                  : null,
              enabled: !isEditing,
              hasError: _formKey.currentState != null &&
                  state.selectedGroupId == null,
              onTap: isEditing
                  ? null
                  : () => _openGroupPicker(context, state),
            ),
          ),
          const SizedBox(height: 16),
          // Student picker
          if (state.selectedGroupId != null) ...[
            if (state.loadingStudents)
              const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              )
            else if (state.groupStudents.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: AppColors.warning),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Bu guruhda o\'quvchilar yo\'q',
                        style: TextStyle(color: AppColors.warningDark),
                      ),
                    ),
                  ],
                ),
              )
            else
              _FormField(
                label: 'O\'quvchi',
                child: _PickerTile(
                  icon: Icons.person_outline_rounded,
                  placeholder: 'O\'quvchini tanlang',
                  value: selectedStudent?.studentName,
                  enabled: !isEditing,
                  hasError: _formKey.currentState != null &&
                      state.selectedStudentId == null,
                  onTap: isEditing
                      ? null
                      : () => _openStudentPicker(context, state),
                ),
              ),
            const SizedBox(height: 16),
          ],
          // Amount
          _FormField(
            label: 'To\'lov miqdori (so\'m)',
            child: TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.payments_outlined,
                    color: AppColors.neutral400),
                hintText: 'Masalan: 500000',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Miqdorni kiriting';
                if (double.tryParse(v) == null || double.parse(v) <= 0) {
                  return 'To\'g\'ri miqdor kiriting';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          // Month
          _FormField(
            label: 'To\'lov oyi',
            child: DropdownButtonFormField<String>(
              initialValue: state.selectedMonth,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.calendar_month_outlined,
                    color: AppColors.neutral400),
              ),
              items: _generateMonths()
                  .map((m) => DropdownMenuItem(
                        value: m,
                        child: Text(_formatMonth(m)),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  context.read<PaymentFormCubit>().selectMonth(v);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, PaymentFormReady? state) {
    final canSubmit = state != null &&
        !state.submitting &&
        !state.loadingStudents &&
        state.selectedGroupId != null &&
        state.groupStudents.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius:
            const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: state?.submitting == true
                  ? null
                  : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: AppColors.neutral300),
              ),
              child: const Text('Bekor qilish'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed:
                  canSubmit ? () => _submit(state) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: state?.submitting == true
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(isEditing ? 'Yangilash' : 'To\'lovni saqlash'),
            ),
          ),
        ],
      ),
    );
  }

  void _openGroupPicker(BuildContext context, PaymentFormReady state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SearchableGroupPicker(
        groups: state.groups,
        selectedId: state.selectedGroupId,
        onSelected: (group) {
          context.read<PaymentFormCubit>().selectGroup(
                group,
                onAmountPrefill: (fee) {
                  _amountController.text = fee.toStringAsFixed(0);
                },
              );
        },
      ),
    );
  }

  void _openStudentPicker(BuildContext context, PaymentFormReady state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SearchableStudentPicker(
        enrollments: state.groupStudents,
        selectedId: state.selectedStudentId,
        onSelected: (enrollment) {
          context.read<PaymentFormCubit>().selectStudent(enrollment.studentId);
        },
      ),
    );
  }

  List<String> _generateMonths() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final date = DateTime(now.year, now.month + i - 3, 1);
      return DateFormat('yyyy-MM').format(date);
    });
  }

  static String _formatMonth(String month) {
    final parts = month.split('-');
    const names = [
      '', 'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
      'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr',
    ];
    return '${names[int.parse(parts[1])]} ${parts[0]}';
  }
}

// ─── Picker tile ──────────────────────────────────────────────────────────────

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String placeholder;
  final String? value;
  final String? subtitle;
  final bool enabled;
  final bool hasError;
  final VoidCallback? onTap;

  const _PickerTile({
    required this.icon,
    required this.placeholder,
    this.value,
    this.subtitle,
    this.enabled = true,
    this.hasError = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;
    final borderColor = hasError ? AppColors.error : AppColors.neutral300;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: enabled ? Colors.white : AppColors.neutral100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 20,
                color:
                    hasValue ? AppColors.neutral600 : AppColors.neutral400),
            const SizedBox(width: 12),
            Expanded(
              child: hasValue
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(value!,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.neutral900)),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(subtitle!,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.neutral500)),
                        ],
                      ],
                    )
                  : Text(placeholder,
                      style: TextStyle(
                          fontSize: 14, color: AppColors.neutral400)),
            ),
            if (enabled)
              Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppColors.neutral400),
          ],
        ),
      ),
    );
  }
}

// ─── Searchable group picker ──────────────────────────────────────────────────

class _SearchableGroupPicker extends StatefulWidget {
  final List<GroupModel> groups;
  final int? selectedId;
  final ValueChanged<GroupModel> onSelected;

  const _SearchableGroupPicker({
    required this.groups,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  State<_SearchableGroupPicker> createState() => _SearchableGroupPickerState();
}

class _SearchableGroupPickerState extends State<_SearchableGroupPicker> {
  final _searchController = TextEditingController();
  String _query = '';

  List<GroupModel> get _filtered => _query.isEmpty
      ? widget.groups
      : widget.groups
          .where((g) => g.name.toLowerCase().contains(_query))
          .toList();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: AppColors.neutral300,
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.group_outlined,
                      color: Color(0xFF8B5CF6), size: 20),
                ),
                const SizedBox(width: 12),
                Text('Guruh tanlang',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Guruh nomi bo\'yicha qidirish...',
                prefixIcon:
                    Icon(Icons.search_rounded, color: AppColors.neutral400),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close_rounded,
                            color: AppColors.neutral400),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.neutral100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.45),
            child: _filtered.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('Guruh topilmadi')),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      final group = _filtered[index];
                      final isSelected = group.id == widget.selectedId;
                      return ListTile(
                        onTap: () {
                          Navigator.pop(context);
                          widget.onSelected(group);
                        },
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              group.name.isNotEmpty
                                  ? group.name[0].toUpperCase()
                                  : 'G',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF8B5CF6)),
                            ),
                          ),
                        ),
                        title: Text(group.name,
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? const Color(0xFF8B5CF6)
                                    : AppColors.neutral900)),
                        subtitle: Text(
                            '${group.monthlyFee.toStringAsFixed(0)} so\'m/oy · ${group.studentsCount} o\'quvchi',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.neutral500)),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle_rounded,
                                color: Color(0xFF8B5CF6))
                            : null,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        tileColor: isSelected
                            ? const Color(0xFF8B5CF6)
                                .withValues(alpha: 0.05)
                            : null,
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─── Searchable student picker ────────────────────────────────────────────────

class _SearchableStudentPicker extends StatefulWidget {
  final List<EnrollmentModel> enrollments;
  final int? selectedId;
  final ValueChanged<EnrollmentModel> onSelected;

  const _SearchableStudentPicker({
    required this.enrollments,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  State<_SearchableStudentPicker> createState() =>
      _SearchableStudentPickerState();
}

class _SearchableStudentPickerState
    extends State<_SearchableStudentPicker> {
  final _searchController = TextEditingController();
  String _query = '';

  List<EnrollmentModel> get _filtered => _query.isEmpty
      ? widget.enrollments
      : widget.enrollments
          .where((e) => e.studentName.toLowerCase().contains(_query))
          .toList();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: AppColors.neutral300,
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.person_outline_rounded,
                      color: AppColors.success, size: 20),
                ),
                const SizedBox(width: 12),
                Text('O\'quvchi tanlang',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Ism bo\'yicha qidirish...',
                prefixIcon:
                    Icon(Icons.search_rounded, color: AppColors.neutral400),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close_rounded,
                            color: AppColors.neutral400),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.neutral100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4),
            child: _filtered.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('O\'quvchi topilmadi')),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      final enrollment = _filtered[index];
                      final isSelected =
                          enrollment.studentId == widget.selectedId;
                      return ListTile(
                        onTap: () {
                          Navigator.pop(context);
                          widget.onSelected(enrollment);
                        },
                        leading: CircleAvatar(
                          backgroundColor:
                              AppColors.success.withValues(alpha: 0.12),
                          child: Text(
                            enrollment.studentName.isNotEmpty
                                ? enrollment.studentName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.success),
                          ),
                        ),
                        title: Text(enrollment.studentName,
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? AppColors.success
                                    : AppColors.neutral900)),
                        trailing: isSelected
                            ? Icon(Icons.check_circle_rounded,
                                color: AppColors.success)
                            : null,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        tileColor: isSelected
                            ? AppColors.success.withValues(alpha: 0.05)
                            : null,
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─── Form field label wrapper ─────────────────────────────────────────────────

class _FormField extends StatelessWidget {
  final String label;
  final Widget child;

  const _FormField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral700)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

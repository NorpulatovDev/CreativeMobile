import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/sms_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../enrollments/data/models/enrollment_model.dart';
import '../../../enrollments/data/repositories/enrollment_repository.dart';
import '../../../enrollments/data/datasources/enrollment_local_datasource.dart';
import '../../../groups/data/datasources/group_local_datasource.dart';
import '../../../groups/data/models/group_model.dart';
import '../../../groups/data/repositories/group_repository.dart';
import '../../../students/data/repositories/student_repository.dart';
import '../../data/models/payment_model.dart';
import '../bloc/payment_bloc.dart';

class PaymentFormDialog extends StatefulWidget {
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
  State<PaymentFormDialog> createState() => _PaymentFormDialogState();
}

class _PaymentFormDialogState extends State<PaymentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;

  List<GroupModel> _groups = [];
  List<EnrollmentModel> _groupStudents = [];
  bool _loadingGroups = true;
  bool _loadingStudents = false;
  bool _submitting = false;
  int? _loadedGroupId;

  bool get isEditing => widget.payment != null;

  int? _selectedGroupId;
  int? _selectedStudentId;
  String _selectedMonth = DateFormat('yyyy-MM').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _amountController = TextEditingController(
          text: widget.payment!.amount.toStringAsFixed(0));
      _selectedGroupId = widget.payment!.groupId;
      _selectedStudentId = widget.payment!.studentId;
      _selectedMonth = widget.payment!.paidForMonth;
    } else {
      _amountController = TextEditingController();
      _selectedGroupId = widget.preselectedGroupId;
      _selectedStudentId = widget.preselectedStudentId;
    }
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    // Show cached groups immediately — dialog opens without a spinner
    final cached = getIt<GroupLocalDataSource>().getAll();
    if (cached.isNotEmpty) _applyGroups(cached);

    // Refresh from network in the background
    final (groups, _) = await getIt<GroupRepository>().getAll();
    if (mounted && groups != null) _applyGroups(groups);
  }

  void _applyGroups(List<GroupModel> groups) {
    setState(() {
      _groups = groups;
      _loadingGroups = false;
    });
    if (_selectedGroupId != null && _loadedGroupId != _selectedGroupId) {
      _loadStudentsForGroup(_selectedGroupId!);
      if (!isEditing) {
        final group = _groups.where((g) => g.id == _selectedGroupId).firstOrNull;
        if (group != null) _amountController.text = group.monthlyFee.toStringAsFixed(0);
      }
    }
  }

  Future<void> _loadStudentsForGroup(int groupId) async {
    final cached = getIt<EnrollmentLocalDataSource>()
        .getGroupStudents(groupId)
        .where((e) => e.active)
        .toList();
    setState(() {
      _loadedGroupId = groupId;
      _groupStudents = cached;
      _loadingStudents = cached.isEmpty;
      if (cached.isEmpty && widget.preselectedStudentId == null && !isEditing) {
        _selectedStudentId = null;
      }
    });
    final (enrollments, _) =
        await getIt<EnrollmentRepository>().getGroupStudents(groupId);
    if (!mounted || _loadedGroupId != groupId) return;
    setState(() {
      _groupStudents =
          (enrollments ?? cached).where((e) => e.active).toList();
      _loadingStudents = false;
      if (_selectedStudentId != null && !isEditing) {
        final exists =
            _groupStudents.any((e) => e.studentId == _selectedStudentId);
        if (!exists) _selectedStudentId = null;
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  List<String> _generateMonths() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final date = DateTime(now.year, now.month + i - 3, 1);
      return DateFormat('yyyy-MM').format(date);
    });
  }

  String _formatMonth(String month) {
    final parts = month.split('-');
    const monthNames = [
      '', 'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
      'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr',
    ];
    return '${monthNames[int.parse(parts[1])]} ${parts[0]}';
  }

  void _openGroupPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SearchableGroupPicker(
        groups: _groups,
        selectedId: _selectedGroupId,
        onSelected: (group) {
          setState(() {
            _selectedGroupId = group.id;
            _amountController.text = group.monthlyFee.toStringAsFixed(0);
          });
          _loadStudentsForGroup(group.id);
        },
      ),
    );
  }

  void _openStudentPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SearchableStudentPicker(
        enrollments: _groupStudents,
        selectedId: _selectedStudentId,
        onSelected: (enrollment) =>
            setState(() => _selectedStudentId = enrollment.studentId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedGroup = _selectedGroupId != null
        ? _groups.where((g) => g.id == _selectedGroupId).firstOrNull
        : null;
    final selectedStudent = _selectedStudentId != null
        ? _groupStudents
            .where((e) => e.studentId == _selectedStudentId)
            .firstOrNull
        : null;

    return BlocListener<PaymentBloc, PaymentState>(
      listener: (context, state) {
        if (state is PaymentActionSuccess) {
          Navigator.pop(context, true);
        } else if (state is PaymentError) {
          setState(() => _submitting = false);
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
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
              ),
              // Form
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _loadingGroups
                      ? const SizedBox(
                          height: 200,
                          child: Center(child: CircularProgressIndicator()))
                      : Form(
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
                                      _selectedGroupId == null,
                                  onTap: isEditing ? null : _openGroupPicker,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Student picker
                              if (_selectedGroupId != null) ...[
                                if (_loadingStudents)
                                  const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: CircularProgressIndicator(),
                                  )
                                else if (_groupStudents.isEmpty)
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
                                            style: TextStyle(
                                                color: AppColors.warningDark),
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
                                          _selectedStudentId == null,
                                      onTap:
                                          isEditing ? null : _openStudentPicker,
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
                                    if (v == null || v.trim().isEmpty) {
                                      return 'Miqdorni kiriting';
                                    }
                                    if (double.tryParse(v) == null ||
                                        double.parse(v) <= 0) {
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
                                  initialValue: _selectedMonth,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(
                                        Icons.calendar_month_outlined,
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
                                      setState(() => _selectedMonth = v);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              // Footer
              Container(
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
                        onPressed:
                            _submitting ? null : () => Navigator.pop(context),
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
                        onPressed: _loadingGroups ||
                                _loadingStudents ||
                                _selectedGroupId == null ||
                                _groupStudents.isEmpty ||
                                _submitting
                            ? null
                            : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: _submitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : Text(isEditing
                                ? 'Yangilash'
                                : 'To\'lovni saqlash'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedGroupId == null || _selectedStudentId == null) {
      setState(() {});
      return;
    }
    setState(() => _submitting = true);
    try {
      final bloc = context.read<PaymentBloc>();
      if (isEditing) {
        bloc.add(PaymentUpdate(
          id: widget.payment!.id,
          studentId: _selectedStudentId!,
          groupId: _selectedGroupId!,
          amount: double.parse(_amountController.text.trim()),
          paidForMonth: _selectedMonth,
        ));
      } else {
        final amount = _amountController.text.trim();
        final month = _selectedMonth;
        final (student, _) =
            await getIt<StudentRepository>().getById(_selectedStudentId!);
        bloc.add(PaymentCreate(
          studentId: _selectedStudentId!,
          groupId: _selectedGroupId!,
          amount: double.parse(amount),
          paidForMonth: month,
        ));
        if (student != null) {
          await getIt<SmsService>().send(
            student.parentPhoneNumber,
            "Assalomu alaykum!\nCreative O'quv Markazi ma'muriyati sizga ma'lum qiladiki, ${student.fullName}ning ${_formatMonth(month)} oyi uchun $amount so'm to'lovi qabul qilindi.\nRahmat!",
          );
        }
        return;
      }
      Navigator.pop(context, true);
    } catch (_) {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

// ─── Picker tile (replaces DropdownButtonFormField) ──────────────────────────

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
    final borderColor =
        hasError ? AppColors.error : AppColors.neutral300;

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
                color: hasValue ? AppColors.neutral600 : AppColors.neutral400),
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
                                  fontSize: 12, color: AppColors.neutral500)),
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
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
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
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
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
                                fontSize: 12, color: AppColors.neutral500)),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle_rounded,
                                color: Color(0xFF8B5CF6))
                            : null,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        tileColor: isSelected
                            ? const Color(0xFF8B5CF6).withValues(alpha: 0.05)
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

class _SearchableStudentPickerState extends State<_SearchableStudentPicker> {
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
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
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
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral700)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../enrollments/data/models/enrollment_model.dart';
import '../../../enrollments/data/repositories/enrollment_repository.dart';
import '../../../groups/data/models/group_model.dart';
import '../../../groups/data/repositories/group_repository.dart';
import '../../../students/data/repositories/student_repository.dart';
import '../../data/models/payment_model.dart';
import '../bloc/payment_bloc.dart';

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PaymentBloc>()..add(PaymentLoadAll()),
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
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                  onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'To\'lovlarni qidirish...',
                    hintStyle: TextStyle(color: AppColors.neutral400, fontWeight: FontWeight.w400),
                    prefixIcon: Icon(Icons.search_rounded, color: AppColors.neutral400),
                    suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: Icon(Icons.close_rounded, color: AppColors.neutral400), onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); }) : null,
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
                final filteredPayments = _searchQuery.isEmpty ? state.payments : state.payments.where((p) => p.studentName.toLowerCase().contains(_searchQuery) || p.groupName.toLowerCase().contains(_searchQuery) || p.paidForMonth.contains(_searchQuery)).toList();
                if (state.payments.isEmpty) {
                  return SliverFillRemaining(child: _buildEmptyState(context));
                }
                if (filteredPayments.isEmpty) {
                  return SliverFillRemaining(child: _buildNoResultsState(context));
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(delegate: SliverChildBuilderDelegate((context, index) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _PaymentCard(payment: filteredPayments[index])), childCount: filteredPayments.length)),
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
          ],
        ),
      ),
    );
  }

  Color _getPaymentColor(String name) {
    final colors = [AppColors.primary, AppColors.success, AppColors.warning, const Color(0xFF8B5CF6), const Color(0xFF06B6D4), const Color(0xFFF97316), AppColors.secondary];
    return colors[name.hashCode.abs() % colors.length];
  }
}

class PaymentFormDialog extends StatefulWidget {
  final int? preselectedStudentId;
  final int? preselectedGroupId;

  const PaymentFormDialog({super.key, this.preselectedStudentId, this.preselectedGroupId});

  @override
  State<PaymentFormDialog> createState() => _PaymentFormDialogState();
}

class _PaymentFormDialogState extends State<PaymentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  List<GroupModel> _groups = [];
  List<EnrollmentModel> _groupStudents = [];
  bool _loadingGroups = true;
  bool _loadingStudents = false;
  bool _submitting = false;

  int? _selectedGroupId;
  int? _selectedStudentId;
  String _selectedMonth = DateFormat('yyyy-MM').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _selectedGroupId = widget.preselectedGroupId;
    _selectedStudentId = widget.preselectedStudentId;
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final (groups, _) = await getIt<GroupRepository>().getAll();
    if (mounted) {
      setState(() { _groups = groups ?? []; _loadingGroups = false; });
      if (_selectedGroupId != null) {
        _loadStudentsForGroup(_selectedGroupId!);
        final group = _groups.firstWhere((g) => g.id == _selectedGroupId);
        _amountController.text = group.monthlyFee.toStringAsFixed(0);
      }
    }
  }

  Future<void> _loadStudentsForGroup(int groupId) async {
    setState(() { _loadingStudents = true; _groupStudents = []; if (widget.preselectedStudentId == null) _selectedStudentId = null; });
    final (enrollments, _) = await getIt<EnrollmentRepository>().getGroupStudents(groupId);
    if (mounted) {
      setState(() {
        _groupStudents = (enrollments ?? []).where((e) => e.active).toList();
        _loadingStudents = false;
        if (_selectedStudentId != null) {
          final exists = _groupStudents.any((e) => e.studentId == _selectedStudentId);
          if (!exists) _selectedStudentId = null;
        }
      });
    }
  }

  @override
  void dispose() { _amountController.dispose(); super.dispose(); }

  List<String> _generateMonths() {
    final now = DateTime.now();
    final months = <String>[];
    for (var i = -3; i <= 3; i++) {
      final date = DateTime(now.year, now.month + i, 1);
      months.add(DateFormat('yyyy-MM').format(date));
    }
    return months;
  }

  String _formatMonth(String month) {
    final parts = month.split('-');
    final monthNames = ['', 'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun', 'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr'];
    return '${monthNames[int.parse(parts[1])]} ${parts[0]}';
  }

  Future<void> _sendPaymentSMS(String phoneNumber, String studentName, String groupName, String amount, String month) async {
    final monthFormatted = _formatMonth(month);
    final message = Uri.encodeComponent(
      "Assalomu alaykum! ${studentName}ning $monthFormatted oyi uchun $amount so‘m to‘lovi qabul qilindi. Rahmat!",
    );
    
    final smsUri = Uri.parse('sms:$phoneNumber?body=$message');
    
    try {
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text('SMS yuborishda xatolik yuz berdi')),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('SMS yuborishda xatolik: $e')),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withOpacity(0.1), borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
              child: Row(children: [
                Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.add_card_rounded, color: const Color(0xFF8B5CF6))),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Yangi to\'lov', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)), const SizedBox(height: 4), Text('To\'lov ma\'lumotlarini kiriting', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.neutral500))])),
              ]),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _loadingGroups
                    ? const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()))
                    : Form(
                        key: _formKey,
                        child: Column(children: [
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Guruh', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.neutral700)),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<int>(
                              value: _selectedGroupId,
                              decoration: InputDecoration(prefixIcon: Icon(Icons.group_outlined, color: AppColors.neutral400)),
                              items: _groups.map((g) => DropdownMenuItem(value: g.id, child: Text('${g.name} (${g.monthlyFee.toStringAsFixed(0)} so\'m)'))).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() { _selectedGroupId = value; final group = _groups.firstWhere((g) => g.id == value); _amountController.text = group.monthlyFee.toStringAsFixed(0); });
                                  _loadStudentsForGroup(value);
                                }
                              },
                              validator: (v) => v == null ? 'Guruhni tanlang' : null,
                            ),
                          ]),
                          const SizedBox(height: 16),
                          if (_selectedGroupId != null) ...[
                            if (_loadingStudents)
                              const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())
                            else if (_groupStudents.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(color: AppColors.warningLight, borderRadius: BorderRadius.circular(12)),
                                child: Row(children: [Icon(Icons.warning_amber_rounded, color: AppColors.warning), const SizedBox(width: 12), Expanded(child: Text('Bu guruhda o\'quvchilar yo\'q', style: TextStyle(color: AppColors.warningDark)))]),
                              )
                            else
                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text('O\'quvchi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.neutral700)),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<int>(
                                  value: _selectedStudentId,
                                  decoration: InputDecoration(prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.neutral400)),
                                  items: _groupStudents.map((e) => DropdownMenuItem(value: e.studentId, child: Text(e.studentName))).toList(),
                                  onChanged: (v) => setState(() => _selectedStudentId = v),
                                  validator: (v) => v == null ? 'O\'quvchini tanlang' : null,
                                ),
                              ]),
                            const SizedBox(height: 16),
                          ],
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('To\'lov miqdori (so\'m)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.neutral700)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(prefixIcon: Icon(Icons.payments_outlined, color: AppColors.neutral400), hintText: 'Masalan: 500000'),
                              validator: (v) { if (v == null || v.trim().isEmpty) return 'Miqdorni kiriting'; if (double.tryParse(v) == null || double.parse(v) <= 0) return 'To\'g\'ri miqdor kiriting'; return null; },
                            ),
                          ]),
                          const SizedBox(height: 16),
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('To\'lov oyi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.neutral700)),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _selectedMonth,
                              decoration: InputDecoration(prefixIcon: Icon(Icons.calendar_month_outlined, color: AppColors.neutral400)),
                              items: _generateMonths().map((m) => DropdownMenuItem(value: m, child: Text(_formatMonth(m)))).toList(),
                              onChanged: (v) { if (v != null) setState(() => _selectedMonth = v); },
                            ),
                          ]),
                        ]),
                      ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AppColors.neutral50, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24))),
              child: Row(children: [
                Expanded(child: OutlinedButton(onPressed: _submitting ? null : () => Navigator.pop(context), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: BorderSide(color: AppColors.neutral300)), child: const Text('Bekor qilish'))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(
                  onPressed: _loadingGroups || _loadingStudents || _selectedGroupId == null || _groupStudents.isEmpty || _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: _submitting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('To\'lovni saqlash'),
                )),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _submitting = true);
      
      try {
        // Get student data to retrieve parent phone number
        final (student, error) = await getIt<StudentRepository>().getById(_selectedStudentId!);
        
        if (student == null || error != null) {
          if (mounted) {
            setState(() => _submitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text('O\'quvchi ma\'lumotlarini olishda xatolik')),
                  ],
                ),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
          return;
        }
        
        final selectedGroup = _groups.firstWhere((g) => g.id == _selectedGroupId);
        final amount = _amountController.text.trim();
        
        // Create payment
        context.read<PaymentBloc>().add(PaymentCreate(
          studentId: _selectedStudentId!,
          groupId: _selectedGroupId!,
          amount: double.parse(amount),
          paidForMonth: _selectedMonth,
        ));
        
        // Close dialog
        Navigator.pop(context);
        
        // Send SMS with parent phone number from student data
        await _sendPaymentSMS(
          student.parentPhoneNumber,
          student.fullName,
          selectedGroup.name,
          amount,
          _selectedMonth,
        );
      } catch (e) {
        if (mounted) {
          setState(() => _submitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Xatolik yuz berdi: $e')),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    }
  }
}
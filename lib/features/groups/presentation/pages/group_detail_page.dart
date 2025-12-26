import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../enrollments/data/models/enrollment_model.dart';
import '../../../enrollments/data/repositories/enrollment_repository.dart';
import '../../../payments/data/models/payment_model.dart';
import '../../../payments/data/repositories/payment_repository.dart';
import '../../../payments/presentation/pages/payments_page.dart';
import '../../../students/data/models/student_model.dart';
import '../../../students/data/repositories/student_repository.dart';
import '../../data/models/group_model.dart';
import '../../data/repositories/group_repository.dart';

class GroupDetailPage extends StatefulWidget {
  final int groupId;

  const GroupDetailPage({super.key, required this.groupId});

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  GroupModel? _group;
  List<EnrollmentModel> _enrollments = [];
  List<PaymentModel> _payments = [];
  List<StudentModel> _allStudents = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final (group, _) = await getIt<GroupRepository>().getById(widget.groupId);
    final (enrollments, _) = await getIt<EnrollmentRepository>().getGroupStudents(widget.groupId);
    final (payments, _) = await getIt<PaymentRepository>().getByGroupId(widget.groupId);
    final (students, _) = await getIt<StudentRepository>().getAll();

    if (mounted) {
      setState(() {
        _group = group;
        _enrollments = enrollments ?? [];
        _payments = payments ?? [];
        _allStudents = students ?? [];
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, Color backgroundColor, IconData icon) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [Icon(icon, color: Colors.white), const SizedBox(width: 12), Expanded(child: Text(message))]),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_group == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: AppColors.errorLight, shape: BoxShape.circle),
                child: Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
              ),
              const SizedBox(height: 24),
              Text('Guruh topilmadi', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.neutral700, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.gradientStart, AppColors.gradientEnd]),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                              child: Center(child: Text(_group!.name.isNotEmpty ? _group!.name[0].toUpperCase() : 'G', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white))),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_group!.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.person_outline_rounded, size: 16, color: Colors.white.withOpacity(0.8)),
                                      const SizedBox(width: 6),
                                      Text(_group!.teacherName, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9))),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            _StatItem(icon: Icons.people_rounded, value: '${_group!.studentsCount}', label: 'O\'quvchi'),
                            const SizedBox(width: 24),
                            _StatItem(icon: Icons.payments_rounded, value: '${_group!.monthlyFee.toStringAsFixed(0)}', label: 'so\'m/oy'),
                            const SizedBox(width: 24),
                            _StatItem(icon: Icons.account_balance_wallet_rounded, value: '${_group!.totalPaid.toStringAsFixed(0)}', label: 'Jami'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.neutral400,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                  tabs: const [
                    Tab(text: 'O\'quvchilar', icon: Icon(Icons.people_rounded, size: 20)),
                    Tab(text: 'To\'lovlar', icon: Icon(Icons.payment_rounded, size: 20)),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildStudentsTab(),
            _buildPaymentsTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 0) {
            _showEnrollStudentDialog();
          } else {
            _showAddPaymentDialog();
          }
        },
        backgroundColor: _tabController.index == 0 ? AppColors.success : const Color(0xFF8B5CF6),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: Icon(_tabController.index == 0 ? Icons.person_add_rounded : Icons.add_card_rounded),
        label: Text(_tabController.index == 0 ? 'O\'quvchi qo\'shish' : 'To\'lov qo\'shish', style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildStudentsTab() {
    if (_enrollments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(Icons.people_outline_rounded, size: 48, color: AppColors.success),
            ),
            const SizedBox(height: 24),
            Text('O\'quvchilar yo\'q', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.neutral700, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Guruhga o\'quvchi qo\'shing', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.neutral500)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.success,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _enrollments.length,
        itemBuilder: (context, index) {
          final enrollment = _enrollments[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _StudentEnrollmentCard(
              enrollment: enrollment,
              onRemove: () => _showRemoveStudentDialog(enrollment),
              onTap: () => context.push('${Routes.students}/${enrollment.studentId}'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentsTab() {
    if (_payments.isEmpty) {
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
            Text('Hali to\'lov qilinmagan', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.neutral500)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFF8B5CF6),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _payments.length,
        itemBuilder: (context, index) {
          final payment = _payments[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _PaymentItemCard(payment: payment),
          );
        },
      ),
    );
  }

  void _showEnrollStudentDialog() {
    final enrolledIds = _enrollments.map((e) => e.studentId).toSet();
    final availableStudents = _allStudents.where((s) => !enrolledIds.contains(s.id)).toList();

    if (availableStudents.isEmpty) {
      _showSnackBar('Barcha o\'quvchilar allaqachon ro\'yxatdan o\'tgan', AppColors.warning, Icons.info_outline);
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => _EnrollStudentDialog(
        availableStudents: availableStudents,
        groupId: widget.groupId,
        onEnrolled: _loadData,
      ),
    );
  }

  void _showRemoveStudentDialog(EnrollmentModel enrollment) {
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
                child: Icon(Icons.person_remove_rounded, size: 32, color: AppColors.error),
              ),
              const SizedBox(height: 20),
              Text('O\'quvchini chiqarish', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Text('${enrollment.studentName}ni ${_group!.name} guruhidan chiqarishni xohlaysizmi?', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.neutral500)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(dialogContext), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: BorderSide(color: AppColors.neutral300)), child: const Text('Bekor qilish'))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(dialogContext);
                        await getIt<EnrollmentRepository>().removeStudentFromGroup(enrollment.studentId, widget.groupId);
                        _loadData();
                        _showSnackBar('O\'quvchi guruhdan chiqarildi', AppColors.success, Icons.check_circle_outline);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: const Text('Chiqarish'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddPaymentDialog() {
    if (_enrollments.isEmpty) {
      _showSnackBar('Bu guruhda o\'quvchilar yo\'q', AppColors.warning, Icons.info_outline);
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => PaymentFormDialog(preselectedGroupId: widget.groupId),
    ).then((_) => _loadData());
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.8))),
          ],
        ),
      ],
    );
  }
}

class _StudentEnrollmentCard extends StatelessWidget {
  final EnrollmentModel enrollment;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _StudentEnrollmentCard({required this.enrollment, required this.onRemove, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: _getAvatarColor(enrollment.studentName).withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                child: Center(child: Text(enrollment.studentName.isNotEmpty ? enrollment.studentName[0].toUpperCase() : '?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _getAvatarColor(enrollment.studentName)))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(enrollment.studentName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.neutral400),
                        const SizedBox(width: 4),
                        Text('Qo\'shilgan: ${dateFormat.format(enrollment.enrolledAt)}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.neutral500)),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: Icon(Icons.remove_circle_outline_rounded, color: AppColors.error),
                tooltip: 'Guruhdan chiqarish',
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.neutral400),
            ],
          ),
        ),
      ),
    );
  }

  Color _getAvatarColor(String name) {
    final colors = [AppColors.primary, AppColors.success, AppColors.warning, const Color(0xFF8B5CF6), const Color(0xFF06B6D4), const Color(0xFFF97316), AppColors.secondary];
    return colors[name.hashCode.abs() % colors.length];
  }
}

class _PaymentItemCard extends StatelessWidget {
  final PaymentModel payment;

  const _PaymentItemCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Container(
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
            child: const Center(child: Icon(Icons.receipt_long_rounded, color: Color(0xFF8B5CF6))),
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
                      decoration: BoxDecoration(color: AppColors.neutral100, borderRadius: BorderRadius.circular(6)),
                      child: Text(payment.paidForMonth, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.neutral600)),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.access_time_rounded, size: 12, color: AppColors.neutral400),
                    const SizedBox(width: 4),
                    Text(dateFormat.format(payment.paidAt), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.neutral400, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(10)),
            child: Text('${payment.amount.toStringAsFixed(0)} so\'m', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.success)),
          ),
        ],
      ),
    );
  }
}

class _EnrollStudentDialog extends StatefulWidget {
  final List<StudentModel> availableStudents;
  final int groupId;
  final VoidCallback onEnrolled;

  const _EnrollStudentDialog({required this.availableStudents, required this.groupId, required this.onEnrolled});

  @override
  State<_EnrollStudentDialog> createState() => _EnrollStudentDialogState();
}

class _EnrollStudentDialogState extends State<_EnrollStudentDialog> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<StudentModel> get _filteredStudents {
    if (_searchQuery.isEmpty) return widget.availableStudents;
    return widget.availableStudents.where((s) => s.fullName.toLowerCase().contains(_searchQuery) || s.parentName.toLowerCase().contains(_searchQuery) || s.parentPhoneNumber.contains(_searchQuery)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
              child: Row(children: [
                Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.success.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.person_add_rounded, color: AppColors.success)),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('O\'quvchi qo\'shish', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)), const SizedBox(height: 4), Text('Guruhga qo\'shish uchun o\'quvchini tanlang', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.neutral500))])),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.neutral50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.neutral200),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Ism bo\'yicha qidirish...',
                    hintStyle: TextStyle(color: AppColors.neutral400),
                    prefixIcon: Icon(Icons.search_rounded, color: AppColors.neutral400),
                    suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: Icon(Icons.close_rounded, color: AppColors.neutral400), onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); }) : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),
            Flexible(
              child: _filteredStudents.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 48, color: AppColors.neutral300),
                          const SizedBox(height: 12),
                          Text('O\'quvchi topilmadi', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.neutral500)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      shrinkWrap: true,
                      itemCount: _filteredStudents.length,
                      itemBuilder: (context, index) {
                        final student = _filteredStudents[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                Navigator.pop(context);
                                await getIt<EnrollmentRepository>().addStudentToGroup(student.id, widget.groupId);
                                widget.onEnrolled();
                              },
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.neutral200.withOpacity(0.5)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(color: _getAvatarColor(student.fullName).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                                      child: Center(child: Text(student.fullName.isNotEmpty ? student.fullName[0].toUpperCase() : '?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _getAvatarColor(student.fullName)))),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(student.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                          const SizedBox(height: 2),
                                          Text(student.parentPhoneNumber, style: TextStyle(fontSize: 12, color: AppColors.neutral500)),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                                      child: Icon(Icons.add_rounded, size: 20, color: AppColors.success),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: BorderSide(color: AppColors.neutral300)),
                  child: const Text('Bekor qilish'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAvatarColor(String name) {
    final colors = [AppColors.primary, AppColors.success, AppColors.warning, const Color(0xFF8B5CF6), const Color(0xFF06B6D4), const Color(0xFFF97316), AppColors.secondary];
    return colors[name.hashCode.abs() % colors.length];
  }
}
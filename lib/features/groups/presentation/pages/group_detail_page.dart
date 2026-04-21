import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/services/sms_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../attendance/data/models/attendance_model.dart';
import '../../../attendance/presentation/bloc/attendance_bloc.dart';
import '../../../enrollments/data/models/enrollment_model.dart';
import '../../../enrollments/data/repositories/enrollment_repository.dart';
import '../../../payments/data/models/payment_model.dart';
import '../../../payments/data/repositories/payment_repository.dart';
import '../../../payments/presentation/bloc/payment_bloc.dart';
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

class _GroupDetailPageState extends State<GroupDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AttendanceBloc _attendanceBloc;
  GroupModel? _group;
  List<StudentModel> _students = [];
  List<PaymentModel> _payments = [];
  bool _loading = true;

  // Selected month/year
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _selectedMonth = DateTime.now();
    _attendanceBloc = getIt<AttendanceBloc>();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    final year = _selectedMonth.year;
    final month = _selectedMonth.month;

    final (group, _) =
        await getIt<GroupRepository>().getById(widget.groupId);
    final (students, _) = await getIt<StudentRepository>()
        .getByGroupId(widget.groupId, year: year, month: month);
    final (payments, _) = await getIt<PaymentRepository>()
        .getByGroupIdAndMonth(widget.groupId, year, month);

    if (mounted) {
      setState(() {
        _group = group;
        _students = students ?? [];
        _payments = payments ?? [];
        _loading = false;
      });
      _attendanceBloc.add(AttendanceLoadByGroupAndMonth(
        groupId: widget.groupId,
        year: year,
        month: month,
      ));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _attendanceBloc.close();
    super.dispose();
  }

  void _showSnackBar(String message, Color backgroundColor, IconData icon) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(message))
        ]),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showMonthPicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(2020, 1);
    final lastDate = DateTime(now.year + 1, 12);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 350),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Oy tanlang',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: YearMonthPicker(
                  selectedDate: _selectedMonth,
                  firstDate: firstDate,
                  lastDate: lastDate,
                  onChanged: (date) {
                    Navigator.pop(context);
                    setState(() => _selectedMonth = date);
                    _loadData();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
      'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
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
                decoration: BoxDecoration(
                    color: AppColors.errorLight, shape: BoxShape.circle),
                child: Icon(Icons.error_outline_rounded,
                    size: 48, color: AppColors.error),
              ),
              const SizedBox(height: 24),
              Text('Guruh topilmadi',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.neutral700, fontWeight: FontWeight.w600)),
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
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.gradientStart, AppColors.gradientEnd]),
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
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Center(
                                  child: Text(
                                      _group!.name.isNotEmpty
                                          ? _group!.name[0].toUpperCase()
                                          : 'G',
                                      style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white))),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_group!.name,
                                      style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.person_outline_rounded,
                                          size: 16,
                                          color:
                                              Colors.white.withOpacity(0.8)),
                                      const SizedBox(width: 6),
                                      Text(_group!.teacherName,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white
                                                  .withOpacity(0.9))),
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
                            _StatItem(
                                icon: Icons.people_rounded,
                                value: '${_group!.studentsCount}',
                                label: 'O\'quvchi'),
                            const SizedBox(width: 24),
                            _StatItem(
                                icon: Icons.payments_rounded,
                                value:
                                    '${_group!.monthlyFee.toStringAsFixed(0)}',
                                label: 'so\'m/oy'),
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
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24)),
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
                    Tab(text: 'Davomat', icon: Icon(Icons.fact_check_rounded, size: 20)),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: Column(
          children: [
            // Month selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.neutral200.withOpacity(0.5),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_month_rounded,
                      size: 20, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_getMonthName(_selectedMonth.month).toUpperCase()} ${_selectedMonth.year}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral700,
                      ),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _showMonthPicker,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'O\'zgartirish',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_drop_down,
                                size: 20, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildStudentsTab(),
                  _buildPaymentsTab(),
                  _DavomatTab(
                    bloc: _attendanceBloc,
                    groupId: widget.groupId,
                    year: _selectedMonth.year,
                    month: _selectedMonth.month,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 0) {
            _showEnrollStudentDialog();
          } else if (_tabController.index == 1) {
            _showAddPaymentDialog();
          } else {
            _showTakeAttendanceSheet();
          }
        },
        backgroundColor: _tabController.index == 0
            ? AppColors.success
            : _tabController.index == 1
                ? const Color(0xFF8B5CF6)
                : const Color(0xFF0891B2),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: Icon(_tabController.index == 0
            ? Icons.person_add_rounded
            : _tabController.index == 1
                ? Icons.add_card_rounded
                : Icons.edit_calendar_rounded),
        label: Text(
          _tabController.index == 0
              ? 'O\'quvchi qo\'shish'
              : _tabController.index == 1
                  ? 'To\'lov qo\'shish'
                  : 'Davomat olish',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildStudentsTab() {
    if (_students.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle),
              child: Icon(Icons.people_outline_rounded,
                  size: 48, color: AppColors.success),
            ),
            const SizedBox(height: 24),
            Text('O\'quvchilar yo\'q',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.neutral700, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Guruhga o\'quvchi qo\'shing',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.neutral500)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.success,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _students.length,
        itemBuilder: (context, index) {
          final student = _students[index];

          // Find payment status for this student in this group
          GroupInfo? groupInfo;
          try {
            groupInfo = student.activeGroups.firstWhere(
              (g) => g.groupId == widget.groupId,
            );
          } catch (e) {
            // If not found, try to get first available group
            if (student.activeGroups.isNotEmpty) {
              groupInfo = student.activeGroups.first;
            }
          }

          if (groupInfo == null) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _StudentCard(
              student: student,
              groupInfo: groupInfo,
              onTap: () => context.push('${Routes.students}/${student.id}'),
              onLongPress: () => _confirmRemoveStudent(student),
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
              decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  shape: BoxShape.circle),
              child: Icon(Icons.payment_rounded,
                  size: 48, color: const Color(0xFF8B5CF6)),
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

  void _confirmRemoveStudent(StudentModel student) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('O\'quvchini chiqarish'),
        content: Text(
          '${student.fullName} guruhdan chiqarilsinmi?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Bekor qilish'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              final failure = await getIt<EnrollmentRepository>()
                  .removeStudentFromGroup(student.id, widget.groupId);
              if (!mounted) return;
              if (failure != null) {
                _showSnackBar(
                    'Xatolik yuz berdi', AppColors.error, Icons.error_outline);
              } else {
                _showSnackBar('${student.fullName} guruhdan chiqarildi',
                    AppColors.success, Icons.check_circle_outline);
                _loadData();
              }
            },
            child: const Text('Chiqarish'),
          ),
        ],
      ),
    );
  }

  void _showTakeAttendanceSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: _attendanceBloc,
        child: _TakeAttendanceSheet(
          groupId: widget.groupId,
          groupName: _group?.name ?? '',
          initialDate: _selectedMonth,
          students: _students,
        ),
      ),
    );
  }

  void _showEnrollStudentDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => _EnrollStudentDialog(
        groupId: widget.groupId,
        onEnrolled: _loadData,
        onError: (message) =>
            _showSnackBar(message, AppColors.error, Icons.error_outline),
        onWarning: (message) =>
            _showSnackBar(message, AppColors.warning, Icons.info_outline),
      ),
    );
  }

  void _showAddPaymentDialog() {
    if (_students.isEmpty) {
      _showSnackBar('Bu guruhda o\'quvchilar yo\'q', AppColors.warning,
          Icons.info_outline);
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider(
        create: (_) => getIt<PaymentBloc>(),
        child: PaymentFormDialog(preselectedGroupId: widget.groupId),
      ),
    ).then((_) => _loadData());
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem(
      {required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
            Text(label,
                style: TextStyle(
                    fontSize: 11, color: Colors.white.withOpacity(0.8))),
          ],
        ),
      ],
    );
  }
}

class _StudentCard extends StatelessWidget {
  final StudentModel student;
  final GroupInfo groupInfo;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _StudentCard({
    required this.student,
    required this.groupInfo,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final double amountPaid = groupInfo.amountPaidThisMonth ?? 0;
    final double monthlyFee = groupInfo.monthlyFee;
    
    final bool isFullyPaid = amountPaid >= monthlyFee;
    final bool isUnpaid = amountPaid <= 0;
    
    Color statusColor;
    Color statusLightColor;
    IconData statusIcon;
    String statusText;

    if (isFullyPaid) {
      statusColor = AppColors.success;
      statusLightColor = AppColors.successLight;
      statusIcon = Icons.check_circle_rounded;
      statusText = '${amountPaid.toStringAsFixed(0)} so\'m';
    } else if (isUnpaid) {
      statusColor = AppColors.error;
      statusLightColor = AppColors.errorLight;
      statusIcon = Icons.cancel_rounded;
      statusText = 'To\'lanmagan';
    } else {
      statusColor = AppColors.warning;
      statusLightColor = AppColors.warningLight;
      statusIcon = Icons.timelapse_rounded;
      statusText = '${amountPaid.toStringAsFixed(0)} so\'m';
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: statusColor.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.neutral900.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusLightColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    student.fullName.isNotEmpty
                        ? student.fullName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.fullName,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusLightColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            statusIcon,
                            size: 14,
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.neutral400),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentItemCard extends StatelessWidget {
  final PaymentModel payment;

  const _PaymentItemCard({required this.payment});

  String _formatDate(DateTime date) {
    const months = [
      'Yan', 'Fev', 'Mar', 'Apr', 'May', 'Iyun',
      'Iyul', 'Avg', 'Sen', 'Okt', 'Noy', 'Dek'
    ];
    
    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    
    return '$day $month $year, $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral200.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
              color: AppColors.neutral900.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(14)),
            child: const Center(
                child: Icon(Icons.receipt_long_rounded,
                    color: Color(0xFF8B5CF6))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(payment.studentName,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: AppColors.neutral100,
                          borderRadius: BorderRadius.circular(6)),
                      child: Text(payment.paidForMonth,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.neutral600)),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.access_time_rounded,
                        size: 12, color: AppColors.neutral400),
                    const SizedBox(width: 4),
                    Text(_formatDate(payment.paidAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral400, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(10)),
            child: Text('${payment.amount.toStringAsFixed(0)} so\'m',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success)),
          ),
        ],
      ),
    );
  }
}

class _EnrollStudentDialog extends StatefulWidget {
  final int groupId;
  final VoidCallback onEnrolled;
  final Function(String) onError;
  final Function(String) onWarning;

  const _EnrollStudentDialog({
    required this.groupId,
    required this.onEnrolled,
    required this.onError,
    required this.onWarning,
  });

  @override
  State<_EnrollStudentDialog> createState() => _EnrollStudentDialogState();
}

class _EnrollStudentDialogState extends State<_EnrollStudentDialog> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _loading = true;
  List<StudentModel> _availableStudents = [];
  Set<int> _enrolledStudentIds = {};

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final (allStudents, failure) =
        await getIt<StudentRepository>().getAll();
    final (enrollments, _) =
        await getIt<EnrollmentRepository>().getGroupStudents(widget.groupId);

    if (failure != null) {
      if (mounted) {
        Navigator.pop(context);
        widget.onError('O\'quvchilarni yuklashda xatolik');
      }
      return;
    }

    _enrolledStudentIds =
        (enrollments ?? []).map((e) => e.studentId).toSet();

    final availableStudents = (allStudents ?? [])
        .where((s) => !_enrolledStudentIds.contains(s.id))
        .toList();

    if (availableStudents.isEmpty) {
      if (mounted) {
        Navigator.pop(context);
        widget.onWarning('Barcha o\'quvchilar allaqachon ro\'yxatdan o\'tgan');
      }
      return;
    }

    if (mounted) {
      setState(() {
        _availableStudents = availableStudents;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<StudentModel> get _filteredStudents {
    if (_searchQuery.isEmpty) return _availableStudents;
    return _availableStudents
        .where((s) =>
            s.fullName.toLowerCase().contains(_searchQuery) ||
            s.parentName.toLowerCase().contains(_searchQuery) ||
            s.parentPhoneNumber.contains(_searchQuery))
        .toList();
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
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.person_add_rounded,
                        color: AppColors.success),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'O\'quvchi qo\'shish',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            if (_loading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.success),
                ),
              )
            else ...[
              Padding(
                padding: const EdgeInsets.all(20),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) =>
                      setState(() => _searchQuery = value.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Ism bo\'yicha qidirish...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                  ),
                ),
              ),
              Flexible(
                child: _filteredStudents.isEmpty
                    ? const Center(child: Text('O\'quvchi topilmadi'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shrinkWrap: true,
                        itemCount: _filteredStudents.length,
                        itemBuilder: (context, index) {
                          final student = _filteredStudents[index];
                          return ListTile(
                            title: Text(student.fullName),
                            subtitle: Text(student.parentPhoneNumber),
                            onTap: () async {
                              Navigator.pop(context);
                              await getIt<EnrollmentRepository>()
                                  .addStudentToGroup(
                                student.id,
                                widget.groupId,
                              );
                              widget.onEnrolled();
                            },
                          );
                        },
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Davomat Tab ─────────────────────────────────────────────────────────────

class _DavomatTab extends StatefulWidget {
  final AttendanceBloc bloc;
  final int groupId;
  final int year;
  final int month;

  const _DavomatTab({
    required this.bloc,
    required this.groupId,
    required this.year,
    required this.month,
  });

  @override
  State<_DavomatTab> createState() => _DavomatTabState();
}

class _DavomatTabState extends State<_DavomatTab> {
  @override
  void didUpdateWidget(_DavomatTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.year != widget.year || oldWidget.month != widget.month) {
      widget.bloc.add(AttendanceLoadByGroupAndMonth(
        groupId: widget.groupId,
        year: widget.year,
        month: widget.month,
      ));
    }
  }

  void _showDetailSheet(BuildContext context, String dateKey, List<AttendanceModel> records) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: widget.bloc,
        child: _AttendanceDetailSheet(dateKey: dateKey, records: records),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.bloc,
      child: BlocBuilder<AttendanceBloc, AttendanceState>(
        builder: (context, state) {
          if (state is AttendanceLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0891B2)),
            );
          }

          if (state is AttendanceLoaded) {
            if (state.attendances.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0891B2).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.fact_check_outlined, size: 48, color: Color(0xFF0891B2)),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Davomat olinmagan',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.neutral700,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bu oy uchun davomat hali olinmagan',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.neutral500,
                          ),
                    ),
                  ],
                ),
              );
            }

            // Group records by date string
            final Map<String, List<AttendanceModel>> byDate = {};
            for (final r in state.attendances) {
              final key =
                  '${r.date.year}-${r.date.month.toString().padLeft(2, '0')}-${r.date.day.toString().padLeft(2, '0')}';
              byDate.putIfAbsent(key, () => []).add(r);
            }
            final sortedKeys = byDate.keys.toList()..sort((a, b) => b.compareTo(a));

            return RefreshIndicator(
              color: const Color(0xFF0891B2),
              onRefresh: () async {
                widget.bloc.add(AttendanceLoadByGroupAndMonth(
                  groupId: widget.groupId,
                  year: widget.year,
                  month: widget.month,
                ));
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: sortedKeys.length,
                itemBuilder: (context, index) {
                  final key = sortedKeys[index];
                  final records = byDate[key]!;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _DateAttendanceCard(
                      dateKey: key,
                      records: records,
                      onTap: () => _showDetailSheet(context, key, records),
                    ),
                  );
                },
              ),
            );
          }

          if (state is AttendanceError) {
            return Center(
              child: Text(state.message,
                  style: TextStyle(color: AppColors.error)),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ─── Date Attendance Card ─────────────────────────────────────────────────────

class _DateAttendanceCard extends StatelessWidget {
  final String dateKey;
  final List<AttendanceModel> records;
  final VoidCallback onTap;

  const _DateAttendanceCard({
    required this.dateKey,
    required this.records,
    required this.onTap,
  });

  String _formatDate(String key) {
    final parts = key.split('-');
    final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    const days = ['Dushanba', 'Seshanba', 'Chorshanba', 'Payshanba', 'Juma', 'Shanba', 'Yakshanba'];
    const months = ['Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun', 'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr'];
    return '${date.day} ${months[date.month - 1]}, ${days[date.weekday - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final presentCount = records.where((r) => r.status == AttendanceStatus.PRESENT).length;
    final absentCount = records.where((r) => r.status == AttendanceStatus.ABSENT).length;
    final total = records.length;

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
                decoration: BoxDecoration(
                  color: const Color(0xFF0891B2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(child: Icon(Icons.fact_check_rounded, color: Color(0xFF0891B2))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(dateKey),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _StatusBadge(count: presentCount, total: total, isPresent: true),
                        const SizedBox(width: 8),
                        _StatusBadge(count: absentCount, total: total, isPresent: false),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.neutral400),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final int count;
  final int total;
  final bool isPresent;

  const _StatusBadge({required this.count, required this.total, required this.isPresent});

  @override
  Widget build(BuildContext context) {
    final color = isPresent ? AppColors.success : AppColors.error;
    final bg = isPresent ? AppColors.successLight : AppColors.errorLight;
    final icon = isPresent ? Icons.check_circle_rounded : Icons.cancel_rounded;
    final label = isPresent ? 'Keldi' : 'Kelmadi';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text('$count $label', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

// ─── Take Attendance Sheet ────────────────────────────────────────────────────

class _TakeAttendanceSheet extends StatefulWidget {
  final int groupId;
  final String groupName;
  final DateTime initialDate;
  final List<StudentModel> students;

  const _TakeAttendanceSheet({
    required this.groupId,
    required this.groupName,
    required this.initialDate,
    required this.students,
  });

  @override
  State<_TakeAttendanceSheet> createState() => _TakeAttendanceSheetState();
}

class _TakeAttendanceSheetState extends State<_TakeAttendanceSheet> {
  late DateTime _selectedDate;
  late final Map<int, StudentModel> _studentMap;
  List<EnrollmentModel> _enrollments = [];
  final Set<int> _absentIds = {};
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _studentMap = {for (final s in widget.students) s.id: s};
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final (enrollments, _) = await getIt<EnrollmentRepository>().getGroupStudents(widget.groupId);
    if (mounted) {
      setState(() {
        _enrollments = (enrollments ?? []).where((e) => e.active).toList();
        _loading = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  String _formatSelectedDate() {
    const months = ['Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun', 'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr'];
    return '${_selectedDate.day} ${months[_selectedDate.month - 1]} ${_selectedDate.year}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AttendanceBloc, AttendanceState>(
      listener: (context, state) {
        if (state is AttendanceActionSuccess) {
          Navigator.pop(context);
        } else if (state is AttendanceLoaded && _submitting) {
          Navigator.pop(context);
        } else if (state is AttendanceError && _submitting) {
          setState(() => _submitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.neutral300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: const Color(0xFF0891B2).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.edit_calendar_rounded, color: Color(0xFF0891B2)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('Davomat olish', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0891B2).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF0891B2).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFF0891B2)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(_formatSelectedDate(),
                              style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0891B2))),
                        ),
                        const Icon(Icons.edit_rounded, size: 16, color: Color(0xFF0891B2)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text('Barcha o\'quvchilar', style: TextStyle(fontSize: 13, color: AppColors.neutral500)),
                    const Spacer(),
                    if (!_loading)
                      Text('${_enrollments.length - _absentIds.length} / ${_enrollments.length} keldi',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0891B2))),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              const Divider(height: 1),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF0891B2)))
                    : _enrollments.isEmpty
                        ? Center(child: Text('Bu guruhda o\'quvchi yo\'q', style: TextStyle(color: AppColors.neutral500)))
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: _enrollments.length,
                            itemBuilder: (context, index) {
                              final enrollment = _enrollments[index];
                              final isAbsent = _absentIds.contains(enrollment.studentId);
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isAbsent ? AppColors.errorLight : AppColors.successLight,
                                  child: Text(
                                    enrollment.studentName.isNotEmpty ? enrollment.studentName[0].toUpperCase() : '?',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: isAbsent ? AppColors.error : AppColors.success,
                                    ),
                                  ),
                                ),
                                title: Text(enrollment.studentName, style: const TextStyle(fontWeight: FontWeight.w500)),
                                trailing: GestureDetector(
                                  onTap: () {
                                    if (isAbsent) {
                                      setState(() => _absentIds.remove(enrollment.studentId));
                                    } else {
                                      setState(() => _absentIds.add(enrollment.studentId));
                                      final student = _studentMap[enrollment.studentId];
                                      if (student != null) {
                                        getIt<SmsService>().send(
                                          student.parentPhoneNumber,
                                          "Assalomu alaykum! ${student.fullName} bugun ${_formatSelectedDate()} kuni ${widget.groupName} darsiga kelmadi. Creative O'quv Markazi.",
                                        );
                                      }
                                    }
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isAbsent ? AppColors.errorLight : AppColors.successLight,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(isAbsent ? Icons.close_rounded : Icons.check_rounded,
                                            size: 14, color: isAbsent ? AppColors.error : AppColors.success),
                                        const SizedBox(width: 4),
                                        Text(
                                          isAbsent ? 'Kelmadi' : 'Keldi',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: isAbsent ? AppColors.error : AppColors.success,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
              const Divider(height: 1),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.of(context).viewInsets.bottom),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading || _submitting || _enrollments.isEmpty
                        ? null
                        : () {
                            setState(() => _submitting = true);
                            context.read<AttendanceBloc>().add(AttendanceCreate(
                              groupId: widget.groupId,
                              date: _selectedDate,
                              absentStudentIds: _absentIds.toList(),
                            ));
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0891B2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _submitting
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Saqlash', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Attendance Detail Sheet ──────────────────────────────────────────────────

class _AttendanceDetailSheet extends StatelessWidget {
  final String dateKey;
  final List<AttendanceModel> records;

  const _AttendanceDetailSheet({required this.dateKey, required this.records});

  String _formatDate() {
    final parts = dateKey.split('-');
    final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    const days = ['Dushanba', 'Seshanba', 'Chorshanba', 'Payshanba', 'Juma', 'Shanba', 'Yakshanba'];
    const months = ['Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun', 'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr'];
    return '${date.day} ${months[date.month - 1]} ${date.year}, ${days[date.weekday - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final presentCount = records.where((r) => r.status == AttendanceStatus.PRESENT).length;
    final absentCount = records.where((r) => r.status == AttendanceStatus.ABSENT).length;

    return BlocListener<AttendanceBloc, AttendanceState>(
      listener: (context, state) {
        if (state is AttendanceError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.neutral300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: const Color(0xFF0891B2).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.fact_check_rounded, color: Color(0xFF0891B2)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_formatDate(), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            _StatusBadge(count: presentCount, total: records.length, isPresent: true),
                            const SizedBox(width: 6),
                            _StatusBadge(count: absentCount, total: records.length, isPresent: false),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            BlocBuilder<AttendanceBloc, AttendanceState>(
              builder: (context, state) {
                final currentRecords = state is AttendanceLoaded
                    ? state.attendances.where((a) {
                        final key =
                            '${a.date.year}-${a.date.month.toString().padLeft(2, '0')}-${a.date.day.toString().padLeft(2, '0')}';
                        return key == dateKey;
                      }).toList()
                    : records;

                return ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: currentRecords.length,
                    itemBuilder: (context, index) {
                      final record = currentRecords[index];
                      final isPresent = record.status == AttendanceStatus.PRESENT;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isPresent ? AppColors.successLight : AppColors.errorLight,
                          child: Text(
                            record.studentName.isNotEmpty ? record.studentName[0].toUpperCase() : '?',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: isPresent ? AppColors.success : AppColors.error,
                            ),
                          ),
                        ),
                        title: Text(record.studentName, style: const TextStyle(fontWeight: FontWeight.w500)),
                        trailing: GestureDetector(
                          onTap: () {
                            context.read<AttendanceBloc>().add(AttendanceUpdateStatus(
                              id: record.id,
                              status: isPresent ? AttendanceStatus.ABSENT : AttendanceStatus.PRESENT,
                            ));
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isPresent ? AppColors.successLight : AppColors.errorLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(isPresent ? Icons.check_rounded : Icons.close_rounded,
                                    size: 14, color: isPresent ? AppColors.success : AppColors.error),
                                const SizedBox(width: 4),
                                Text(
                                  isPresent ? 'Keldi' : 'Kelmadi',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isPresent ? AppColors.success : AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Simple YearMonth picker widget
class YearMonthPicker extends StatefulWidget {
  final DateTime selectedDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onChanged;

  const YearMonthPicker({
    super.key,
    required this.selectedDate,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
  });

  @override
  State<YearMonthPicker> createState() => _YearMonthPickerState();
}

class _YearMonthPickerState extends State<YearMonthPicker> {
  late int _selectedYear;
  late int _selectedMonth;

  static const List<String> _monthNames = [
    'Yan', 'Fev', 'Mar', 'Apr', 'May', 'Iyun',
    'Iyul', 'Avg', 'Sen', 'Okt', 'Noy', 'Dek'
  ];

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.selectedDate.year;
    _selectedMonth = widget.selectedDate.month;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Year selector
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _selectedYear > widget.firstDate.year
                  ? () => setState(() => _selectedYear--)
                  : null,
            ),
            Text(
              '$_selectedYear',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _selectedYear < widget.lastDate.year
                  ? () => setState(() => _selectedYear++)
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Month grid
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              final month = index + 1;
              final isSelected =
                  month == _selectedMonth && _selectedYear == widget.selectedDate.year;
              return InkWell(
                onTap: () {
                  widget.onChanged(DateTime(_selectedYear, month));
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.neutral100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      _monthNames[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.neutral700,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
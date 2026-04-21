import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../attendance/presentation/bloc/attendance_bloc.dart';
import '../../../attendance/presentation/sheets/take_attendance_sheet.dart';
import '../../../enrollments/data/repositories/enrollment_repository.dart';
import '../../../payments/presentation/bloc/payment_bloc.dart';
import '../../../payments/presentation/dialogs/payment_form_dialog.dart';
import '../../../students/data/models/student_model.dart';
import '../../data/models/group_model.dart';
import '../../data/repositories/group_repository.dart';
import '../dialogs/enroll_student_dialog.dart';
import '../widgets/group_stat_item.dart';
import '../widgets/year_month_picker.dart';
import 'tabs/group_attendance_tab.dart';
import 'tabs/group_payments_tab.dart';
import 'tabs/group_students_tab.dart';

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
  bool _loading = true;
  int _studentsRefreshKey = 0;
  int _paymentsRefreshKey = 0;
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _selectedMonth = DateTime.now();
    _attendanceBloc = getIt<AttendanceBloc>();
    _loadGroupData();
  }

  Future<void> _loadGroupData() async {
    setState(() => _loading = true);
    final (group, _) = await getIt<GroupRepository>().getById(widget.groupId);
    if (mounted) {
      setState(() {
        _group = group;
        _loading = false;
      });
      _attendanceBloc.add(AttendanceLoadByGroupAndMonth(
        groupId: widget.groupId,
        year: _selectedMonth.year,
        month: _selectedMonth.month,
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

  void _showMonthPicker() {
    final now = DateTime.now();
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
                  Text('Oy tanlang',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: YearMonthPicker(
                  selectedDate: _selectedMonth,
                  firstDate: DateTime(2020, 1),
                  lastDate: DateTime(now.year + 1, 12),
                  onChanged: (date) {
                    Navigator.pop(context);
                    setState(() => _selectedMonth = date);
                    _attendanceBloc.add(AttendanceLoadByGroupAndMonth(
                      groupId: widget.groupId,
                      year: date.year,
                      month: date.month,
                    ));
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

  void _confirmRemoveStudent(StudentModel student) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('O\'quvchini chiqarish'),
        content: Text('${student.fullName} guruhdan chiqarilsinmi?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Bekor qilish')),
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
                setState(() => _studentsRefreshKey++);
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
        child: TakeAttendanceSheet(
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
      builder: (dialogContext) => EnrollStudentDialog(
        groupId: widget.groupId,
        onEnrolled: () => setState(() => _studentsRefreshKey++),
        onError: (message) =>
            _showSnackBar(message, AppColors.error, Icons.error_outline),
        onWarning: (message) =>
            _showSnackBar(message, AppColors.warning, Icons.info_outline),
      ),
    );
  }

  void _showAddPaymentDialog() {
    if (_students.isEmpty) {
      _showSnackBar(
          'Bu guruhda o\'quvchilar yo\'q', AppColors.warning, Icons.info_outline);
      return;
    }
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider(
        create: (_) => getIt<PaymentBloc>(),
        child: PaymentFormDialog(preselectedGroupId: widget.groupId),
      ),
    ).then((_) => setState(() => _paymentsRefreshKey++));
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
                      color: AppColors.neutral700,
                      fontWeight: FontWeight.w600)),
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
                                          color: Colors.white.withOpacity(0.8)),
                                      const SizedBox(width: 6),
                                      Text(_group!.teacherName,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color:
                                                  Colors.white.withOpacity(0.9))),
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
                            GroupStatItem(
                                icon: Icons.people_rounded,
                                value: '${_group!.studentsCount}',
                                label: 'O\'quvchi'),
                            const SizedBox(width: 24),
                            GroupStatItem(
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
                    Tab(
                        text: 'O\'quvchilar',
                        icon: Icon(Icons.people_rounded, size: 20)),
                    Tab(
                        text: 'To\'lovlar',
                        icon: Icon(Icons.payment_rounded, size: 20)),
                    Tab(
                        text: 'Davomat',
                        icon: Icon(Icons.fact_check_rounded, size: 20)),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: Column(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                border: Border(
                    bottom: BorderSide(
                        color: AppColors.neutral200.withOpacity(0.5))),
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
                          color: AppColors.neutral700),
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
                            Text('O\'zgartirish',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary)),
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
                  GroupStudentsTab(
                    key: ValueKey(
                        'students_${_studentsRefreshKey}_${_selectedMonth.year}_${_selectedMonth.month}'),
                    groupId: widget.groupId,
                    year: _selectedMonth.year,
                    month: _selectedMonth.month,
                    onStudentsLoaded: (students) {
                      if (mounted) setState(() => _students = students);
                    },
                    onRemoveStudent: _confirmRemoveStudent,
                  ),
                  GroupPaymentsTab(
                    key: ValueKey(
                        'payments_${_paymentsRefreshKey}_${_selectedMonth.year}_${_selectedMonth.month}'),
                    groupId: widget.groupId,
                    year: _selectedMonth.year,
                    month: _selectedMonth.month,
                  ),
                  GroupAttendanceTab(
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
}

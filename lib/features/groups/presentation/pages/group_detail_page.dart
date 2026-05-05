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
import '../bloc/enroll_student_cubit.dart';
import '../bloc/group_detail_cubit.dart';
import '../bloc/group_payments_cubit.dart';
import '../bloc/group_students_cubit.dart';
import '../bloc/transfer_student_cubit.dart';
import '../dialogs/enroll_student_dialog.dart';
import '../dialogs/transfer_student_dialog.dart';
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
  late final TabController _tabController;
  late final GroupDetailCubit _detailCubit;
  late final GroupStudentsCubit _studentsCubit;
  late final GroupPaymentsCubit _paymentsCubit;
  late final AttendanceBloc _attendanceBloc;
  late final EnrollStudentCubit _enrollStudentCubit;
  late final TransferStudentCubit _transferStudentCubit;

  bool _isTransferMode = false;
  final Set<int> _selectedStudentIds = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(() => setState(() {}));
    _attendanceBloc = getIt<AttendanceBloc>();
    _detailCubit = GroupDetailCubit(
      groupRepository: getIt(),
      attendanceBloc: _attendanceBloc,
      groupId: widget.groupId,
    );
    _studentsCubit = GroupStudentsCubit(getIt());
    _paymentsCubit = GroupPaymentsCubit(getIt());
    _enrollStudentCubit = EnrollStudentCubit(
      studentRepo: getIt(),
      enrollmentRepo: getIt(),
      enrollmentLocal: getIt(),
      groupId: widget.groupId,
    );
    _transferStudentCubit = TransferStudentCubit(
      groupRepository: getIt(),
      enrollmentRepository: getIt(),
      currentGroupId: widget.groupId,
    );
    _detailCubit.loadGroup();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _detailCubit.close();
    _studentsCubit.close();
    _paymentsCubit.close();
    _attendanceBloc.close();
    _enrollStudentCubit.close();
    _transferStudentCubit.close();
    super.dispose();
  }

  void _enterTransferMode() => setState(() {
        _isTransferMode = true;
        _selectedStudentIds.clear();
      });

  void _exitTransferMode() => setState(() {
        _isTransferMode = false;
        _selectedStudentIds.clear();
      });

  void _toggleSelection(int studentId) => setState(() {
        if (_selectedStudentIds.contains(studentId)) {
          _selectedStudentIds.remove(studentId);
        } else {
          _selectedStudentIds.add(studentId);
        }
      });

  void _showTransferDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: _transferStudentCubit,
        child: TransferStudentDialog(
          studentIds: _selectedStudentIds.toList(),
          onSuccess: () {
            _exitTransferMode();
            _studentsCubit.reload();
            _showSnackBar(
              'O\'quvchilar muvaffaqiyatli o\'tkazildi',
              AppColors.success,
              Icons.check_circle_outline,
            );
          },
          onError: (message) =>
              _showSnackBar(message, AppColors.error, Icons.error_outline),
        ),
      ),
    );
  }

  void _showSnackBar(String message, Color backgroundColor, IconData icon) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ]),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showMonthPicker(DateTime selectedMonth) {
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
                  selectedDate: selectedMonth,
                  firstDate: DateTime(2020, 1),
                  lastDate: DateTime(now.year + 1, 12),
                  onChanged: (date) {
                    Navigator.pop(context);
                    _detailCubit.selectMonth(date);
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
      'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr',
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
                _studentsCubit.reload();
              }
            },
            child: const Text('Chiqarish'),
          ),
        ],
      ),
    );
  }

  void _showTakeAttendanceSheet(GroupDetailLoaded state) {
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (ctx) => BlocProvider.value(
        value: _attendanceBloc,
        child: TakeAttendanceSheet(
          groupId: widget.groupId,
          initialDate: state.selectedMonth,
          students: _studentsCubit.students,
        ),
      ),
    );
  }

  void _showEnrollStudentDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: _enrollStudentCubit,
        child: EnrollStudentDialog(
          onEnrolled: () {
            _studentsCubit.reload();
            _showSnackBar("O'quvchi muvaffaqiyatli qo'shildi",
                AppColors.success, Icons.check_circle_outline);
          },
          onError: (message) =>
              _showSnackBar(message, AppColors.error, Icons.error_outline),
        ),
      ),
    );
  }

  void _showAddPaymentDialog() {
    if (_studentsCubit.students.isEmpty) {
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
    ).then((saved) { if (saved == true) _paymentsCubit.reload(); });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _detailCubit),
        BlocProvider.value(value: _studentsCubit),
        BlocProvider.value(value: _paymentsCubit),
        BlocProvider.value(value: _attendanceBloc),
        BlocProvider.value(value: _enrollStudentCubit),
        BlocProvider.value(value: _transferStudentCubit),
      ],
      child: BlocListener<GroupDetailCubit, GroupDetailState>(
        listenWhen: (prev, curr) {
          if (curr is! GroupDetailLoaded) return false;
          if (prev is! GroupDetailLoaded) return true;
          return prev.selectedMonth != curr.selectedMonth;
        },
        listener: (context, state) {
          final loaded = state as GroupDetailLoaded;
          _studentsCubit.load(
            groupId: widget.groupId,
            year: loaded.selectedMonth.year,
            month: loaded.selectedMonth.month,
          );
          _paymentsCubit.load(
            groupId: widget.groupId,
            year: loaded.selectedMonth.year,
            month: loaded.selectedMonth.month,
          );
        },
        child: BlocBuilder<GroupDetailCubit, GroupDetailState>(
          builder: (context, state) {
            if (state is GroupDetailLoading) return _buildLoadingScaffold();
            if (state is GroupDetailError) return _buildErrorScaffold();
            if (state is GroupDetailLoaded) return _buildScaffold(state);
            return _buildLoadingScaffold();
          },
        ),
      ),
    );
  }

  Widget _buildLoadingScaffold() {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }

  Widget _buildErrorScaffold() {
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

  Widget _buildScaffold(GroupDetailLoaded state) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 12,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
              ),
              child: Center(
                child: Text(
                  state.group.name.isNotEmpty
                      ? state.group.name[0].toUpperCase()
                      : 'G',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.group.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: AppColors.neutral900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    state.group.teacherName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.neutral600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (_tabController.index == 0 && !_isTransferMode)
            IconButton(
              onPressed: _enterTransferMode,
              icon: const Icon(Icons.swap_horiz_rounded),
              splashRadius: 22,
              tooltip: 'O\'tkazish',
            ),
          if (_isTransferMode) ...[
            if (_selectedStudentIds.isNotEmpty)
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_selectedStudentIds.length} ta',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        fontSize: 13),
                  ),
                ),
              ),
            TextButton(
              onPressed: _exitTransferMode,
              child: const Text('Bekor qilish',
                  style: TextStyle(color: AppColors.error)),
            ),
          ],
          if (!_isTransferMode)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_vert_rounded),
                splashRadius: 22,
                tooltip: 'Boshqa',
              ),
            ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: Container(
              height: 40,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.neutral200),
              ),
              child: TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.neutral500,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                tabs: const [
                  Tab(text: 'O\'quvchilar'),
                  Tab(text: 'Davomat'),
                  Tab(text: 'To\'lovlar'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              border: Border(
                  bottom: BorderSide(
                      color: AppColors.neutral200.withValues(alpha: 0.5))),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_month_rounded,
                    size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_getMonthName(state.selectedMonth.month).toUpperCase()} ${state.selectedMonth.year}',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral700),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showMonthPicker(state.selectedMonth),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
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
                  groupId: widget.groupId,
                  onRemoveStudent: _confirmRemoveStudent,
                  isTransferMode: _isTransferMode,
                  selectedStudentIds: _selectedStudentIds,
                  onToggleSelection: _toggleSelection,
                ),
                GroupAttendanceTab(
                  bloc: _attendanceBloc,
                  groupId: widget.groupId,
                  year: state.selectedMonth.year,
                  month: state.selectedMonth.month,
                ),
                const GroupPaymentsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _isTransferMode
          ? FloatingActionButton.extended(
              onPressed: _selectedStudentIds.isEmpty ? null : _showTransferDialog,
              backgroundColor: _selectedStudentIds.isEmpty
                  ? AppColors.neutral300
                  : AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              icon: const Icon(Icons.swap_horiz_rounded),
              label: Text(
                _selectedStudentIds.isEmpty
                    ? 'O\'quvchi tanlang'
                    : '${_selectedStudentIds.length} ta o\'quvchini o\'tkazish',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            )
          : FloatingActionButton.extended(
              onPressed: () {
                if (_tabController.index == 0) {
                  _showEnrollStudentDialog();
                } else if (_tabController.index == 1) {
                  _showTakeAttendanceSheet(state);
                } else {
                  _showAddPaymentDialog();
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
                      ? Icons.edit_calendar_rounded
                      : Icons.add_card_rounded),
              label: Text(
                _tabController.index == 0
                    ? 'O\'quvchi qo\'shish'
                    : _tabController.index == 1
                        ? 'Davomat olish'
                        : 'To\'lov qo\'shish',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
    );
  }
}

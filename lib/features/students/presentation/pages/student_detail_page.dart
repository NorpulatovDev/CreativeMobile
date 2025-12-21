import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/routes.dart';
import '../../../attendance/data/models/attendance_model.dart';
import '../../../attendance/data/repositories/attendance_repository.dart';
import '../../../enrollments/data/models/enrollment_model.dart';
import '../../../enrollments/data/repositories/enrollment_repository.dart';
import '../../../groups/data/models/group_model.dart';
import '../../../groups/data/repositories/group_repository.dart';
import '../../../payments/data/models/payment_model.dart';
import '../../../payments/data/repositories/payment_repository.dart';
import '../../../payments/presentation/pages/payments_page.dart';
import '../../data/models/student_model.dart';
import '../../data/repositories/student_repository.dart';

class StudentDetailPage extends StatefulWidget {
  final int studentId;

  const StudentDetailPage({super.key, required this.studentId});

  @override
  State<StudentDetailPage> createState() => _StudentDetailPageState();
}

class _StudentDetailPageState extends State<StudentDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  StudentModel? _student;
  List<EnrollmentModel> _enrollments = [];
  List<PaymentModel> _payments = [];
  List<AttendanceModel> _attendances = [];
  List<GroupModel> _allGroups = [];
  bool _loading = true;

  // For attendance calendar
  DateTime _selectedMonth = DateTime.now();
  DateTime? _selectedDay;
  bool _loadingAttendance = false;
  int? _selectedGroupId; // null means all groups

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final (student, _) =
        await getIt<StudentRepository>().getById(widget.studentId);
    final (enrollments, _) =
        await getIt<EnrollmentRepository>().getStudentGroups(widget.studentId);
    final (payments, _) =
        await getIt<PaymentRepository>().getByStudentId(widget.studentId);
    final (groups, _) = await getIt<GroupRepository>().getAll();

    // Load attendance for selected month
    final (attendances, _) = await getIt<AttendanceRepository>()
        .getByStudentIdAndMonth(
            widget.studentId, _selectedMonth.year, _selectedMonth.month);

    if (mounted) {
      setState(() {
        _student = student;
        _enrollments = enrollments ?? [];
        _payments = payments ?? [];
        _attendances = attendances ?? [];
        _allGroups = groups ?? [];
        _loading = false;
      });
    }
  }

  Future<void> _loadAttendanceForMonth(DateTime month, {int? groupId}) async {
    setState(() {
      _selectedMonth = month;
      _loadingAttendance = true;
      if (groupId != null || groupId != _selectedGroupId) {
        _selectedGroupId = groupId;
      }
    });

    final (attendances, _) = _selectedGroupId != null
        ? await getIt<AttendanceRepository>().getByStudentIdAndGroupIdAndMonth(
            widget.studentId, _selectedGroupId!, month.year, month.month)
        : await getIt<AttendanceRepository>()
            .getByStudentIdAndMonth(widget.studentId, month.year, month.month);

    if (mounted) {
      setState(() {
        _attendances = attendances ?? [];
        _loadingAttendance = false;
      });
    }
  }

  void _onGroupFilterChanged(int? groupId) {
    _loadAttendanceForMonth(_selectedMonth, groupId: groupId);
  }

  Map<DateTime, List<AttendanceModel>> _getAttendanceMap() {
    final map = <DateTime, List<AttendanceModel>>{};
    for (final attendance in _attendances) {
      final key = DateTime(
        attendance.date.year,
        attendance.date.month,
        attendance.date.day,
      );
      if (map[key] == null) {
        map[key] = [];
      }
      map[key]!.add(attendance);
    }
    return map;
  }

  List<AttendanceModel> _getAttendanceForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _getAttendanceMap()[key] ?? [];
  }

  bool _hasAnyAbsence(DateTime day) {
    final attendances = _getAttendanceForDay(day);
    if (attendances.isEmpty) return false;
    return attendances.any((a) => a.status == AttendanceStatus.ABSENT);
  }

  bool _hasAttendance(DateTime day) {
    final attendances = _getAttendanceForDay(day);
    return attendances.isNotEmpty;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_student == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Student not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_student!.fullName),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Groups', icon: Icon(Icons.groups)),
            Tab(text: 'Payments', icon: Icon(Icons.payment)),
            Tab(text: 'Attendance', icon: Icon(Icons.fact_check)),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildStudentInfo(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGroupsTab(),
                _buildPaymentsTab(),
                _buildAttendanceTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            _showEnrollInGroupDialog();
          } else if (_tabController.index == 1) {
            _showAddPaymentDialog();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStudentInfo() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    _student!.fullName[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 24,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _student!.fullName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.family_restroom,
                            size: 16,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _student!.parentName,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 16,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _student!.parentPhoneNumber,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _InfoColumn(
                  label: 'Groups',
                  value: '${_student!.activeGroupsCount}',
                ),
                _InfoColumn(
                  label: 'Total Paid',
                  value: '${_student!.totalPaid.toStringAsFixed(0)} UZS',
                  color: Theme.of(context).colorScheme.primary,
                ),
                _InfoColumn(
                  label: 'Payments',
                  value: '${_payments.length}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupsTab() {
    final activeEnrollments = _enrollments.where((e) => e.active).toList();
    if (activeEnrollments.isEmpty) {
      return const Center(child: Text('Not enrolled in any groups'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activeEnrollments.length,
      itemBuilder: (context, index) {
        final enrollment = activeEnrollments[index];
        return Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.groups)),
            title: Text(enrollment.groupName),
            subtitle: Text('Teacher: ${enrollment.teacherName}'),
            trailing: Text(
              '${enrollment.monthlyFee.toStringAsFixed(0)} UZS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            onTap: () => context.push('${Routes.groups}/${enrollment.groupId}'),
          ),
        );
      },
    );
  }

  Widget _buildPaymentsTab() {
    if (_payments.isEmpty) {
      return const Center(child: Text('No payments recorded'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _payments.length,
      itemBuilder: (context, index) {
        final payment = _payments[index];
        return Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.payment)),
            title: Text(payment.groupName),
            subtitle: Text('For: ${payment.paidForMonth}'),
            trailing: Text(
              '${payment.amount.toStringAsFixed(0)} UZS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttendanceTab() {
    final presentCount =
        _attendances.where((a) => a.status == AttendanceStatus.PRESENT).length;
    final absentCount =
        _attendances.where((a) => a.status == AttendanceStatus.ABSENT).length;
    final totalRecords = _attendances.length;

    // Get active enrollments for group filter
    final activeEnrollments = _enrollments.where((e) => e.active).toList();

    return Column(
      children: [
        // Group Filter Dropdown
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: DropdownButtonFormField<int?>(
            value: _selectedGroupId,
            decoration: InputDecoration(
              labelText: 'Filter by Group',
              prefixIcon: const Icon(Icons.filter_list),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('All Groups'),
              ),
              ...activeEnrollments.map((enrollment) => DropdownMenuItem<int?>(
                    value: enrollment.groupId,
                    child: Text(enrollment.groupName),
                  )),
            ],
            onChanged: _onGroupFilterChanged,
          ),
        ),

        // Stats Row
        if (totalRecords > 0)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.check_circle,
                    label: 'Present',
                    value: '$presentCount',
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
                    icon: Icons.cancel,
                    label: 'Absent',
                    value: '$absentCount',
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
                    icon: Icons.percent,
                    label: 'Rate',
                    value: totalRecords > 0
                        ? '${(presentCount / totalRecords * 100).toStringAsFixed(0)}%'
                        : '0%',
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

        // Calendar
        Expanded(
          child: _loadingAttendance
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      _CustomCalendar(
                        selectedMonth: _selectedMonth,
                        selectedDay: _selectedDay,
                        onMonthChanged: (month) {
                          _loadAttendanceForMonth(month, groupId: _selectedGroupId);
                        },
                        onDaySelected: (day) {
                          setState(() {
                            _selectedDay = day;
                          });
                        },
                        hasAttendance: _hasAttendance,
                        hasAnyAbsence: _hasAnyAbsence,
                      ),
                      const SizedBox(height: 16),
                      if (_selectedDay != null) _buildSelectedDayInfo(),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSelectedDayInfo() {
    if (_selectedDay == null) return const SizedBox();

    final attendanceForDay = _getAttendanceForDay(_selectedDay!);

    if (attendanceForDay.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.event_busy,
                  size: 48,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  'No attendance records',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  DateFormat('EEEE, dd MMM yyyy').format(_selectedDay!),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text(
              DateFormat('EEEE, dd MMM yyyy').format(_selectedDay!),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ...attendanceForDay.map((attendance) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(
                  attendance.status == AttendanceStatus.PRESENT
                      ? Icons.check_circle
                      : Icons.cancel,
                  color: attendance.status == AttendanceStatus.PRESENT
                      ? Colors.green
                      : Colors.red,
                ),
                title: Text(attendance.groupName),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: attendance.status == AttendanceStatus.PRESENT
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: attendance.status == AttendanceStatus.PRESENT
                          ? Colors.green
                          : Colors.red,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    attendance.status == AttendanceStatus.PRESENT ? 'Present' : 'Absent',
                    style: TextStyle(
                      color: attendance.status == AttendanceStatus.PRESENT
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _showEnrollInGroupDialog() {
    final enrolledGroupIds = _enrollments
        .where((e) => e.active)
        .map((e) => e.groupId)
        .toSet();
    final availableGroups =
        _allGroups.where((g) => !enrolledGroupIds.contains(g.id)).toList();

    if (availableGroups.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Already enrolled in all groups')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Enroll in Group'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableGroups.length,
            itemBuilder: (context, index) {
              final group = availableGroups[index];
              return ListTile(
                title: Text(group.name),
                subtitle: Text('${group.teacherName} • ${group.monthlyFee.toStringAsFixed(0)} UZS'),
                onTap: () async {
                  Navigator.pop(dialogContext);
                  await getIt<EnrollmentRepository>()
                      .addStudentToGroup(widget.studentId, group.id);
                  _loadData();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showAddPaymentDialog() {
    if (_enrollments.where((e) => e.active).isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enrolled in any groups')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => PaymentFormDialog(
        preselectedStudentId: widget.studentId,
      ),
    ).then((_) => _loadData());
  }
}

class _CustomCalendar extends StatelessWidget {
  final DateTime selectedMonth;
  final DateTime? selectedDay;
  final Function(DateTime) onMonthChanged;
  final Function(DateTime) onDaySelected;
  final bool Function(DateTime) hasAttendance;
  final bool Function(DateTime) hasAnyAbsence;

  const _CustomCalendar({
    required this.selectedMonth,
    required this.selectedDay,
    required this.onMonthChanged,
    required this.onDaySelected,
    required this.hasAttendance,
    required this.hasAnyAbsence,
  });

  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final daysInMonth = lastDay.day;

    final startWeekday = firstDay.weekday;
    final leadingDays = startWeekday - 1;

    final days = <DateTime>[];

    // Add leading days from previous month
    for (int i = leadingDays; i > 0; i--) {
      days.add(firstDay.subtract(Duration(days: i)));
    }

    // Add days of current month
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(month.year, month.month, i));
    }

    // Add trailing days to complete the week
    final remainingDays = 7 - (days.length % 7);
    if (remainingDays < 7) {
      for (int i = 1; i <= remainingDays; i++) {
        days.add(lastDay.add(Duration(days: i)));
      }
    }

    return days;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final days = _getDaysInMonth(selectedMonth);
    final today = DateTime.now();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    final prevMonth = DateTime(
                      selectedMonth.year,
                      selectedMonth.month - 1,
                    );
                    onMonthChanged(prevMonth);
                  },
                ),
                Text(
                  DateFormat('MMMM yyyy').format(selectedMonth),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    final nextMonth = DateTime(
                      selectedMonth.year,
                      selectedMonth.month + 1,
                    );
                    onMonthChanged(nextMonth);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Weekday headers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                  .map((day) => SizedBox(
                        width: 40,
                        child: Center(
                          child: Text(
                            day,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            // Days grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: days.length,
              itemBuilder: (context, index) {
                final day = days[index];
                final isCurrentMonth = day.month == selectedMonth.month;
                final isToday = _isSameDay(day, today);
                final isSelected = selectedDay != null && _isSameDay(day, selectedDay!);
                final hasRecord = hasAttendance(day);
                final isAbsent = hasAnyAbsence(day);

                Color? backgroundColor;
                Color? textColor;
                Color? borderColor;

                if (isSelected) {
                  backgroundColor = Theme.of(context).colorScheme.primary;
                  textColor = Theme.of(context).colorScheme.onPrimary;
                } else if (hasRecord && isAbsent) {
                  backgroundColor = Colors.red.withOpacity(0.2);
                  textColor = Colors.red;
                  borderColor = Colors.red;
                } else if (hasRecord && !isAbsent) {
                  backgroundColor = Colors.green.withOpacity(0.2);
                  textColor = Colors.green;
                  borderColor = Colors.green;
                } else if (isToday) {
                  backgroundColor = Theme.of(context).colorScheme.primaryContainer;
                  textColor = Theme.of(context).colorScheme.onPrimaryContainer;
                }

                if (!isCurrentMonth && backgroundColor == null) {
                  textColor = Theme.of(context).colorScheme.outline;
                }

                return GestureDetector(
                  onTap: isCurrentMonth ? () => onDaySelected(day) : null,
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      shape: BoxShape.circle,
                      border: borderColor != null
                          ? Border.all(color: borderColor, width: 2)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: textColor ?? Theme.of(context).colorScheme.onSurface,
                          fontWeight: isToday || isSelected ? FontWeight.bold : null,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendItem(
                  color: Colors.green,
                  label: 'Present',
                ),
                const SizedBox(width: 16),
                _LegendItem(
                  color: Colors.red,
                  label: 'Absent',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _InfoColumn({
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
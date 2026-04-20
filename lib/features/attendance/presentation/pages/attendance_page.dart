import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/sms_service.dart';
import '../../../../core/widgets/sms_permission_gate.dart';
import '../../../enrollments/data/models/enrollment_model.dart';
import '../../../enrollments/data/repositories/enrollment_repository.dart';
import '../../../groups/data/models/group_model.dart';
import '../../../groups/data/repositories/group_repository.dart';
import '../../../students/data/models/student_model.dart';
import '../../../students/data/repositories/student_repository.dart';
import '../../data/models/attendance_model.dart';
import '../bloc/attendance_bloc.dart';

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SmsPermissionGate(
      child: BlocProvider(
        create: (_) => getIt<AttendanceBloc>(),
        child: const AttendanceView(),
      ),
    );
  }
}

class AttendanceView extends StatefulWidget {
  const AttendanceView({super.key});

  @override
  State<AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<AttendanceView> {
  List<GroupModel> _groups = [];
  GroupModel? _selectedGroup;
  final DateTime _today = DateTime.now();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final (groups, _) = await getIt<GroupRepository>().getAll();
    if (mounted) {
      setState(() {
        _groups = groups ?? [];
        _loading = false;
        if (_groups.isNotEmpty) {
          _selectedGroup = _groups.first;
          _loadAttendance();
        }
      });
    }
  }

  void _loadAttendance() {
    if (_selectedGroup != null) {
      context.read<AttendanceBloc>().add(
            AttendanceLoadByGroupAndDate(
              groupId: _selectedGroup!.id,
              date: _today,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Davomat'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _groups.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.groups_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Guruhlar mavjud emas',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      const Text('Avval guruh yarating'),
                    ],
                  ),
                )
              : Column(
                  children: [
                    _buildHeader(),
                    Expanded(child: _buildAttendanceList()),
                  ],
                ),
      floatingActionButton: _buildFab(),
    );
  }

  Widget _buildHeader() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Today's date display (not changeable)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    DateFormat('EEEE, dd MMMM yyyy').format(_today),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<GroupModel>(
              value: _selectedGroup,
              decoration: const InputDecoration(
                labelText: 'Guruh',
                prefixIcon: Icon(Icons.group_outlined),
                border: OutlineInputBorder(),
              ),
              items: _groups
                  .map((g) => DropdownMenuItem(
                        value: g,
                        child: Text('${g.name} (${g.teacherName})'),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedGroup = value);
                _loadAttendance();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildFab() {
    if (_groups.isEmpty || _selectedGroup == null) return null;

    return BlocBuilder<AttendanceBloc, AttendanceState>(
      builder: (context, state) {
        // Hide FAB if attendance already taken for today
        if (state is AttendanceLoaded && state.attendances.isNotEmpty) {
          return const SizedBox.shrink();
        }
        return FloatingActionButton.extended(
          onPressed: () => _showTakeAttendanceDialog(context),
          icon: const Icon(Icons.fact_check),
          label: const Text('Davomat olish'),
        );
      },
    );
  }

  Widget _buildAttendanceList() {
    return BlocConsumer<AttendanceBloc, AttendanceState>(
      listener: (context, state) {
        if (state is AttendanceError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
        if (state is AttendanceActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is AttendanceLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AttendanceLoaded) {
          if (state.attendances.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fact_check_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Davomat olinmagan',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text('Davomat olish tugmasini bosing'),
                ],
              ),
            );
          }
          // Show attendance (read-only, no toggle)
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.attendances.length,
            itemBuilder: (context, index) {
              final attendance = state.attendances[index];
              return _AttendanceCard(attendance: attendance);
            },
          );
        }
        return const Center(child: Text('Guruh tanlang'));
      },
    );
  }

  void _showTakeAttendanceDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<AttendanceBloc>(),
        child: TakeAttendanceDialog(
          groupId: _selectedGroup!.id,
          groupName: _selectedGroup!.name,
          onSuccess: _loadAttendance,
        ),
      ),
    );
  }
}

// Read-only attendance card (no toggle switch)
class _AttendanceCard extends StatelessWidget {
  final AttendanceModel attendance;

  const _AttendanceCard({required this.attendance});

  @override
  Widget build(BuildContext context) {
    final isPresent = attendance.status == AttendanceStatus.PRESENT;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: isPresent
              ? Colors.green.withOpacity(0.2)
              : Colors.red.withOpacity(0.2),
          child: Icon(
            isPresent ? Icons.check : Icons.close,
            color: isPresent ? Colors.green : Colors.red,
            size: 28,
          ),
        ),
        title: Text(
          attendance.studentName,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isPresent
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isPresent ? Colors.green : Colors.red,
            ),
          ),
          child: Text(
            isPresent ? 'Keldi' : 'Kelmadi',
            style: TextStyle(
              color: isPresent ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class TakeAttendanceDialog extends StatefulWidget {
  final int groupId;
  final String groupName;
  final VoidCallback onSuccess;

  const TakeAttendanceDialog({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.onSuccess,
  });

  @override
  State<TakeAttendanceDialog> createState() => _TakeAttendanceDialogState();
}

class _TakeAttendanceDialogState extends State<TakeAttendanceDialog> {
  List<EnrollmentModel> _enrollments = [];
  Map<int, StudentModel> _studentDetails = {};
  Map<int, bool> _attendanceStatus = {};
  final Map<int, bool> _smsSentMap = {};
  final Map<int, bool> _smsSendingMap = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final results = await Future.wait([
      getIt<EnrollmentRepository>().getGroupStudents(widget.groupId),
      getIt<StudentRepository>().getByGroupId(widget.groupId),
    ]);

    final (enrollments, _) = results[0] as (List<EnrollmentModel>?, dynamic);
    final (students, _) = results[1] as (List<StudentModel>?, dynamic);

    final studentDetails = <int, StudentModel>{
      for (final s in students ?? []) s.id: s,
    };
    final attendanceStatus = <int, bool>{
      for (final e in enrollments ?? []) e.studentId: true,
    };

    if (mounted) {
      setState(() {
        _enrollments = enrollments ?? [];
        _studentDetails = studentDetails;
        _attendanceStatus = attendanceStatus;
        _loading = false;
      });
    }
  }

  void _markAbsent(int studentId) {
    setState(() {
      _attendanceStatus[studentId] = false;
      _smsSentMap.remove(studentId);
      _smsSendingMap.remove(studentId);
    });
  }

  void _markPresent(int studentId) {
    setState(() {
      _attendanceStatus[studentId] = true;
      _smsSentMap.remove(studentId);
      _smsSendingMap.remove(studentId);
    });
  }

  Future<void> _sendSms(int studentId) async {
    final student = _studentDetails[studentId];
    if (student == null) return;
    setState(() => _smsSendingMap[studentId] = true);
    final dateStr = DateFormat('dd.MM.yyyy').format(DateTime.now());
    final message =
        "Hurmatli ota-ona,\nCreative O’quv Markazi ma’muriyati sizga ma’lum qiladiki, ${student.fullName} bugun ($dateStr) darsga kelmadi.\nIltimos, kelmaslik sababini bizga ma’lum qilishingizni so’raymiz.";
    await getIt<SmsService>().send(student.parentPhoneNumber, message);
    if (!mounted) return;
    setState(() {
      _smsSendingMap[studentId] = false;
      _smsSentMap[studentId] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return Dialog(
      child: Container(
        width: double.maxFinite,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: 500,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  Text(
                    'Davomat olish',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.groupName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      DateFormat('dd MMMM yyyy').format(today),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: _loading
                  ? const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _enrollments.isEmpty
                      ? const SizedBox(
                          height: 100,
                          child: Center(child: Text('O\'quvchilar yo\'q')),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(16),
                          itemCount: _enrollments.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final enrollment = _enrollments[index];
                            final isPresent =
                                _attendanceStatus[enrollment.studentId] ?? true;
                            final student = _studentDetails[enrollment.studentId];

                            return _StudentAttendanceTile(
                              studentName: enrollment.studentName,
                              parentPhone: student?.parentPhoneNumber ?? '',
                              isPresent: isPresent,
                              smsSent: _smsSentMap[enrollment.studentId] ?? false,
                              smsSending: _smsSendingMap[enrollment.studentId] ?? false,
                              onTap: () {
                                if (isPresent) {
                                  _markAbsent(enrollment.studentId);
                                } else {
                                  _markPresent(enrollment.studentId);
                                }
                              },
                              onSendSms: () => _sendSms(enrollment.studentId),
                            );
                          },
                        ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {} ,
                      onLongPress: () => Navigator.pop(context),
                      child: const Text('Bekor qilish'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        
                      },
                      onLongPress: _enrollments.isEmpty ? null : _submit,
                      child: const Text('Saqlash'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    final absentIds = _attendanceStatus.entries
        .where((e) => e.value == false)
        .map((e) => e.key)
        .toList();

    context.read<AttendanceBloc>().add(AttendanceCreate(
          groupId: widget.groupId,
          date: DateTime.now(),
          absentStudentIds: absentIds,
        ));

    Navigator.pop(context);
    widget.onSuccess();
  }
}

class _StudentAttendanceTile extends StatelessWidget {
  final String studentName;
  final String parentPhone;
  final bool isPresent;
  final bool smsSent;
  final bool smsSending;
  final VoidCallback onTap;
  final VoidCallback? onSendSms;

  const _StudentAttendanceTile({
    required this.studentName,
    required this.parentPhone,
    required this.isPresent,
    required this.smsSent,
    required this.smsSending,
    required this.onTap,
    this.onSendSms,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPresent
          ? Colors.green.withOpacity(0.1)
          : Colors.red.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPresent ? Colors.green : Colors.red,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              // Large status indicator
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isPresent
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isPresent ? Colors.green : Colors.red,
                    width: 3,
                  ),
                ),
                child: Icon(
                  isPresent ? Icons.check : Icons.close,
                  color: isPresent ? Colors.green : Colors.red,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              // Student info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      studentName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      parentPhone,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              if (!isPresent) ...[
                GestureDetector(
                  onTap: smsSent ? null : onSendSms,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: smsSent
                          ? Colors.green.withOpacity(0.12)
                          : Colors.blue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: smsSent
                            ? Colors.green.withOpacity(0.4)
                            : Colors.blue.withOpacity(0.4),
                      ),
                    ),
                    child: smsSending
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                smsSent ? Icons.check_rounded : Icons.sms_outlined,
                                size: 14,
                                color: smsSent ? Colors.green : Colors.blue,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                smsSent ? 'Yuborildi' : 'SMS',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: smsSent ? Colors.green : Colors.blue,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (isPresent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'KELDI',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
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
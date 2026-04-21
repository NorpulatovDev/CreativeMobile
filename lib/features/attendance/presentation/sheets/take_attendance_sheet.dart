import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/sms_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../enrollments/data/models/enrollment_model.dart';
import '../../../enrollments/data/repositories/enrollment_repository.dart';
import '../../../students/data/models/student_model.dart';
import '../bloc/attendance_bloc.dart';

class TakeAttendanceSheet extends StatefulWidget {
  final int groupId;
  final String groupName;
  final DateTime initialDate;
  final List<StudentModel> students;

  const TakeAttendanceSheet({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.initialDate,
    required this.students,
  });

  @override
  State<TakeAttendanceSheet> createState() => _TakeAttendanceSheetState();
}

class _TakeAttendanceSheetState extends State<TakeAttendanceSheet> {
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
    _loadEnrollments();
  }

  Future<void> _loadEnrollments() async {
    final (enrollments, _) =
        await getIt<EnrollmentRepository>().getGroupStudents(widget.groupId);
    if (mounted) {
      setState(() {
        _enrollments =
            (enrollments ?? []).where((e) => e.active).toList();
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

  String _formatDate() {
    const months = [
      'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
      'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr',
    ];
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
            SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error),
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
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.neutral300,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Davomat olish',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        if (widget.groupName.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.groupName,
                            style: TextStyle(
                                fontSize: 14,
                                color: AppColors.neutral500,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.neutral100,
                              borderRadius: BorderRadius.circular(20),
                              border:
                                  Border.all(color: AppColors.neutral200),
                            ),
                            child: Text(
                              _formatDate(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.success))
                    : _enrollments.isEmpty
                        ? Center(
                            child: Text('Bu guruhda o\'quvchi yo\'q',
                                style: TextStyle(
                                    color: AppColors.neutral500)))
                        : ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                            itemCount: _enrollments.length,
                            itemBuilder: (context, index) {
                              final enrollment = _enrollments[index];
                              final isAbsent = _absentIds
                                  .contains(enrollment.studentId);
                              final color = isAbsent
                                  ? AppColors.error
                                  : AppColors.success;
                              final bgColor = isAbsent
                                  ? AppColors.errorLight
                                  : AppColors.successLight;
                              final phone = _studentMap[enrollment.studentId]
                                  ?.parentPhoneNumber;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      if (isAbsent) {
                                        setState(() => _absentIds
                                            .remove(enrollment.studentId));
                                      } else {
                                        setState(() => _absentIds
                                            .add(enrollment.studentId));
                                        final student = _studentMap[
                                            enrollment.studentId];
                                        if (student != null) {
                                          getIt<SmsService>().send(
                                            student.parentPhoneNumber,
                                            "Assalomu alaykum! ${student.fullName} bugun ${_formatDate()} kuni ${widget.groupName} darsiga kelmadi. Creative O'quv Markazi.",
                                          );
                                        }
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(14),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 180),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: bgColor,
                                        borderRadius:
                                            BorderRadius.circular(14),
                                        border: Border.all(
                                            color: color, width: 1.5),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 42,
                                            height: 42,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white,
                                              border: Border.all(
                                                  color: color, width: 2),
                                            ),
                                            child: Icon(
                                              isAbsent
                                                  ? Icons.close_rounded
                                                  : Icons.check_rounded,
                                              color: color,
                                              size: 22,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  enrollment.studentName,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 15,
                                                    color: AppColors.neutral900,
                                                  ),
                                                ),
                                                if (phone != null &&
                                                    phone.isNotEmpty) ...[
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    phone,
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: AppColors
                                                            .neutral500),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: color,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              isAbsent ? 'KELMADI' : 'KELDI',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 12,
                                              ),
                                            ),
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
              const Divider(height: 1),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    20, 12, 20, 12 + MediaQuery.of(context).viewInsets.bottom),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: AppColors.neutral300),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Bekor qilish',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _loading ||
                                _submitting ||
                                _enrollments.isEmpty
                            ? null
                            : () {
                                setState(() => _submitting = true);
                                context.read<AttendanceBloc>().add(
                                      AttendanceCreate(
                                        groupId: widget.groupId,
                                        date: _selectedDate,
                                        absentStudentIds:
                                            _absentIds.toList(),
                                      ),
                                    );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _submitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Saqlash',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16)),
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
}

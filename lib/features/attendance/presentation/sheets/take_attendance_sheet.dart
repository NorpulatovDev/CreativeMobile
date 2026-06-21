import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/sms_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../students/data/models/student_model.dart';
import '../bloc/attendance_bloc.dart';
import '../bloc/take_attendance_sheet_cubit.dart';

class TakeAttendanceSheet extends StatelessWidget {
  final int groupId;
  final DateTime initialDate;
  final List<StudentModel> students;

  const TakeAttendanceSheet({
    super.key,
    required this.groupId,
    required this.initialDate,
    required this.students,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TakeAttendanceSheetCubit(
        enrollmentRepo: getIt(),
        smsService: getIt(),
        groupId: groupId,
        students: students,
      )..load(),
      child: _TakeAttendanceSheetBody(groupId: groupId),
    );
  }
}

class _TakeAttendanceSheetBody extends StatelessWidget {
  final int groupId;

  const _TakeAttendanceSheetBody({required this.groupId});

  void _showSnackBar(BuildContext context, String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Row(children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(message),
        ]),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
  }

  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('SMS ruxsati'),
        content: const Text('SMS yuborish uchun ilova sozlamalarida ruxsat bering.'),
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

  void _handleSmsNotification(BuildContext context, SmsResult result) {
    switch (result) {
      case SmsResult.sent:
        _showSnackBar(context, 'SMS yuborildi', AppColors.success, Icons.check_circle_outline);
      case SmsResult.failed:
        _showSnackBar(context, 'SMS yuborishda xatolik', AppColors.error, Icons.error_outline);
      case SmsResult.permissionDenied:
        _showSnackBar(context, 'SMS ruxsati berilmadi', AppColors.warning, Icons.warning_amber_rounded);
      case SmsResult.permissionPermanentlyDenied:
        _showPermissionDialog(context);
      case SmsResult.notAvailable:
        _showSnackBar(context, 'Bu qurilmada SMS yuborish mumkin emas', AppColors.neutral500, Icons.sms_failed_rounded);
    }
  }

  void _save(BuildContext context, TakeAttendanceSheetReady state) {
    context.read<TakeAttendanceSheetCubit>().startSubmitting();
    context.read<AttendanceBloc>().add(AttendanceCreate(
      groupId: groupId,
      date: state.selectedDate,
      absentStudentIds: state.absentIds.toList(),
    ));
  }

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d.$m.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<TakeAttendanceSheetCubit, TakeAttendanceSheetState>(
          listenWhen: (prev, curr) {
            if (curr is! TakeAttendanceSheetReady || prev is! TakeAttendanceSheetReady) return false;
            return curr.smsNotification != null && curr.smsNotification != prev.smsNotification;
          },
          listener: (context, state) {
            _handleSmsNotification(context, (state as TakeAttendanceSheetReady).smsNotification!);
          },
        ),
        BlocListener<AttendanceBloc, AttendanceState>(
          listener: (context, state) {
            if (state is AttendanceActionSuccess) {
              Navigator.pop(context);
            } else if (state is AttendanceError) {
              context.read<TakeAttendanceSheetCubit>().resetSubmitting();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
        ),
      ],
      child: BlocBuilder<TakeAttendanceSheetCubit, TakeAttendanceSheetState>(
        builder: (context, sheetState) {
          final loading = sheetState is TakeAttendanceSheetLoading;
          final ready = sheetState is TakeAttendanceSheetReady ? sheetState : null;

          return Dialog.fullscreen(
            child: Scaffold(
              backgroundColor: AppColors.backgroundLight,
              appBar: AppBar(
                backgroundColor: AppColors.surfaceLight,
                foregroundColor: AppColors.neutral900,
                elevation: 0,
                scrolledUnderElevation: 0,
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Column(
                  children: [
                    const Text(
                      'Davomat olish',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: AppColors.neutral900),
                    ),
                    const SizedBox(height: 2),
                    GestureDetector(
                      onTap: ready == null
                          ? null
                          : () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: ready.selectedDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null && context.mounted) {
                                context.read<TakeAttendanceSheetCubit>().setDate(picked);
                              }
                            },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.neutral100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.neutral200),
                        ),
                        child: Text(
                          ready != null ? _formatDate(ready.selectedDate) : '--.--.----',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.neutral700),
                        ),
                      ),
                    ),
                  ],
                ),
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              body: loading || ready == null
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.success))
                  : ready.enrollments.isEmpty
                      ? Center(
                          child: Text(
                            'Bu guruhda o\'quvchi yo\'q',
                            style: TextStyle(color: AppColors.neutral500),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                          itemCount: ready.enrollments.length,
                          itemBuilder: (context, index) {
                            final enrollment = ready.enrollments[index];
                            final isAbsent = ready.absentIds.contains(enrollment.studentId);
                            final color = isAbsent ? AppColors.error : AppColors.success;
                            final bgColor = isAbsent ? AppColors.errorLight : AppColors.successLight;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => context
                                      .read<TakeAttendanceSheetCubit>()
                                      .toggleAbsent(enrollment.studentId),
                                  borderRadius: BorderRadius.circular(14),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: bgColor,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: color, width: 1.5),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 42,
                                          height: 42,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white,
                                            border: Border.all(color: color, width: 2),
                                          ),
                                          child: Icon(
                                            isAbsent ? Icons.close_rounded : Icons.check_rounded,
                                            color: color,
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            enrollment.studentName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                              color: AppColors.neutral900,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        if (isAbsent)
                                          _SmsButton(
                                            studentId: enrollment.studentId,
                                            sending: ready.smsSendingIds.contains(enrollment.studentId),
                                            sent: ready.smsSentIds.contains(enrollment.studentId),
                                          )
                                        else
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: color,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: const Text(
                                              'KELDI',
                                              style: TextStyle(
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
              bottomNavigationBar: Container(
                padding: EdgeInsets.fromLTRB(
                    20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  border: Border(
                      top: BorderSide(
                          color: AppColors.neutral200.withValues(alpha: 0.5))),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _LongPressButton(
                            label: 'Bekor qilish',
                            filled: false,
                            onLongPress: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _LongPressButton(
                            label: ready?.submitting == true ? null : 'Saqlash',
                            filled: true,
                            enabled: ready != null &&
                                !ready.submitting &&
                                ready.enrollments.isNotEmpty,
                            onLongPress: ready == null ||
                                    ready.submitting ||
                                    ready.enrollments.isEmpty
                                ? null
                                : () => _save(context, ready),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Saqlash yoki bekor qilish uchun bosib turing',
                      style: TextStyle(fontSize: 11, color: AppColors.neutral400),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SmsButton extends StatelessWidget {
  final int studentId;
  final bool sending;
  final bool sent;

  const _SmsButton({
    required this.studentId,
    required this.sending,
    required this.sent,
  });

  @override
  Widget build(BuildContext context) {
    final color = sent ? AppColors.success : AppColors.primary;
    return GestureDetector(
      onTap: sending
          ? null
          : () => context.read<TakeAttendanceSheetCubit>().sendSms(studentId),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: sent
              ? AppColors.successLight
              : AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: sending
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primary),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    sent ? Icons.check_rounded : Icons.sms_rounded,
                    size: 16,
                    color: color,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    sent ? 'YUBORILDI' : 'SMS',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _LongPressButton extends StatefulWidget {
  final String? label;
  final bool filled;
  final bool enabled;
  final VoidCallback? onLongPress;

  const _LongPressButton({
    required this.label,
    required this.filled,
    this.enabled = true,
    this.onLongPress,
  });

  @override
  State<_LongPressButton> createState() => _LongPressButtonState();
}

class _LongPressButtonState extends State<_LongPressButton> {
  bool _pressing = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.enabled && widget.onLongPress != null;
    final bg = widget.filled
        ? (active ? AppColors.primary : AppColors.neutral200)
        : Colors.transparent;
    final fg = widget.filled
        ? Colors.white
        : (active ? AppColors.neutral700 : AppColors.neutral400);
    final border = widget.filled
        ? BorderSide.none
        : BorderSide(color: active ? AppColors.neutral300 : AppColors.neutral200);

    return GestureDetector(
      onLongPressStart: active ? (_) => setState(() => _pressing = true) : null,
      onLongPressEnd: active
          ? (_) {
              setState(() => _pressing = false);
              widget.onLongPress?.call();
            }
          : null,
      onLongPressCancel: active ? () => setState(() => _pressing = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _pressing
              ? (widget.filled
                  ? AppColors.primary.withValues(alpha: 0.75)
                  : AppColors.neutral100)
              : bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.fromBorderSide(border),
        ),
        child: Center(
          child: widget.label == null
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : Text(
                  widget.label!,
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15, color: fg),
                ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../attendance/data/models/attendance_model.dart' show AttendanceStatus;
import '../../data/models/attendance_submission_model.dart';
import '../bloc/pending_approvals_cubit.dart';

/// Admin dashboard listing pending teacher attendance submissions. Approving a
/// submission materializes attendance and queues SMS (sent from the admin's
/// device); rejecting discards it.
class PendingApprovalsPage extends StatelessWidget {
  const PendingApprovalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PendingApprovalsCubit(getIt())..load(),
      child: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d.$m.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Tasdiqlash',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
      ),
      body: BlocConsumer<PendingApprovalsCubit, PendingApprovalsState>(
        listenWhen: (prev, curr) =>
            curr is PendingApprovalsLoaded && curr.actionError != null,
        listener: (context, state) {
          if (state is PendingApprovalsLoaded && state.actionError != null) {
            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(SnackBar(
                content: Text(state.actionError!),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ));
          }
        },
        builder: (context, state) {
          if (state is PendingApprovalsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PendingApprovalsError) {
            return _ErrorView(
              message: state.message,
              onRetry: () => context.read<PendingApprovalsCubit>().load(),
            );
          }
          if (state is! PendingApprovalsLoaded) return const SizedBox.shrink();
          if (state.submissions.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => context.read<PendingApprovalsCubit>().load(),
              child: ListView(
                children: [
                  const SizedBox(height: 140),
                  Icon(Icons.inbox_rounded, size: 56, color: AppColors.neutral300),
                  const SizedBox(height: 12),
                  Center(
                    child: Text('Tasdiqlanmagan davomat yo\'q',
                        style: TextStyle(color: AppColors.neutral500)),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => context.read<PendingApprovalsCubit>().load(),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: state.submissions.length,
              itemBuilder: (context, index) {
                final s = state.submissions[index];
                final processing = state.processingIds.contains(s.id);
                return _SubmissionCard(
                  submission: s,
                  processing: processing,
                  formattedDate: _formatDate(s.date),
                  onTap: () => _openDetail(context, s),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _openDetail(BuildContext context, AttendanceSubmissionModel s) {
    final cubit = context.read<PendingApprovalsCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: _DetailSheet(submissionId: s.id),
      ),
    );
  }
}

class _SubmissionCard extends StatelessWidget {
  final AttendanceSubmissionModel submission;
  final bool processing;
  final String formattedDate;
  final VoidCallback onTap;

  const _SubmissionCard({
    required this.submission,
    required this.processing,
    required this.formattedDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: processing ? null : onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.fact_check_rounded,
                    color: AppColors.warning, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(submission.groupName,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.neutral900)),
                    const SizedBox(height: 3),
                    Text(
                        '${submission.teacherName} · $formattedDate',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.neutral500)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _Pill(
                          text: '${submission.absentCount} kelmadi',
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 6),
                        _Pill(
                          text: '${submission.totalCount} jami',
                          color: AppColors.neutral500,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (processing)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                const Icon(Icons.chevron_right_rounded, color: AppColors.neutral400),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;

  const _Pill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _DetailSheet extends StatelessWidget {
  final int submissionId;

  const _DetailSheet({required this.submissionId});

  Future<void> _confirmReject(BuildContext context, PendingApprovalsCubit cubit) async {
    final controller = TextEditingController();
    try {
    final note = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Rad etish', style: TextStyle(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Sabab (ixtiyoriy)',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Bekor qilish', style: TextStyle(color: AppColors.neutral500)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Rad etish',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (note == null) return; // cancelled
    if (context.mounted) Navigator.pop(context); // close detail sheet
    cubit.reject(submissionId, note.isEmpty ? null : note);
    } finally {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PendingApprovalsCubit>();
    return BlocBuilder<PendingApprovalsCubit, PendingApprovalsState>(
      builder: (context, state) {
        if (state is! PendingApprovalsLoaded) return const SizedBox.shrink();
        final submission = state.submissions
            .where((s) => s.id == submissionId)
            .cast<AttendanceSubmissionModel?>()
            .firstWhere((s) => s != null, orElse: () => null);
        if (submission == null) {
          // Already reviewed and removed from list — close the sheet.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.canPop(context)) Navigator.pop(context);
          });
          return const SizedBox.shrink();
        }
        final processing = state.processingIds.contains(submissionId);
        final sorted = [...submission.items]..sort((a, b) {
            // absentees first
            if (a.status == b.status) return a.studentName.compareTo(b.studentName);
            return a.status == AttendanceStatus.ABSENT ? -1 : 1;
          });

        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.backgroundLight,
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
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(submission.groupName,
                                  style: const TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 2),
                              Text(submission.teacherName,
                                  style: const TextStyle(
                                      fontSize: 13, color: AppColors.neutral500)),
                            ],
                          ),
                        ),
                        _Pill(text: '${submission.absentCount} kelmadi', color: AppColors.error),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: sorted.length,
                      itemBuilder: (context, index) {
                        final item = sorted[index];
                        final isAbsent = item.status == AttendanceStatus.ABSENT;
                        final color = isAbsent ? AppColors.error : AppColors.success;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isAbsent
                                    ? Icons.cancel_rounded
                                    : Icons.check_circle_rounded,
                                color: color,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(item.studentName,
                                    style: const TextStyle(
                                        fontSize: 15, fontWeight: FontWeight.w600)),
                              ),
                              Text(isAbsent ? 'KELMADI' : 'KELDI',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: color)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed:
                                  processing ? null : () => _confirmReject(context, cubit),
                              child: const Text('Rad etish',
                                  style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.success,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: processing
                                  ? null
                                  : () {
                                      Navigator.pop(context);
                                      cubit.approve(submissionId);
                                    },
                              child: processing
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Text('Tasdiqlash va SMS',
                                      style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.neutral600)),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Qayta urinish')),
        ],
      ),
    );
  }
}

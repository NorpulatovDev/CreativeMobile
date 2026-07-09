import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/sms_queue_processor.dart';
import '../../data/models/attendance_submission_model.dart';
import '../../data/repositories/attendance_submission_repository.dart';

abstract class PendingApprovalsState extends Equatable {
  const PendingApprovalsState();

  @override
  List<Object?> get props => [];
}

class PendingApprovalsLoading extends PendingApprovalsState {}

class PendingApprovalsError extends PendingApprovalsState {
  final String message;
  const PendingApprovalsError(this.message);

  @override
  List<Object?> get props => [message];
}

class PendingApprovalsLoaded extends PendingApprovalsState {
  final List<AttendanceSubmissionModel> submissions;
  final Set<int> processingIds; // ids currently being approved/rejected
  final String? actionError;

  const PendingApprovalsLoaded(
    this.submissions, {
    this.processingIds = const {},
    this.actionError,
  });

  PendingApprovalsLoaded copyWith({
    List<AttendanceSubmissionModel>? submissions,
    Set<int>? processingIds,
    String? actionError,
  }) =>
      PendingApprovalsLoaded(
        submissions ?? this.submissions,
        processingIds: processingIds ?? this.processingIds,
        actionError: actionError,
      );

  @override
  List<Object?> get props =>
      [submissions, [...processingIds]..sort(), actionError];
}

class PendingApprovalsCubit extends Cubit<PendingApprovalsState> {
  final AttendanceSubmissionRepository _repo;

  PendingApprovalsCubit(this._repo) : super(PendingApprovalsLoading());

  Future<void> load() async {
    emit(PendingApprovalsLoading());
    final (submissions, failure) = await _repo.getPending();
    if (isClosed) return;
    if (failure != null) {
      emit(PendingApprovalsError(failure.message));
    } else {
      emit(PendingApprovalsLoaded(submissions ?? []));
    }
  }

  Future<void> approve(int id) => _review(id, approve: true);

  Future<void> reject(int id, String? note) => _review(id, approve: false, note: note);

  Future<void> _review(int id, {required bool approve, String? note}) async {
    final current = state;
    if (current is! PendingApprovalsLoaded) return;
    if (current.processingIds.contains(id)) return;

    emit(current.copyWith(
      processingIds: {...current.processingIds, id},
      actionError: null,
    ));

    final (_, failure) = approve
        ? await _repo.approve(id)
        : await _repo.reject(id, note);

    if (isClosed) return;
    final latest = state;
    if (latest is! PendingApprovalsLoaded) return;

    final remainingProcessing = {...latest.processingIds}..remove(id);

    if (failure != null) {
      emit(latest.copyWith(
        processingIds: remainingProcessing,
        actionError: failure.message,
      ));
    } else {
      // Remove the reviewed submission from the pending list
      emit(latest.copyWith(
        submissions: latest.submissions.where((s) => s.id != id).toList(),
        processingIds: remainingProcessing,
      ));
      // Approval queues SMS server-side; nudge the device to deliver them now.
      if (approve) {
        getIt<SmsQueueProcessor>().processQueue();
      }
    }
  }
}

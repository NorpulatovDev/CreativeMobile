import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/sms_service.dart';
import '../../../enrollments/data/models/enrollment_model.dart';
import '../../../enrollments/data/repositories/enrollment_repository.dart';
import '../../../students/data/models/student_model.dart';

// States

abstract class TakeAttendanceSheetState extends Equatable {
  const TakeAttendanceSheetState();

  @override
  List<Object?> get props => [];
}

class TakeAttendanceSheetLoading extends TakeAttendanceSheetState {}

class TakeAttendanceSheetReady extends TakeAttendanceSheetState {
  final DateTime selectedDate;
  final List<EnrollmentModel> enrollments;
  final Set<int> absentIds;
  final Set<int> smsSentIds;
  final Set<int> smsSendingIds;
  final bool submitting;
  final SmsResult? smsNotification;

  const TakeAttendanceSheetReady({
    required this.selectedDate,
    required this.enrollments,
    this.absentIds = const {},
    this.smsSentIds = const {},
    this.smsSendingIds = const {},
    this.submitting = false,
    this.smsNotification,
  });

  TakeAttendanceSheetReady copyWith({
    DateTime? selectedDate,
    List<EnrollmentModel>? enrollments,
    Set<int>? absentIds,
    Set<int>? smsSentIds,
    Set<int>? smsSendingIds,
    bool? submitting,
    SmsResult? smsNotification,
  }) =>
      TakeAttendanceSheetReady(
        selectedDate: selectedDate ?? this.selectedDate,
        enrollments: enrollments ?? this.enrollments,
        absentIds: absentIds ?? this.absentIds,
        smsSentIds: smsSentIds ?? this.smsSentIds,
        smsSendingIds: smsSendingIds ?? this.smsSendingIds,
        submitting: submitting ?? this.submitting,
        smsNotification: smsNotification,
      );

  @override
  List<Object?> get props => [
        selectedDate,
        enrollments,
        [...absentIds]..sort(),
        [...smsSentIds]..sort(),
        [...smsSendingIds]..sort(),
        submitting,
        smsNotification,
      ];
}

// Cubit

class TakeAttendanceSheetCubit extends Cubit<TakeAttendanceSheetState> {
  final EnrollmentRepository _enrollmentRepo;
  final SmsService _smsService;
  final int groupId;
  final Map<int, StudentModel> _studentMap;

  TakeAttendanceSheetCubit({
    required EnrollmentRepository enrollmentRepo,
    required SmsService smsService,
    required this.groupId,
    required List<StudentModel> students,
  })  : _enrollmentRepo = enrollmentRepo,
        _smsService = smsService,
        _studentMap = {for (final s in students) s.id: s},
        super(TakeAttendanceSheetLoading());

  Future<void> load() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final (enrollments, _) = await _enrollmentRepo.getGroupStudents(groupId);
    if (isClosed) return;
    emit(TakeAttendanceSheetReady(
      selectedDate: today,
      enrollments: (enrollments ?? []).where((e) => e.active).toList(),
    ));
  }

  void setDate(DateTime date) {
    final ready = state as TakeAttendanceSheetReady;
    emit(ready.copyWith(selectedDate: date));
  }

  void toggleAbsent(int studentId) {
    final ready = state as TakeAttendanceSheetReady;
    final newAbsent = Set<int>.from(ready.absentIds);
    if (newAbsent.contains(studentId)) {
      newAbsent.remove(studentId);
      emit(ready.copyWith(
        absentIds: newAbsent,
        smsSentIds: Set<int>.from(ready.smsSentIds)..remove(studentId),
      ));
    } else {
      emit(ready.copyWith(absentIds: newAbsent..add(studentId)));
    }
  }

  void startSubmitting() {
    final ready = state as TakeAttendanceSheetReady;
    emit(ready.copyWith(submitting: true));
  }

  void resetSubmitting() {
    final ready = state as TakeAttendanceSheetReady;
    emit(ready.copyWith(submitting: false));
  }

  Future<void> sendSms(int studentId) async {
    final ready = state as TakeAttendanceSheetReady;
    final student = _studentMap[studentId];
    if (student == null) return;

    emit(ready.copyWith(
      smsSendingIds: Set<int>.from(ready.smsSendingIds)..add(studentId),
    ));

    final date = (state as TakeAttendanceSheetReady).selectedDate;
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final dateStr = '$d.$m.${date.year}';

    final result = await _smsService.send(
      student.parentPhoneNumber,
      "Hurmatli ota-ona,\nCreative O'quv Markazi: ${student.fullName} bugun ($dateStr) darsga kelmadi.\nIltimos, kelmaslik sababini bizga ma'lum qiling.",
    );

    if (isClosed) return;
    final current = state as TakeAttendanceSheetReady;
    final doneSending = Set<int>.from(current.smsSendingIds)..remove(studentId);

    if (result == SmsResult.sent) {
      emit(current.copyWith(
        smsSendingIds: doneSending,
        smsSentIds: Set<int>.from(current.smsSentIds)..add(studentId),
        smsNotification: result,
      ));
    } else {
      emit(current.copyWith(
        smsSendingIds: doneSending,
        smsNotification: result,
      ));
    }
  }
}

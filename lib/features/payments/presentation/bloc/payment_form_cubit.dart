import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/sms_service.dart';
import '../../../enrollments/data/datasources/enrollment_local_datasource.dart';
import '../../../enrollments/data/models/enrollment_model.dart';
import '../../../enrollments/data/repositories/enrollment_repository.dart';
import '../../../groups/data/datasources/group_local_datasource.dart';
import '../../../groups/data/models/group_model.dart';
import '../../../groups/data/repositories/group_repository.dart';
import '../../../students/data/repositories/student_repository.dart';
import '../../data/models/payment_model.dart';
import 'payment_bloc.dart';

// States

abstract class PaymentFormState extends Equatable {
  const PaymentFormState();

  @override
  List<Object?> get props => [];
}

class PaymentFormLoading extends PaymentFormState {
  const PaymentFormLoading();
}

class PaymentFormReady extends PaymentFormState {
  final List<GroupModel> groups;
  final List<EnrollmentModel> groupStudents;
  final bool loadingStudents;
  final int? selectedGroupId;
  final int? selectedStudentId;
  final String selectedMonth;
  final bool submitting;
  final String? pendingSmsPhone;
  final String? pendingSmsMessage;
  final SmsResult? smsNotification;
  final bool done;

  const PaymentFormReady({
    required this.groups,
    this.groupStudents = const [],
    this.loadingStudents = false,
    this.selectedGroupId,
    this.selectedStudentId,
    required this.selectedMonth,
    this.submitting = false,
    this.pendingSmsPhone,
    this.pendingSmsMessage,
    this.smsNotification,
    this.done = false,
  });

  PaymentFormReady copyWith({
    List<GroupModel>? groups,
    List<EnrollmentModel>? groupStudents,
    bool? loadingStudents,
    Object? selectedGroupId = _keep,
    Object? selectedStudentId = _keep,
    String? selectedMonth,
    bool? submitting,
    Object? pendingSmsPhone = _keep,
    Object? pendingSmsMessage = _keep,
    SmsResult? smsNotification,
    bool? done,
  }) =>
      PaymentFormReady(
        groups: groups ?? this.groups,
        groupStudents: groupStudents ?? this.groupStudents,
        loadingStudents: loadingStudents ?? this.loadingStudents,
        selectedGroupId: selectedGroupId == _keep
            ? this.selectedGroupId
            : selectedGroupId as int?,
        selectedStudentId: selectedStudentId == _keep
            ? this.selectedStudentId
            : selectedStudentId as int?,
        selectedMonth: selectedMonth ?? this.selectedMonth,
        submitting: submitting ?? this.submitting,
        pendingSmsPhone: pendingSmsPhone == _keep
            ? this.pendingSmsPhone
            : pendingSmsPhone as String?,
        pendingSmsMessage: pendingSmsMessage == _keep
            ? this.pendingSmsMessage
            : pendingSmsMessage as String?,
        smsNotification: smsNotification,
        done: done ?? this.done,
      );

  @override
  List<Object?> get props => [
        groups,
        groupStudents,
        loadingStudents,
        selectedGroupId,
        selectedStudentId,
        selectedMonth,
        submitting,
        pendingSmsPhone,
        pendingSmsMessage,
        smsNotification,
        done,
      ];
}

const Object _keep = Object();

// Cubit

class PaymentFormCubit extends Cubit<PaymentFormState> {
  final GroupRepository _groupRepo;
  final GroupLocalDataSource _groupLocal;
  final EnrollmentRepository _enrollmentRepo;
  final EnrollmentLocalDataSource _enrollmentLocal;
  final StudentRepository _studentRepo;
  final SmsService _smsService;
  final PaymentBloc _paymentBloc;

  int? _loadedGroupId;

  PaymentFormCubit({
    required GroupRepository groupRepo,
    required GroupLocalDataSource groupLocal,
    required EnrollmentRepository enrollmentRepo,
    required EnrollmentLocalDataSource enrollmentLocal,
    required StudentRepository studentRepo,
    required SmsService smsService,
    required PaymentBloc paymentBloc,
    required String initialMonth,
    int? preselectedGroupId,
    int? preselectedStudentId,
    PaymentModel? editing,
  })  : _groupRepo = groupRepo,
        _groupLocal = groupLocal,
        _enrollmentRepo = enrollmentRepo,
        _enrollmentLocal = enrollmentLocal,
        _studentRepo = studentRepo,
        _smsService = smsService,
        _paymentBloc = paymentBloc,
        super(editing != null
            ? PaymentFormReady(
                groups: const [],
                selectedGroupId: editing.groupId,
                selectedStudentId: editing.studentId,
                selectedMonth: editing.paidForMonth,
              )
            : PaymentFormReady(
                groups: const [],
                selectedGroupId: preselectedGroupId,
                selectedStudentId: preselectedStudentId,
                selectedMonth: initialMonth,
              ));

  Future<void> loadGroups({double? prefillAmount}) async {
    final cached = _groupLocal.getAll();
    if (cached.isNotEmpty) {
      _applyGroups(cached, prefillAmount: prefillAmount);
    } else {
      emit(const PaymentFormLoading());
    }

    final (groups, _) = await _groupRepo.getAll();
    if (isClosed || groups == null) return;
    _applyGroups(groups, prefillAmount: prefillAmount);
  }

  void _applyGroups(List<GroupModel> groups, {double? prefillAmount}) {
    final prev = state is PaymentFormReady
        ? state as PaymentFormReady
        : PaymentFormReady(groups: const [], selectedMonth: _currentMonth());
    final updated = prev.copyWith(groups: groups);
    emit(updated);

    if (updated.selectedGroupId != null &&
        _loadedGroupId != updated.selectedGroupId) {
      loadStudentsForGroup(updated.selectedGroupId!,
          prefillAmount: prefillAmount);
    }
  }

  Future<void> loadStudentsForGroup(int groupId, {double? prefillAmount}) async {
    final ready = state as PaymentFormReady;
    _loadedGroupId = groupId;

    final cached = _enrollmentLocal
        .getGroupStudents(groupId)
        .where((e) => e.active)
        .toList();

    emit(ready.copyWith(
      groupStudents: cached,
      loadingStudents: cached.isEmpty,
      selectedStudentId: cached.isEmpty ? null : ready.selectedStudentId,
    ));

    final (enrollments, _) = await _enrollmentRepo.getGroupStudents(groupId);
    if (isClosed || _loadedGroupId != groupId) return;

    final current = state as PaymentFormReady;
    final students = (enrollments ?? cached).where((e) => e.active).toList();
    final studentStillExists =
        students.any((e) => e.studentId == current.selectedStudentId);

    emit(current.copyWith(
      groupStudents: students,
      loadingStudents: false,
      selectedStudentId:
          studentStillExists ? current.selectedStudentId : null,
    ));
  }

  void selectGroup(GroupModel group, {required void Function(double) onAmountPrefill}) {
    final ready = state as PaymentFormReady;
    _loadedGroupId = null;
    emit(ready.copyWith(
      selectedGroupId: group.id,
      selectedStudentId: null,
      groupStudents: const [],
    ));
    onAmountPrefill(group.monthlyFee);
    loadStudentsForGroup(group.id);
  }

  void selectStudent(int studentId) {
    final ready = state as PaymentFormReady;
    emit(ready.copyWith(selectedStudentId: studentId));
  }

  void selectMonth(String month) {
    final ready = state as PaymentFormReady;
    emit(ready.copyWith(selectedMonth: month));
  }

  Future<void> submit({
    required bool isEditing,
    required int? paymentId,
    required double amount,
  }) async {
    final ready = state as PaymentFormReady;
    if (ready.selectedGroupId == null || ready.selectedStudentId == null) return;

    emit(ready.copyWith(submitting: true));

    if (isEditing) {
      _paymentBloc.add(PaymentUpdate(
        id: paymentId!,
        studentId: ready.selectedStudentId!,
        groupId: ready.selectedGroupId!,
        amount: amount,
        paidForMonth: ready.selectedMonth,
      ));
    } else {
      final (student, _) = await _studentRepo.getById(ready.selectedStudentId!);
      if (isClosed) return;

      final current = state as PaymentFormReady;
      final monthLabel = _formatMonth(current.selectedMonth);
      emit(current.copyWith(
        pendingSmsPhone: student?.parentPhoneNumber,
        pendingSmsMessage: student != null
            ? "Assalomu alaykum!\nCreative O'quv Markazi ma'muriyati sizga ma'lum qiladiki, "
                "${student.fullName}ning $monthLabel oyi uchun "
                "${amount.toStringAsFixed(0)} so'm to'lovi qabul qilindi.\nRahmat!"
            : null,
      ));

      _paymentBloc.add(PaymentCreate(
        studentId: ready.selectedStudentId!,
        groupId: ready.selectedGroupId!,
        amount: amount,
        paidForMonth: ready.selectedMonth,
      ));
    }
  }

  Future<void> onPaymentSuccess() async {
    final ready = state as PaymentFormReady;

    if (ready.pendingSmsPhone == null || ready.pendingSmsMessage == null) {
      emit(ready.copyWith(done: true));
      return;
    }

    final result =
        await _smsService.send(ready.pendingSmsPhone!, ready.pendingSmsMessage!);
    if (isClosed) return;

    final current = state as PaymentFormReady;
    emit(current.copyWith(smsNotification: result, submitting: false, done: true));
  }

  void onPaymentError() {
    final ready = state as PaymentFormReady;
    emit(ready.copyWith(submitting: false));
  }

  static String _currentMonth() {
    final now = DateTime.now();
    final m = now.month.toString().padLeft(2, '0');
    return '${now.year}-$m';
  }

  static String _formatMonth(String month) {
    final parts = month.split('-');
    const names = [
      '', 'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
      'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr',
    ];
    return '${names[int.parse(parts[1])]} ${parts[0]}';
  }
}

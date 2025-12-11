import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import '../../data/models/models.dart';
import '../../data/repositories/payment_repository.dart';
import '../../../groups/data/models/models.dart';
import '../../../groups/data/repositories/group_repository.dart';
import '../../../students/data/models/models.dart';
import '../../../students/data/repositories/student_repository.dart';

part 'payment_bloc.freezed.dart';

// Events
@freezed
class PaymentEvent with _$PaymentEvent {
  const factory PaymentEvent.loadAll() = PaymentLoadAll;
  const factory PaymentEvent.filterByStudent({required int? studentId}) = PaymentFilterByStudent;
  const factory PaymentEvent.filterByGroup({required int? groupId}) = PaymentFilterByGroup;
  const factory PaymentEvent.create({
    required int studentId,
    required int groupId,
    required double amount,
    required String paidForMonth,
  }) = PaymentCreate;
}

// States
@freezed
class PaymentState with _$PaymentState {
  const factory PaymentState.initial() = PaymentInitial;
  const factory PaymentState.loading() = PaymentLoading;
  const factory PaymentState.loaded({
    required List<Payment> payments,
    required List<Payment> filteredPayments,
    required List<Student> students,
    required List<Group> groups,
    int? selectedStudentId,
    int? selectedGroupId,
  }) = PaymentLoaded;
  const factory PaymentState.saving() = PaymentSaving;
  const factory PaymentState.saved() = PaymentSaved;
  const factory PaymentState.error({required String message}) = PaymentError;
}

// Bloc
@injectable
class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepository _paymentRepository;
  final StudentRepository _studentRepository;
  final GroupRepository _groupRepository;

  List<Payment> _allPayments = [];
  List<Student> _students = [];
  List<Group> _groups = [];
  int? _selectedStudentId;
  int? _selectedGroupId;

  PaymentBloc(
    this._paymentRepository,
    this._studentRepository,
    this._groupRepository,
  ) : super(const PaymentState.initial()) {
    on<PaymentLoadAll>(_onLoadAll);
    on<PaymentFilterByStudent>(_onFilterByStudent);
    on<PaymentFilterByGroup>(_onFilterByGroup);
    on<PaymentCreate>(_onCreate);
  }

  Future<void> _onLoadAll(
    PaymentLoadAll event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentState.loading());
    try {
      final results = await Future.wait([
        _paymentRepository.getAll(),
        _studentRepository.getAll(),
        _groupRepository.getAll(),
      ]);

      _allPayments = results[0] as List<Payment>;
      _students = results[1] as List<Student>;
      _groups = results[2] as List<Group>;
      _selectedStudentId = null;
      _selectedGroupId = null;

      emit(PaymentState.loaded(
        payments: _allPayments,
        filteredPayments: _allPayments,
        students: _students,
        groups: _groups,
      ));
    } catch (e) {
      emit(PaymentState.error(message: e.toString()));
    }
  }

  void _onFilterByStudent(
    PaymentFilterByStudent event,
    Emitter<PaymentState> emit,
  ) {
    _selectedStudentId = event.studentId;
    _selectedGroupId = null;

    final filtered = event.studentId == null
        ? _allPayments
        : _allPayments.where((p) => p.studentId == event.studentId).toList();

    emit(PaymentState.loaded(
      payments: _allPayments,
      filteredPayments: filtered,
      students: _students,
      groups: _groups,
      selectedStudentId: _selectedStudentId,
      selectedGroupId: _selectedGroupId,
    ));
  }

  void _onFilterByGroup(
    PaymentFilterByGroup event,
    Emitter<PaymentState> emit,
  ) {
    _selectedGroupId = event.groupId;
    _selectedStudentId = null;

    final filtered = event.groupId == null
        ? _allPayments
        : _allPayments.where((p) => p.groupId == event.groupId).toList();

    emit(PaymentState.loaded(
      payments: _allPayments,
      filteredPayments: filtered,
      students: _students,
      groups: _groups,
      selectedStudentId: _selectedStudentId,
      selectedGroupId: _selectedGroupId,
    ));
  }

  Future<void> _onCreate(
    PaymentCreate event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentState.saving());
    try {
      await _paymentRepository.create(PaymentRequest(
        studentId: event.studentId,
        groupId: event.groupId,
        amount: event.amount,
        paidForMonth: event.paidForMonth,
      ));
      emit(const PaymentState.saved());
      add(const PaymentLoadAll());
    } catch (e) {
      emit(PaymentState.error(message: e.toString()));
    }
  }
}
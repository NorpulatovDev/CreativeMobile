import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import '../../data/models/models.dart';
import '../../data/repositories/attendance_repository.dart';
import '../../../groups/data/models/models.dart';
import '../../../groups/data/repositories/group_repository.dart';
import '../../../students/data/models/models.dart';
import '../../../students/data/repositories/student_repository.dart';

part 'attendance_bloc.freezed.dart';

// Events
@freezed
class AttendanceEvent with _$AttendanceEvent {
  const factory AttendanceEvent.loadGroups() = AttendanceLoadGroups;
  const factory AttendanceEvent.selectGroup({required Group group}) = AttendanceSelectGroup;
  const factory AttendanceEvent.selectDate({required DateTime date}) = AttendanceSelectDate;
  const factory AttendanceEvent.loadForGroupAndDate({
    required int groupId,
    required DateTime date,
  }) = AttendanceLoadForGroupAndDate;
  const factory AttendanceEvent.toggleStudent({required int studentId}) = AttendanceToggleStudent;
  const factory AttendanceEvent.saveAttendance() = AttendanceSave;
  const factory AttendanceEvent.updateStatus({
    required int attendanceId,
    required String status,
  }) = AttendanceUpdateStatus;
}

// States
@freezed
class AttendanceState with _$AttendanceState {
  const factory AttendanceState.initial() = AttendanceInitial;
  const factory AttendanceState.loading() = AttendanceLoading;
  const factory AttendanceState.groupsLoaded({
    required List<Group> groups,
  }) = AttendanceGroupsLoaded;
  const factory AttendanceState.ready({
    required List<Group> groups,
    required Group selectedGroup,
    required DateTime selectedDate,
    required List<Student> students,
    required List<Attendance> existingAttendance,
    required Set<int> absentStudentIds,
    required bool hasExistingAttendance,
  }) = AttendanceReady;
  const factory AttendanceState.saving() = AttendanceSaving;
  const factory AttendanceState.saved() = AttendanceSaved;
  const factory AttendanceState.error({required String message}) = AttendanceError;
}

// Bloc
@injectable
class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceRepository _attendanceRepository;
  final GroupRepository _groupRepository;
  final StudentRepository _studentRepository;

  List<Group> _groups = [];
  Group? _selectedGroup;
  DateTime _selectedDate = DateTime.now();
  List<Student> _students = [];
  List<Attendance> _existingAttendance = [];
  Set<int> _absentStudentIds = {};

  AttendanceBloc(
    this._attendanceRepository,
    this._groupRepository,
    this._studentRepository,
  ) : super(const AttendanceState.initial()) {
    on<AttendanceLoadGroups>(_onLoadGroups);
    on<AttendanceSelectGroup>(_onSelectGroup);
    on<AttendanceSelectDate>(_onSelectDate);
    on<AttendanceLoadForGroupAndDate>(_onLoadForGroupAndDate);
    on<AttendanceToggleStudent>(_onToggleStudent);
    on<AttendanceSave>(_onSave);
    on<AttendanceUpdateStatus>(_onUpdateStatus);
  }

  Future<void> _onLoadGroups(
    AttendanceLoadGroups event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(const AttendanceState.loading());
    try {
      _groups = await _groupRepository.getAll();
      emit(AttendanceState.groupsLoaded(groups: _groups));
    } catch (e) {
      emit(AttendanceState.error(message: e.toString()));
    }
  }

  Future<void> _onSelectGroup(
    AttendanceSelectGroup event,
    Emitter<AttendanceState> emit,
  ) async {
    _selectedGroup = event.group;
    add(AttendanceLoadForGroupAndDate(
      groupId: event.group.id,
      date: _selectedDate,
    ));
  }

  Future<void> _onSelectDate(
    AttendanceSelectDate event,
    Emitter<AttendanceState> emit,
  ) async {
    _selectedDate = event.date;
    if (_selectedGroup != null) {
      add(AttendanceLoadForGroupAndDate(
        groupId: _selectedGroup!.id,
        date: event.date,
      ));
    }
  }

  Future<void> _onLoadForGroupAndDate(
    AttendanceLoadForGroupAndDate event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(const AttendanceState.loading());
    try {
      final results = await Future.wait([
        _studentRepository.getByGroupId(event.groupId),
        _attendanceRepository.getByGroupAndDate(event.groupId, event.date),
      ]);

      _students = results[0] as List<Student>;
      _existingAttendance = results[1] as List<Attendance>;

      // Set absent students from existing attendance
      _absentStudentIds = _existingAttendance
          .where((a) => a.status == AttendanceStatus.ABSENT)
          .map((a) => a.studentId)
          .toSet();

      emit(AttendanceState.ready(
        groups: _groups,
        selectedGroup: _selectedGroup!,
        selectedDate: _selectedDate,
        students: _students,
        existingAttendance: _existingAttendance,
        absentStudentIds: _absentStudentIds,
        hasExistingAttendance: _existingAttendance.isNotEmpty,
      ));
    } catch (e) {
      emit(AttendanceState.error(message: e.toString()));
    }
  }

  void _onToggleStudent(
    AttendanceToggleStudent event,
    Emitter<AttendanceState> emit,
  ) {
    if (_absentStudentIds.contains(event.studentId)) {
      _absentStudentIds = Set.from(_absentStudentIds)..remove(event.studentId);
    } else {
      _absentStudentIds = Set.from(_absentStudentIds)..add(event.studentId);
    }

    emit(AttendanceState.ready(
      groups: _groups,
      selectedGroup: _selectedGroup!,
      selectedDate: _selectedDate,
      students: _students,
      existingAttendance: _existingAttendance,
      absentStudentIds: _absentStudentIds,
      hasExistingAttendance: _existingAttendance.isNotEmpty,
    ));
  }

  Future<void> _onSave(
    AttendanceSave event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(const AttendanceState.saving());
    try {
      await _attendanceRepository.createForGroup(AttendanceRequest(
        groupId: _selectedGroup!.id,
        date: _selectedDate,
        absentStudentIds: _absentStudentIds.toList(),
      ));
      emit(const AttendanceState.saved());
      
      // Reload data
      add(AttendanceLoadForGroupAndDate(
        groupId: _selectedGroup!.id,
        date: _selectedDate,
      ));
    } catch (e) {
      emit(AttendanceState.error(message: e.toString()));
    }
  }

  Future<void> _onUpdateStatus(
    AttendanceUpdateStatus event,
    Emitter<AttendanceState> emit,
  ) async {
    try {
      await _attendanceRepository.updateStatus(event.attendanceId, event.status);
      
      // Reload data
      add(AttendanceLoadForGroupAndDate(
        groupId: _selectedGroup!.id,
        date: _selectedDate,
      ));
    } catch (e) {
      emit(AttendanceState.error(message: e.toString()));
    }
  }
}
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../attendance/presentation/bloc/attendance_bloc.dart';
import '../../data/models/group_model.dart';
import '../../data/repositories/group_repository.dart';

// States

abstract class GroupDetailState extends Equatable {
  const GroupDetailState();

  @override
  List<Object?> get props => [];
}

class GroupDetailLoading extends GroupDetailState {}

class GroupDetailLoaded extends GroupDetailState {
  final GroupModel group;
  final DateTime selectedMonth;

  const GroupDetailLoaded({
    required this.group,
    required this.selectedMonth,
  });

  GroupDetailLoaded copyWith({
    GroupModel? group,
    DateTime? selectedMonth,
  }) =>
      GroupDetailLoaded(
        group: group ?? this.group,
        selectedMonth: selectedMonth ?? this.selectedMonth,
      );

  @override
  List<Object?> get props => [group, selectedMonth];
}

class GroupDetailError extends GroupDetailState {}

// Cubit

class GroupDetailCubit extends Cubit<GroupDetailState> {
  final GroupRepository _groupRepository;
  final AttendanceBloc _attendanceBloc;
  final int _groupId;

  GroupDetailCubit({
    required GroupRepository groupRepository,
    required AttendanceBloc attendanceBloc,
    required int groupId,
  })  : _groupRepository = groupRepository,
        _attendanceBloc = attendanceBloc,
        _groupId = groupId,
        super(GroupDetailLoading());

  Future<void> loadGroup() async {
    emit(GroupDetailLoading());
    final (group, _) = await _groupRepository.getById(_groupId);
    if (group == null) {
      emit(GroupDetailError());
      return;
    }
    final now = DateTime.now();
    emit(GroupDetailLoaded(group: group, selectedMonth: now));
    _triggerAttendanceLoad(now);
  }

  void selectMonth(DateTime month) {
    final current = state;
    if (current is GroupDetailLoaded) {
      emit(current.copyWith(selectedMonth: month));
      _triggerAttendanceLoad(month);
    }
  }

  void _triggerAttendanceLoad(DateTime month) {
    _attendanceBloc.add(AttendanceLoadByGroupAndMonth(
      groupId: _groupId,
      year: month.year,
      month: month.month,
    ));
  }
}

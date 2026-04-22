import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../students/data/models/student_model.dart';
import '../../../students/data/repositories/student_repository.dart';

// States

abstract class GroupStudentsState extends Equatable {
  const GroupStudentsState();

  @override
  List<Object?> get props => [];
}

class GroupStudentsInitial extends GroupStudentsState {}

class GroupStudentsLoading extends GroupStudentsState {}

class GroupStudentsLoaded extends GroupStudentsState {
  final List<StudentModel> students;

  const GroupStudentsLoaded(this.students);

  @override
  List<Object?> get props => [students];
}

// Cubit

class GroupStudentsCubit extends Cubit<GroupStudentsState> {
  final StudentRepository _repository;

  int? _groupId;
  int? _year;
  int? _month;

  GroupStudentsCubit(this._repository) : super(GroupStudentsInitial());

  Future<void> load({
    required int groupId,
    required int year,
    required int month,
  }) async {
    _groupId = groupId;
    _year = year;
    _month = month;
    emit(GroupStudentsLoading());
    final (students, _) =
        await _repository.getByGroupId(groupId, year: year, month: month);
    emit(GroupStudentsLoaded(students ?? []));
  }

  Future<void> reload() async {
    if (_groupId == null) return;
    await load(groupId: _groupId!, year: _year!, month: _month!);
  }

  List<StudentModel> get students =>
      state is GroupStudentsLoaded
          ? (state as GroupStudentsLoaded).students
          : [];
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/router/routes.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../students/data/models/student_model.dart';
import '../../bloc/group_students_cubit.dart';
import '../../widgets/student_card.dart';

class GroupStudentsTab extends StatelessWidget {
  final int groupId;
  final ValueChanged<StudentModel> onRemoveStudent;
  final bool isTransferMode;
  final Set<int> selectedStudentIds;
  final ValueChanged<int> onToggleSelection;

  const GroupStudentsTab({
    super.key,
    required this.groupId,
    required this.onRemoveStudent,
    this.isTransferMode = false,
    this.selectedStudentIds = const {},
    required this.onToggleSelection,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupStudentsCubit, GroupStudentsState>(
      buildWhen: (prev, curr) =>
          prev.runtimeType != curr.runtimeType || curr is GroupStudentsLoaded,
      builder: (context, state) {
        if (state is GroupStudentsInitial || state is GroupStudentsLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.success),
          );
        }

        if (state is GroupStudentsLoaded && state.students.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      shape: BoxShape.circle),
                  child: Icon(Icons.people_outline_rounded,
                      size: 48, color: AppColors.success),
                ),
                const SizedBox(height: 24),
                Text('O\'quvchilar yo\'q',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.neutral700,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('Guruhga o\'quvchi qo\'shing',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.neutral500)),
              ],
            ),
          );
        }

        final students =
            state is GroupStudentsLoaded ? state.students : <StudentModel>[];

        return RefreshIndicator(
          onRefresh: context.read<GroupStudentsCubit>().reload,
          color: AppColors.success,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              GroupInfo? groupInfo;
              try {
                groupInfo = student.activeGroups.firstWhere(
                  (g) => g.groupId == groupId,
                );
              } catch (_) {
                if (student.activeGroups.isNotEmpty) {
                  groupInfo = student.activeGroups.first;
                }
              }
              if (groupInfo == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: StudentCard(
                  student: student,
                  groupInfo: groupInfo,
                  isSelectionMode: isTransferMode,
                  isSelected: selectedStudentIds.contains(student.id),
                  onTap: isTransferMode
                      ? () => onToggleSelection(student.id)
                      : () => context.push('${Routes.students}/${student.id}'),
                  onLongPress:
                      isTransferMode ? null : () => onRemoveStudent(student),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/router/routes.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../students/data/models/student_model.dart';
import '../../bloc/group_students_cubit.dart';
import '../../widgets/student_card.dart';

class GroupStudentsTab extends StatefulWidget {
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
  State<GroupStudentsTab> createState() => _GroupStudentsTabState();
}

class _GroupStudentsTabState extends State<GroupStudentsTab> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<StudentModel> _filtered(List<StudentModel> students) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return students;
    return students
        .where((s) => s.fullName.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // ── Layout: search bar (stable) on top, scrollable list below ──
    // The TextField MUST live outside BlocBuilder and CustomScrollView
    // so that setState() doesn't destroy its element/focus.
    return Column(
      children: [
        // ── Search bar ────────────────────────────────────────────────
        Container(
          color: AppColors.backgroundLight,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v),
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'O\'quvchi qidirish...',
              hintStyle:
                  const TextStyle(fontSize: 14, color: AppColors.neutral400),
              prefixIcon: const Icon(Icons.search_rounded,
                  color: AppColors.neutral400, size: 20),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded,
                          size: 18, color: AppColors.neutral400),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.neutral100,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                    color: AppColors.success.withValues(alpha: 0.5), width: 1.5),
              ),
            ),
          ),
        ),

        // ── BlocBuilder: list (rebuilds on bloc state, not on setState) ──
        Expanded(
          child: BlocBuilder<GroupStudentsCubit, GroupStudentsState>(
            buildWhen: (prev, curr) =>
                prev.runtimeType != curr.runtimeType ||
                curr is GroupStudentsLoaded,
            builder: (context, state) {
              if (state is GroupStudentsInitial ||
                  state is GroupStudentsLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.success),
                );
              }

              final allStudents = state is GroupStudentsLoaded
                  ? state.students
                  : <StudentModel>[];

              if (allStudents.isEmpty) {
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
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
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

              final students = _filtered(allStudents);

              // ── Empty search result ──────────────────────────────────
              if (students.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded,
                          size: 48, color: AppColors.neutral300),
                      const SizedBox(height: 12),
                      Text(
                        '"$_query" bo\'yicha o\'quvchi topilmadi',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: AppColors.neutral400, fontSize: 14),
                      ),
                    ],
                  ),
                );
              }

              // ── Student list ─────────────────────────────────────────
              return RefreshIndicator(
                onRefresh: context.read<GroupStudentsCubit>().reload,
                color: AppColors.success,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  itemCount: students.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final student = students[index];
                    GroupInfo? groupInfo;
                    try {
                      groupInfo = student.activeGroups.firstWhere(
                        (g) => g.groupId == widget.groupId,
                      );
                    } catch (_) {
                      if (student.activeGroups.isNotEmpty) {
                        groupInfo = student.activeGroups.first;
                      }
                    }
                    if (groupInfo == null) return const SizedBox.shrink();
                    return StudentCard(
                      student: student,
                      groupInfo: groupInfo,
                      isSelectionMode: widget.isTransferMode,
                      isSelected:
                          widget.selectedStudentIds.contains(student.id),
                      onTap: widget.isTransferMode
                          ? () => widget.onToggleSelection(student.id)
                          : () =>
                              context.push('${Routes.students}/${student.id}'),
                      onLongPress: widget.isTransferMode
                          ? null
                          : () => widget.onRemoveStudent(student),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/router/routes.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../students/data/models/student_model.dart';
import '../../../../students/data/repositories/student_repository.dart';
import '../../widgets/student_card.dart';

class GroupStudentsTab extends StatefulWidget {
  final int groupId;
  final int year;
  final int month;
  final ValueChanged<List<StudentModel>> onStudentsLoaded;
  final ValueChanged<StudentModel> onRemoveStudent;

  const GroupStudentsTab({
    super.key,
    required this.groupId,
    required this.year,
    required this.month,
    required this.onStudentsLoaded,
    required this.onRemoveStudent,
  });

  @override
  State<GroupStudentsTab> createState() => _GroupStudentsTabState();
}

class _GroupStudentsTabState extends State<GroupStudentsTab> {
  List<StudentModel> _students = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final (students, _) = await getIt<StudentRepository>()
        .getByGroupId(widget.groupId, year: widget.year, month: widget.month);
    if (mounted) {
      final list = students ?? [];
      setState(() {
        _students = list;
        _loading = false;
      });
      widget.onStudentsLoaded(list);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.success),
      );
    }

    if (_students.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle),
              child: Icon(Icons.people_outline_rounded,
                  size: 48, color: AppColors.success),
            ),
            const SizedBox(height: 24),
            Text('O\'quvchilar yo\'q',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.neutral700, fontWeight: FontWeight.w600)),
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

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.success,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _students.length,
        itemBuilder: (context, index) {
          final student = _students[index];
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
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: StudentCard(
              student: student,
              groupInfo: groupInfo,
              onTap: () => context.push('${Routes.students}/${student.id}'),
              onLongPress: () => widget.onRemoveStudent(student),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../enrollments/data/repositories/enrollment_repository.dart';
import '../../../students/data/models/student_model.dart';
import '../../../students/data/repositories/student_repository.dart';

class EnrollStudentDialog extends StatefulWidget {
  final int groupId;
  final VoidCallback onEnrolled;
  final ValueChanged<String> onError;
  final ValueChanged<String> onWarning;

  const EnrollStudentDialog({
    super.key,
    required this.groupId,
    required this.onEnrolled,
    required this.onError,
    required this.onWarning,
  });

  @override
  State<EnrollStudentDialog> createState() => _EnrollStudentDialogState();
}

class _EnrollStudentDialogState extends State<EnrollStudentDialog> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _loading = true;
  List<StudentModel> _availableStudents = [];

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final (allStudents, failure) = await getIt<StudentRepository>().getAll();
    final (enrollments, _) =
        await getIt<EnrollmentRepository>().getGroupStudents(widget.groupId);

    if (failure != null) {
      if (mounted) {
        Navigator.pop(context);
        widget.onError('O\'quvchilarni yuklashda xatolik');
      }
      return;
    }

    final enrolledIds =
        (enrollments ?? []).map((e) => e.studentId).toSet();
    final available = (allStudents ?? [])
        .where((s) => !enrolledIds.contains(s.id))
        .toList();

    if (available.isEmpty) {
      if (mounted) {
        Navigator.pop(context);
        widget.onWarning('Barcha o\'quvchilar allaqachon ro\'yxatdan o\'tgan');
      }
      return;
    }

    if (mounted) {
      setState(() {
        _availableStudents = available;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<StudentModel> get _filtered {
    if (_searchQuery.isEmpty) return _availableStudents;
    return _availableStudents
        .where((s) =>
            s.fullName.toLowerCase().contains(_searchQuery) ||
            s.parentName.toLowerCase().contains(_searchQuery) ||
            s.parentPhoneNumber.contains(_searchQuery))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                        Icon(Icons.person_add_rounded, color: AppColors.success),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'O\'quvchi qo\'shish',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            if (_loading)
              const Expanded(
                child: Center(
                    child:
                        CircularProgressIndicator(color: AppColors.success)),
              )
            else ...[
              Padding(
                padding: const EdgeInsets.all(20),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) =>
                      setState(() => _searchQuery = v.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Ism bo\'yicha qidirish...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                  ),
                ),
              ),
              Flexible(
                child: _filtered.isEmpty
                    ? const Center(child: Text('O\'quvchi topilmadi'))
                    : ListView.builder(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        shrinkWrap: true,
                        itemCount: _filtered.length,
                        itemBuilder: (context, index) {
                          final student = _filtered[index];
                          return ListTile(
                            title: Text(student.fullName),
                            subtitle: Text(student.parentPhoneNumber),
                            onTap: () async {
                              Navigator.pop(context);
                              await getIt<EnrollmentRepository>()
                                  .addStudentToGroup(
                                      student.id, widget.groupId);
                              widget.onEnrolled();
                            },
                          );
                        },
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

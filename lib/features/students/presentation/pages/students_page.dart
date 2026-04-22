import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/phone_formatter.dart';
import '../../../groups/data/datasources/group_local_datasource.dart';
import '../../../groups/data/models/group_model.dart';
import '../../../groups/data/repositories/group_repository.dart';
import '../../data/models/student_model.dart';
import '../bloc/student_bloc.dart';

class StudentsPage extends StatelessWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<StudentBloc>()..add(const StudentSearch('')),
      child: const StudentsView(),
    );
  }
}

class StudentsView extends StatefulWidget {
  const StudentsView({super.key});

  @override
  State<StudentsView> createState() => _StudentsViewState();
}

class _StudentsViewState extends State<StudentsView> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      final state = context.read<StudentBloc>().state;
      if (state is StudentLoaded && state.hasMore && !state.isLoadingMore) {
        context.read<StudentBloc>().add(StudentLoadMore());
      }
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) context.read<StudentBloc>().add(StudentSearch(value.trim()));
    });
  }

  void _showSnackBar(String message, Color backgroundColor, IconData icon) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _onRefresh() {
    context.read<StudentBloc>().add(const StudentSearch(''));
    _searchController.clear();
    return context
        .read<StudentBloc>()
        .stream
        .firstWhere((s) => s is StudentLoaded || s is StudentError);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.success,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.surfaceLight,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: const Text(
                'O\'quvchilar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral900,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.success.withOpacity(0.1),
                      AppColors.surfaceLight,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.neutral200),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neutral900.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'O\'quvchilarni qidirish...',
                    hintStyle: TextStyle(
                      color: AppColors.neutral400,
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AppColors.neutral400,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.close_rounded,
                              color: AppColors.neutral400,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              context.read<StudentBloc>().add(const StudentSearch(''));
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
          BlocConsumer<StudentBloc, StudentState>(
            listener: (context, state) {
              if (state is StudentError) {
                _showSnackBar(
                  state.message,
                  AppColors.error,
                  Icons.error_outline,
                );
              }
              if (state is StudentActionSuccess) {
                _showSnackBar(
                  state.message,
                  AppColors.success,
                  Icons.check_circle_outline,
                );
              }
            },
            builder: (context, state) {
              if (state is StudentLoading && state is! StudentLoaded) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.success),
                  ),
                );
              }
              if (state is StudentLoaded) {
                if (state.students.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: _searchController.text.isEmpty
                                  ? AppColors.success.withOpacity(0.1)
                                  : AppColors.neutral100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _searchController.text.isEmpty
                                  ? Icons.school_rounded
                                  : Icons.search_off_rounded,
                              size: 48,
                              color: _searchController.text.isEmpty
                                  ? AppColors.success
                                  : AppColors.neutral400,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _searchController.text.isEmpty
                                ? 'O\'quvchilar yo\'q'
                                : 'Natija topilmadi',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: AppColors.neutral700,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          if (_searchController.text.isEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Birinchi o\'quvchini qo\'shing',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.neutral500),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == state.students.length) {
                          if (state.isLoadingMore) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: CircularProgressIndicator(color: AppColors.success, strokeWidth: 2)),
                            );
                          }
                          if (!state.hasMore) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Text(
                                  'Hammasi yuklandi',
                                  style: TextStyle(color: AppColors.neutral400, fontSize: 13),
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _StudentCard(
                            student: state.students[index],
                            onDelete: () => _showDeleteDialog(context, state.students[index]),
                          ),
                        );
                      },
                      childCount: state.students.length + 1,
                    ),
                  ),
                );
              }
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showStudentDialog(context),
        backgroundColor: AppColors.success,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text(
          'Qo\'shish',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _showStudentDialog(BuildContext context, [StudentModel? student]) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<StudentBloc>(),
        child: StudentFormDialog(student: student),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, StudentModel student) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  size: 32,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'O\'quvchini o\'chirish',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Text(
                '${student.fullName}ni o\'chirishni xohlaysizmi? Barcha guruhlar, to\'lovlar va davomat yozuvlari ham o\'chiriladi.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.neutral500),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: AppColors.neutral300),
                      ),
                      child: const Text('Bekor qilish'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<StudentBloc>().add(
                          StudentDelete(student.id),
                        );
                        Navigator.pop(dialogContext);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('O\'chirish'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final StudentModel student;
  final VoidCallback onDelete;

  const _StudentCard({required this.student, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('${Routes.students}/${student.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.neutral200.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: AppColors.neutral900.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: _getAvatarColor(
                            student.fullName,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            _getInitials(student.fullName),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: _getAvatarColor(student.fullName),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: student.paidForCurrentMonth
                                ? AppColors.success
                                : AppColors.warning,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(
                            student.paidForCurrentMonth
                                ? Icons.check
                                : Icons.schedule,
                            size: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.fullName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline_rounded,
                              size: 14,
                              color: AppColors.neutral400,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                student.parentName,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.neutral500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert_rounded,
                      color: AppColors.neutral400,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditDialog(context);
                      } else if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_rounded,
                              size: 20,
                              color: AppColors.neutral600,
                            ),
                            const SizedBox(width: 12),
                            const Text('Tahrirlash'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_rounded,
                              size: 20,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'O\'chirish',
                              style: TextStyle(color: AppColors.error),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _InfoChip(
                      icon: Icons.phone_outlined,
                      label: PhoneValidator.toDisplayFormat(
                        student.parentPhoneNumber,
                      ),
                      color: AppColors.neutral600,
                    ),
                    const SizedBox(width: 8),
                    _InfoChip(
                      icon: Icons.groups_rounded,
                      label: '${student.activeGroupsCount} guruh',
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    if (student.groupsPaidCount > 0)
                      _InfoChip(
                        icon: Icons.check_circle_rounded,
                        label: '${student.groupsPaidCount} to\'langan',
                        color: AppColors.success,
                      ),
                    if (student.groupsUnpaidCount > 0) ...[
                      const SizedBox(width: 8),
                      _InfoChip(
                        icon: Icons.schedule_rounded,
                        label: '${student.groupsUnpaidCount} to\'lanmagan',
                        color: AppColors.warning,
                      ),
                    ],
                  ],
                ),
              ),
              if (student.activeGroups.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: student.activeGroups
                      .map(
                        (g) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            g.groupName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) => name.isNotEmpty
      ? name
            .split(' ')
            .take(2)
            .map((e) => e.isNotEmpty ? e[0] : '')
            .join()
            .toUpperCase()
      : '?';
  Color _getAvatarColor(String name) {
    final colors = [
      AppColors.primary,
      AppColors.success,
      AppColors.warning,
      const Color(0xFF8B5CF6),
      const Color(0xFF06B6D4),
      const Color(0xFFF97316),
      const Color(0xFF84CC16),
      AppColors.secondary,
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  void _showEditDialog(BuildContext context) => showDialog(
    context: context,
    builder: (dialogContext) => BlocProvider.value(
      value: context.read<StudentBloc>(),
      child: StudentFormDialog(student: student),
    ),
  );
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    ),
  );
}

class StudentFormDialog extends StatefulWidget {
  final StudentModel? student;
  const StudentFormDialog({super.key, this.student});
  @override
  State<StudentFormDialog> createState() => _StudentFormDialogState();
}

class _StudentFormDialogState extends State<StudentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController =
      TextEditingController(text: widget.student?.fullName);
  late final TextEditingController _parentNameController =
      TextEditingController(text: widget.student?.parentName);
  late final TextEditingController _phoneController = TextEditingController(
    text: widget.student != null
        ? PhoneValidator.toDisplayFormat(widget.student!.parentPhoneNumber)
        : '+998 ',
  );
  List<GroupModel> _groups = [];
  int? _selectedGroupId;
  String? _groupError;
  bool _submitting = false;
  bool get isEditing => widget.student != null;

  @override
  void initState() {
    super.initState();
    if (!isEditing) {
      _groups = getIt<GroupLocalDataSource>().getAll();
      getIt<GroupRepository>().getAll().then((result) {
        if (mounted && result.$1 != null) setState(() => _groups = result.$1!);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _parentNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickGroup() async {
    final picked = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) =>
          _GroupPickerSheet(groups: _groups, selectedId: _selectedGroupId),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedGroupId = picked;
        _groupError = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedGroup = _selectedGroupId != null
        ? _groups.where((g) => g.id == _selectedGroupId).firstOrNull
        : null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isEditing
                            ? Icons.edit_rounded
                            : Icons.person_add_rounded,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEditing
                                ? 'O\'quvchini tahrirlash'
                                : 'Yangi o\'quvchi',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isEditing
                                ? 'Ma\'lumotlarni yangilash'
                                : 'O\'quvchi ma\'lumotlarini kiriting',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.neutral500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        controller: _nameController,
                        label: 'O\'quvchi ismi',
                        hint: 'To\'liq ismni kiriting',
                        icon: Icons.person_outline_rounded,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Ismni kiriting'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _parentNameController,
                        label: 'Ota-ona ismi (ixtiyoriy)',
                        hint: 'Ota-ona ismini kiriting',
                        icon: Icons.family_restroom_rounded,
                      ),
                      const SizedBox(height: 16),
                      _buildPhoneField(),
                      if (!isEditing) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Guruh',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.neutral700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _pickGroup,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              border: Border.all(
                                color: _groupError != null
                                    ? AppColors.error
                                    : AppColors.neutral300,
                                width: _groupError != null ? 1.5 : 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.groups_rounded,
                                  color: _groupError != null
                                      ? AppColors.error
                                      : AppColors.neutral400,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    selectedGroup?.name ?? 'Guruhni tanlang',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: selectedGroup != null
                                          ? AppColors.neutral900
                                          : AppColors.neutral400,
                                    ),
                                  ),
                                ),
                                Icon(Icons.arrow_drop_down_rounded,
                                    color: AppColors.neutral400),
                              ],
                            ),
                          ),
                        ),
                        if (_groupError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6, left: 12),
                            child: Text(
                              _groupError!,
                              style: TextStyle(
                                  color: AppColors.error, fontSize: 12),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.neutral50,
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            _submitting ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: AppColors.neutral300),
                        ),
                        child: const Text('Bekor qilish'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: _submitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : Text(isEditing ? 'Yangilash' : 'Yaratish'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.neutral700,
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.neutral400),
        ),
      ),
    ],
  );

  Widget _buildPhoneField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Telefon raqami',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.neutral700,
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        inputFormatters: [
          // Remove FilteringTextInputFormatter.digitsOnly
          // Use the new single formatter
          UzbekPhoneNumberFormatter(),
        ],
        // You can keep your validator if it checks the final string length
        validator: (value) {
          if (value == null || value.length < 17) {
            // +998 90 123 45 67 is 17 chars
            return 'Telefon raqamini to\'liq kiriting';
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: '+998 XX XXX XX XX',
          prefixIcon: Icon(Icons.phone_outlined, color: AppColors.neutral400),
          helperText: 'Format: +998 97 123 45 67',
          helperStyle: TextStyle(fontSize: 11, color: AppColors.neutral400),
        ),
      ),
    ],
  );

  void _submit() async {
    final formValid = _formKey.currentState?.validate() ?? false;
    final groupValid = isEditing || _selectedGroupId != null;
    if (!groupValid) setState(() => _groupError = 'Guruhni tanlang');
    if (!formValid || !groupValid) return;

    setState(() => _submitting = true);
    final bloc = context.read<StudentBloc>();
    final parentName = _parentNameController.text.trim().isEmpty
        ? 'Unknown'
        : _parentNameController.text.trim();
    final phoneNumber = _phoneController.text.replaceAll(' ', '');

    if (isEditing) {
      bloc.add(StudentUpdate(
        id: widget.student!.id,
        fullName: _nameController.text.trim(),
        parentName: parentName,
        parentPhoneNumber: phoneNumber,
      ));
    } else {
      bloc.add(StudentCreateWithGroup(
        fullName: _nameController.text.trim(),
        parentName: parentName,
        parentPhoneNumber: phoneNumber,
        groupId: _selectedGroupId,
      ));
    }
    Navigator.pop(context);
  }
}

class UzbekPhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 1. Extract only digits from the input
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    // 2. If the text is empty or just "998", reset to base prefix
    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '+998 ',
        selection: TextSelection.collapsed(offset: 5),
      );
    }

    // 3. Handle the prefix logic
    // We strictly assume the number must start with 998.
    // If the user deleted the prefix, we add it back.
    // If the user typed digits, we ensure 998 is not duplicated.
    String body = digits;
    if (body.startsWith('998')) {
      body = body.substring(3);
    }

    // Limit to 9 digits (standard Uzbek mobile number length)
    if (body.length > 9) {
      body = body.substring(0, 9);
    }

    // 4. Build the formatted string
    final buffer = StringBuffer();
    buffer.write('+998 ');

    if (body.isNotEmpty) {
      // Area code (2 digits) e.g., 90
      buffer.write(body.substring(0, body.length >= 2 ? 2 : body.length));
      if (body.length > 2) buffer.write(' ');
    }

    if (body.length > 2) {
      // Next 3 digits e.g., 123
      buffer.write(body.substring(2, body.length >= 5 ? 5 : body.length));
      if (body.length > 5) buffer.write(' ');
    }

    if (body.length > 5) {
      // Next 2 digits e.g., 45
      buffer.write(body.substring(5, body.length >= 7 ? 7 : body.length));
      if (body.length > 7) buffer.write(' ');
    }

    if (body.length > 7) {
      // Last 2 digits e.g., 67
      buffer.write(body.substring(7));
    }

    final formattedText = buffer.toString();

    // 5. Return the new value with the cursor at the end
    // (Simple implementation; for advanced cursor handling, more logic is needed)
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class _GroupPickerSheet extends StatefulWidget {
  final List<GroupModel> groups;
  final int? selectedId;

  const _GroupPickerSheet({required this.groups, this.selectedId});

  @override
  State<_GroupPickerSheet> createState() => _GroupPickerSheetState();
}

class _GroupPickerSheetState extends State<_GroupPickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _query.isEmpty
        ? widget.groups
        : widget.groups
            .where((g) =>
                g.name.toLowerCase().contains(_query.toLowerCase()) ||
                g.teacherName.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.neutral300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 8, 12),
            child: Row(
              children: [
                Text(
                  'Guruhni tanlang',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral900),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Guruhni qidirish...',
                prefixIcon:
                    Icon(Icons.search_rounded, color: AppColors.neutral400),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          LimitedBox(
            maxHeight: 300,
            child: filtered.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text('Guruh topilmadi',
                          style: TextStyle(color: AppColors.neutral500)),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final group = filtered[i];
                      final isSelected = widget.selectedId == group.id;
                      return ListTile(
                        onTap: () => Navigator.pop(context, group.id),
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              group.name.isNotEmpty
                                  ? group.name[0].toUpperCase()
                                  : 'G',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary),
                            ),
                          ),
                        ),
                        title: Text(group.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(group.teacherName,
                            style: TextStyle(
                                fontSize: 12, color: AppColors.neutral500)),
                        trailing: isSelected
                            ? Icon(Icons.check_rounded,
                                color: AppColors.primary)
                            : null,
                        selected: isSelected,
                        selectedTileColor:
                            AppColors.primary.withValues(alpha: 0.05),
                      );
                    },
                  ),
          ),
          SizedBox(height: 8 + MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

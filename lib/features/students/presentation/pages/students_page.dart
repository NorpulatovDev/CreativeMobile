import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../groups/data/models/group_model.dart';
import '../../../groups/data/repositories/group_repository.dart';
import '../../data/models/student_model.dart';
import '../bloc/student_bloc.dart';

class StudentsPage extends StatelessWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<StudentBloc>()..add(StudentLoadAll()),
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
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.surfaceLight,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: const Text('O\'quvchilar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.neutral900)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.success.withOpacity(0.1), AppColors.surfaceLight]),
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
                  boxShadow: [BoxShadow(color: AppColors.neutral900.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2))],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'O\'quvchilarni qidirish...',
                    hintStyle: TextStyle(color: AppColors.neutral400, fontWeight: FontWeight.w400),
                    prefixIcon: Icon(Icons.search_rounded, color: AppColors.neutral400),
                    suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: Icon(Icons.close_rounded, color: AppColors.neutral400), onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); }) : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),
          ),
          BlocConsumer<StudentBloc, StudentState>(
            listener: (context, state) {
              if (state is StudentError) {
                _showSnackBar(state.message, AppColors.error, Icons.error_outline);
              }
              if (state is StudentActionSuccess) {
                _showSnackBar(state.message, AppColors.success, Icons.check_circle_outline);
              }
            },
            builder: (context, state) {
              if (state is StudentLoading && state is! StudentLoaded) {
                return const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppColors.success)));
              }
              if (state is StudentLoaded) {
                final filteredStudents = _searchQuery.isEmpty ? state.students : state.students.where((s) => s.fullName.toLowerCase().contains(_searchQuery) || s.parentName.toLowerCase().contains(_searchQuery) || s.parentPhoneNumber.contains(_searchQuery)).toList();
                if (state.students.isEmpty) {
                  return SliverFillRemaining(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), shape: BoxShape.circle), child: Icon(Icons.school_rounded, size: 48, color: AppColors.success)), const SizedBox(height: 24), Text('O\'quvchilar yo\'q', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.neutral700, fontWeight: FontWeight.w600)), const SizedBox(height: 8), Text('Birinchi o\'quvchini qo\'shing', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.neutral500))])));
                }
                if (filteredStudents.isEmpty) {
                  return SliverFillRemaining(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: AppColors.neutral100, shape: BoxShape.circle), child: Icon(Icons.search_off_rounded, size: 48, color: AppColors.neutral400)), const SizedBox(height: 24), Text('Natija topilmadi', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.neutral700, fontWeight: FontWeight.w600))])));
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(delegate: SliverChildBuilderDelegate((context, index) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _StudentCard(student: filteredStudents[index])), childCount: filteredStudents.length)),
                );
              }
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => _showStudentDialog(context), backgroundColor: AppColors.success, foregroundColor: Colors.white, elevation: 4, icon: const Icon(Icons.person_add_rounded), label: const Text('Qo\'shish', style: TextStyle(fontWeight: FontWeight.w600))),
    );
  }

  void _showStudentDialog(BuildContext context, [StudentModel? student]) {
    showDialog(context: context, builder: (dialogContext) => BlocProvider.value(value: context.read<StudentBloc>(), child: StudentFormDialog(student: student)));
  }
}

class _StudentCard extends StatelessWidget {
  final StudentModel student;
  const _StudentCard({required this.student});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('${Routes.students}/${student.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.neutral200.withOpacity(0.5)), boxShadow: [BoxShadow(color: AppColors.neutral900.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Stack(children: [
                Container(width: 52, height: 52, decoration: BoxDecoration(color: _getAvatarColor(student.fullName).withOpacity(0.1), borderRadius: BorderRadius.circular(16)), child: Center(child: Text(_getInitials(student.fullName), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _getAvatarColor(student.fullName))))),
                Positioned(right: -2, bottom: -2, child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: student.paidForCurrentMonth ? AppColors.success : AppColors.warning, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)), child: Icon(student.paidForCurrentMonth ? Icons.check : Icons.schedule, size: 10, color: Colors.white))),
              ]),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(student.fullName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)), const SizedBox(height: 2), Row(children: [Icon(Icons.person_outline_rounded, size: 14, color: AppColors.neutral400), const SizedBox(width: 4), Expanded(child: Text(student.parentName, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.neutral500), overflow: TextOverflow.ellipsis))])])),
              PopupMenuButton<String>(icon: Icon(Icons.more_vert_rounded, color: AppColors.neutral400), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), onSelected: (value) { if (value == 'edit') _showEditDialog(context); }, itemBuilder: (context) => [PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_rounded, size: 20, color: AppColors.neutral600), const SizedBox(width: 12), const Text('Tahrirlash')]))]),
            ]),
            const SizedBox(height: 14),
            SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [_InfoChip(icon: Icons.phone_outlined, label: student.parentPhoneNumber, color: AppColors.neutral600), const SizedBox(width: 8), _InfoChip(icon: Icons.groups_rounded, label: '${student.activeGroupsCount} guruh', color: AppColors.primary), const SizedBox(width: 8), if (student.groupsPaidCount > 0) _InfoChip(icon: Icons.check_circle_rounded, label: '${student.groupsPaidCount} to\'langan', color: AppColors.success), if (student.groupsUnpaidCount > 0) ...[const SizedBox(width: 8), _InfoChip(icon: Icons.schedule_rounded, label: '${student.groupsUnpaidCount} to\'lanmagan', color: AppColors.warning)]])),
            if (student.activeGroups.isNotEmpty) ...[const SizedBox(height: 12), Wrap(spacing: 6, runSpacing: 6, children: student.activeGroups.map((g) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: AppColors.primaryContainer.withOpacity(0.5), borderRadius: BorderRadius.circular(8)), child: Text(g.groupName, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primary)))).toList())],
          ]),
        ),
      ),
    );
  }

  String _getInitials(String name) => name.isNotEmpty ? name.split(' ').take(2).map((e) => e.isNotEmpty ? e[0] : '').join().toUpperCase() : '?';
  Color _getAvatarColor(String name) { final colors = [AppColors.primary, AppColors.success, AppColors.warning, const Color(0xFF8B5CF6), const Color(0xFF06B6D4), const Color(0xFFF97316), const Color(0xFF84CC16), AppColors.secondary]; return colors[name.hashCode.abs() % colors.length]; }
  void _showEditDialog(BuildContext context) => showDialog(context: context, builder: (dialogContext) => BlocProvider.value(value: context.read<StudentBloc>(), child: StudentFormDialog(student: student)));
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 14, color: color), const SizedBox(width: 5), Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color))]));
}

class StudentFormDialog extends StatefulWidget {
  final StudentModel? student;
  const StudentFormDialog({super.key, this.student});
  @override
  State<StudentFormDialog> createState() => _StudentFormDialogState();
}

class _StudentFormDialogState extends State<StudentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController = TextEditingController(text: widget.student?.fullName);
  late final TextEditingController _parentNameController = TextEditingController(text: widget.student?.parentName);
  late final TextEditingController _phoneController = TextEditingController(text: widget.student?.parentPhoneNumber);
  List<GroupModel> _groups = [];
  int? _selectedGroupId;
  bool _loadingGroups = true;
  bool _submitting = false;
  bool get isEditing => widget.student != null;

  @override
  void initState() { super.initState(); if (!isEditing) _loadGroups(); else _loadingGroups = false; }
  Future<void> _loadGroups() async { final (groups, _) = await getIt<GroupRepository>().getAll(); if (mounted) setState(() { _groups = groups ?? []; _loadingGroups = false; }); }
  @override
  void dispose() { _nameController.dispose(); _parentNameController.dispose(); _phoneController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
            child: Row(children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.success.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Icon(isEditing ? Icons.edit_rounded : Icons.person_add_rounded, color: AppColors.success)),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(isEditing ? 'O\'quvchini tahrirlash' : 'Yangi o\'quvchi', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)), const SizedBox(height: 4), Text(isEditing ? 'Ma\'lumotlarni yangilash' : 'O\'quvchi ma\'lumotlarini kiriting', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.neutral500))])),
            ]),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _loadingGroups ? const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())) : Form(key: _formKey, child: Column(children: [
                _buildTextField(controller: _nameController, label: 'O\'quvchi ismi', hint: 'To\'liq ismni kiriting', icon: Icons.person_outline_rounded, validator: (v) => v == null || v.trim().isEmpty ? 'Ismni kiriting' : null),
                const SizedBox(height: 16),
                _buildTextField(controller: _parentNameController, label: 'Ota-ona ismi', hint: 'Ota-ona ismini kiriting', icon: Icons.family_restroom_rounded, validator: (v) => v == null || v.trim().isEmpty ? 'Ota-ona ismini kiriting' : null),
                const SizedBox(height: 16),
                _buildTextField(controller: _phoneController, label: 'Telefon raqami', hint: '+998XXXXXXXXX', icon: Icons.phone_outlined, keyboardType: TextInputType.phone, validator: (v) { if (v == null || v.trim().isEmpty) return 'Telefon raqamini kiriting'; if (!RegExp(r'^\+998[0-9]{9}$').hasMatch(v)) return 'Format: +998XXXXXXXXX'; return null; }),
                if (!isEditing && _groups.isNotEmpty) ...[const SizedBox(height: 16), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Guruhga qo\'shish (ixtiyoriy)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.neutral700)), const SizedBox(height: 8), DropdownButtonFormField<int?>(value: _selectedGroupId, decoration: InputDecoration(prefixIcon: Icon(Icons.groups_rounded, color: AppColors.neutral400)), items: [const DropdownMenuItem<int?>(value: null, child: Text('Guruhsiz')), ..._groups.map((g) => DropdownMenuItem<int?>(value: g.id, child: Text(g.name)))], onChanged: (v) => setState(() => _selectedGroupId = v))])],
              ])),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppColors.neutral50, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24))),
            child: Row(children: [
              Expanded(child: OutlinedButton(onPressed: _submitting ? null : () => Navigator.pop(context), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: BorderSide(color: AppColors.neutral300)), child: const Text('Bekor qilish'))),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(onPressed: _loadingGroups || _submitting ? null : _submit, style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)), child: _submitting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(isEditing ? 'Yangilash' : 'Yaratish'))),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required String hint, required IconData icon, TextInputType? keyboardType, String? Function(String?)? validator}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.neutral700)), const SizedBox(height: 8), TextFormField(controller: controller, keyboardType: keyboardType, validator: validator, decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon, color: AppColors.neutral400)))]);

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _submitting = true);
      final bloc = context.read<StudentBloc>();
      if (isEditing) { bloc.add(StudentUpdate(id: widget.student!.id, fullName: _nameController.text.trim(), parentName: _parentNameController.text.trim(), parentPhoneNumber: _phoneController.text.trim())); }
      else { bloc.add(StudentCreateWithGroup(fullName: _nameController.text.trim(), parentName: _parentNameController.text.trim(), parentPhoneNumber: _phoneController.text.trim(), groupId: _selectedGroupId)); }
      Navigator.pop(context);
    }
  }
}
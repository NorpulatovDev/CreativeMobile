import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../teachers/data/models/teacher_model.dart';
import '../../../teachers/data/repositories/teacher_repository.dart';
import '../../data/models/group_model.dart';
import '../bloc/group_bloc.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<GroupBloc>()..add(GroupLoadAll()),
      child: const GroupsView(),
    );
  }
}

class GroupsView extends StatefulWidget {
  const GroupsView({super.key});

  @override
  State<GroupsView> createState() => _GroupsViewState();
}

class _GroupsViewState extends State<GroupsView> {
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
              title: const Text('Guruhlar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.neutral900)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.primary.withOpacity(0.1), AppColors.surfaceLight]),
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
                    hintText: 'Guruhlarni qidirish...',
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
          BlocConsumer<GroupBloc, GroupState>(
            listener: (context, state) {
              if (state is GroupError) {
                _showSnackBar(state.message, AppColors.error, Icons.error_outline);
              }
              if (state is GroupActionSuccess) {
                _showSnackBar(state.message, AppColors.success, Icons.check_circle_outline);
              }
            },
            builder: (context, state) {
              if (state is GroupLoading && state is! GroupLoaded) {
                return const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppColors.primary)));
              }
              if (state is GroupLoaded) {
                final filteredGroups = _searchQuery.isEmpty ? state.groups : state.groups.where((g) => g.name.toLowerCase().contains(_searchQuery) || g.teacherName.toLowerCase().contains(_searchQuery)).toList();
                if (state.groups.isEmpty) {
                  return SliverFillRemaining(child: _buildEmptyState(context));
                }
                if (filteredGroups.isEmpty) {
                  return SliverFillRemaining(child: _buildNoResultsState(context));
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(delegate: SliverChildBuilderDelegate((context, index) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _GroupCard(group: filteredGroups[index])), childCount: filteredGroups.length)),
                );
              }
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showGroupDialog(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.group_add_rounded),
        label: const Text('Qo\'shish', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.groups_rounded, size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          Text('Guruhlar yo\'q', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.neutral700, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Birinchi guruhni qo\'shing', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.neutral500)),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppColors.neutral100, shape: BoxShape.circle),
            child: Icon(Icons.search_off_rounded, size: 48, color: AppColors.neutral400),
          ),
          const SizedBox(height: 24),
          Text('Natija topilmadi', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.neutral700, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showGroupDialog(BuildContext context, [GroupModel? group]) {
    showDialog(context: context, builder: (dialogContext) => BlocProvider.value(value: context.read<GroupBloc>(), child: GroupFormDialog(group: group)));
  }
}

class _GroupCard extends StatelessWidget {
  final GroupModel group;
  const _GroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final debt = group.totalAmountToPay - group.totalPaid;
    final isDebt = debt > 0;
    final progress = group.totalAmountToPay > 0 ? (group.totalPaid / group.totalAmountToPay).clamp(0.0, 1.0) : 0.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('${Routes.groups}/${group.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.neutral200.withOpacity(0.5)),
            boxShadow: [BoxShadow(color: AppColors.neutral900.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _getGroupColor(group.name).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        group.name.isNotEmpty ? group.name[0].toUpperCase() : 'G',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _getGroupColor(group.name)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(group.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.person_outline_rounded, size: 14, color: AppColors.neutral400),
                            const SizedBox(width: 4),
                            Expanded(child: Text(group.teacherName, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.neutral500), overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert_rounded, color: AppColors.neutral400),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onSelected: (value) {
                      if (value == 'edit') _showEditDialog(context);
                      else if (value == 'delete') _showDeleteDialog(context);
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_rounded, size: 20, color: AppColors.neutral600), const SizedBox(width: 12), const Text('Tahrirlash')])),
                      PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_rounded, size: 20, color: AppColors.error), const SizedBox(width: 12), Text('O\'chirish', style: TextStyle(color: AppColors.error))])),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _InfoChip(icon: Icons.people_outline_rounded, label: '${group.studentsCount} o\'quvchi', color: AppColors.primary),
                  const SizedBox(width: 8),
                  _InfoChip(icon: Icons.payments_outlined, label: '${group.monthlyFee.toStringAsFixed(0)} so\'m/oy', color: AppColors.neutral600),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('To\'langan: ${group.totalPaid.toStringAsFixed(0)} so\'m', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.neutral500)),
                            Text('${(progress * 100).toStringAsFixed(0)}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: AppColors.neutral200,
                            valueColor: AlwaysStoppedAnimation<Color>(isDebt ? AppColors.warning : AppColors.success),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDebt ? AppColors.errorLight : AppColors.successLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      isDebt ? '-${debt.toStringAsFixed(0)}' : '+${(-debt).toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDebt ? AppColors.error : AppColors.success),
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

  Color _getGroupColor(String name) {
    final colors = [AppColors.primary, AppColors.success, AppColors.warning, const Color(0xFF8B5CF6), const Color(0xFF06B6D4), const Color(0xFFF97316), AppColors.secondary];
    return colors[name.hashCode.abs() % colors.length];
  }

  void _showEditDialog(BuildContext context) => showDialog(context: context, builder: (dialogContext) => BlocProvider.value(value: context.read<GroupBloc>(), child: GroupFormDialog(group: group)));

  void _showDeleteDialog(BuildContext context) {
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
                decoration: BoxDecoration(color: AppColors.errorLight, shape: BoxShape.circle),
                child: Icon(Icons.delete_outline_rounded, size: 32, color: AppColors.error),
              ),
              const SizedBox(height: 20),
              Text('Guruhni o\'chirish', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Text('${group.name} guruhini o\'chirishni xohlaysizmi? Barcha davomat va to\'lov yozuvlari ham o\'chiriladi.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.neutral500)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(dialogContext), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: BorderSide(color: AppColors.neutral300)), child: const Text('Bekor qilish'))),
                  const SizedBox(width: 12),
                  Expanded(child: ElevatedButton(onPressed: () { context.read<GroupBloc>().add(GroupDelete(group.id)); Navigator.pop(dialogContext); }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)), child: const Text('O\'chirish'))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 14, color: color), const SizedBox(width: 5), Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color))]),
  );
}

class GroupFormDialog extends StatefulWidget {
  final GroupModel? group;
  const GroupFormDialog({super.key, this.group});
  @override
  State<GroupFormDialog> createState() => _GroupFormDialogState();
}

class _GroupFormDialogState extends State<GroupFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController = TextEditingController(text: widget.group?.name);
  late final TextEditingController _feeController = TextEditingController(text: widget.group?.monthlyFee.toStringAsFixed(0));
  int? _selectedTeacherId;
  List<TeacherModel> _teachers = [];
  bool _loadingTeachers = true;
  bool _submitting = false;
  bool get isEditing => widget.group != null;

  @override
  void initState() {
    super.initState();
    _selectedTeacherId = widget.group?.teacherId;
    _loadTeachers();
  }

  Future<void> _loadTeachers() async {
    final (teachers, _) = await getIt<TeacherRepository>().getAll();
    if (mounted) setState(() { _teachers = teachers ?? []; _loadingTeachers = false; });
  }

  @override
  void dispose() { _nameController.dispose(); _feeController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
              child: Row(children: [
                Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Icon(isEditing ? Icons.edit_rounded : Icons.group_add_rounded, color: AppColors.primary)),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(isEditing ? 'Guruhni tahrirlash' : 'Yangi guruh', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)), const SizedBox(height: 4), Text(isEditing ? 'Guruh ma\'lumotlarini yangilash' : 'Guruh ma\'lumotlarini kiriting', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.neutral500))])),
              ]),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _loadingTeachers
                    ? const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))
                    : Form(
                        key: _formKey,
                        child: Column(children: [
                          _buildTextField(controller: _nameController, label: 'Guruh nomi', hint: 'Masalan: Ingliz tili A1', icon: Icons.group_outlined, validator: (v) => v == null || v.trim().isEmpty ? 'Guruh nomini kiriting' : null),
                          const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('O\'qituvchi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.neutral700)),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<int>(
                                value: _selectedTeacherId,
                                decoration: InputDecoration(prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.neutral400)),
                                items: _teachers.map((t) => DropdownMenuItem(value: t.id, child: Text(t.fullName))).toList(),
                                onChanged: (v) => setState(() => _selectedTeacherId = v),
                                validator: (v) => v == null ? 'O\'qituvchini tanlang' : null,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(controller: _feeController, label: 'Oylik to\'lov (so\'m)', hint: 'Masalan: 500000', icon: Icons.payments_outlined, keyboardType: TextInputType.number, validator: (v) { if (v == null || v.trim().isEmpty) return 'To\'lov miqdorini kiriting'; if (double.tryParse(v) == null || double.parse(v) <= 0) return 'To\'g\'ri miqdor kiriting'; return null; }),
                        ]),
                      ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AppColors.neutral50, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24))),
              child: Row(children: [
                Expanded(child: OutlinedButton(onPressed: _submitting ? null : () => Navigator.pop(context), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: BorderSide(color: AppColors.neutral300)), child: const Text('Bekor qilish'))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(onPressed: _loadingTeachers || _submitting ? null : _submit, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)), child: _submitting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(isEditing ? 'Yangilash' : 'Yaratish'))),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required String hint, required IconData icon, TextInputType? keyboardType, String? Function(String?)? validator}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.neutral700)), const SizedBox(height: 8), TextFormField(controller: controller, keyboardType: keyboardType, validator: validator, decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon, color: AppColors.neutral400)))]);

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _submitting = true);
      final bloc = context.read<GroupBloc>();
      if (isEditing) { bloc.add(GroupUpdate(id: widget.group!.id, name: _nameController.text.trim(), teacherId: _selectedTeacherId!, monthlyFee: double.parse(_feeController.text.trim()))); }
      else { bloc.add(GroupCreate(name: _nameController.text.trim(), teacherId: _selectedTeacherId!, monthlyFee: double.parse(_feeController.text.trim()))); }
      Navigator.pop(context);
    }
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../branches/data/models/branch_model.dart';
import '../../../branches/data/repositories/branch_repository.dart';
import '../../data/models/admin_model.dart';
import '../bloc/admin_bloc.dart';

class AdminsPage extends StatelessWidget {
  const AdminsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminBloc>()..add(AdminLoadAll()),
      child: const _AdminsView(),
    );
  }
}

class _AdminsView extends StatelessWidget {
  const _AdminsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Adminlar'),
        backgroundColor: AppColors.gradientStart,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocConsumer<AdminBloc, AdminState>(
        listener: (context, state) {
          if (state is AdminError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
          if (state is AdminActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AdminLoaded) {
            if (state.admins.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.admin_panel_settings_outlined,
                        size: 72, color: AppColors.neutral400),
                    const SizedBox(height: 16),
                    Text("Hali adminlar yo'q",
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: () => _showAdminDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text("Admin qo'shish"),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<AdminBloc>().add(AdminLoadAll()),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.admins.length,
                itemBuilder: (context, index) =>
                    _AdminCard(admin: state.admins[index]),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAdminDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAdminDialog(BuildContext context, [AdminModel? admin]) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<AdminBloc>(),
        child: AdminFormDialog(admin: admin),
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  final AdminModel admin;

  const _AdminCard({required this.admin});

  @override
  Widget build(BuildContext context) {
    final isSuperAdmin = admin.isSuperAdmin;
    final roleColor = isSuperAdmin ? const Color(0xFFEC4899) : AppColors.primary;
    final roleLabel = isSuperAdmin ? 'Super Admin' : 'Filial Admin';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: roleColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.person_rounded, color: roleColor),
        ),
        title: Text(
          admin.username,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: roleColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    roleLabel,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: roleColor),
                  ),
                ),
                if (admin.branchName != null) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.business_outlined,
                      size: 13, color: AppColors.neutral500),
                  const SizedBox(width: 4),
                  Text(admin.branchName!,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.neutral600)),
                ],
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              _showEditDialog(context);
            } else if (value == 'delete') {
              _showDeleteDialog(context);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Tahrirlash')),
            PopupMenuItem(value: 'delete', child: Text("O'chirish")),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<AdminBloc>(),
        child: AdminFormDialog(admin: admin),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Adminni o'chirish"),
        content: Text(
            "${admin.username} adminini o'chirishni tasdiqlaysizmi?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Bekor qilish'),
          ),
          FilledButton(
            onPressed: () {
              context.read<AdminBloc>().add(AdminDelete(admin.id));
              Navigator.pop(dialogContext);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text("O'chirish"),
          ),
        ],
      ),
    );
  }
}

class AdminFormDialog extends StatefulWidget {
  final AdminModel? admin;

  const AdminFormDialog({super.key, this.admin});

  @override
  State<AdminFormDialog> createState() => _AdminFormDialogState();
}

class _AdminFormDialogState extends State<AdminFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late String _selectedRole;
  int? _selectedBranchId;
  List<BranchModel> _branches = [];
  bool _loadingBranches = false;

  bool get isEditing => widget.admin != null;

  @override
  void initState() {
    super.initState();
    _usernameController =
        TextEditingController(text: widget.admin?.username ?? '');
    _passwordController = TextEditingController();
    _selectedRole = widget.admin?.role ?? 'BRANCH_ADMIN';
    _selectedBranchId = widget.admin?.branchId;
    _loadBranches();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadBranches() async {
    setState(() => _loadingBranches = true);
    final (branches, _) = await getIt<BranchRepository>().getAll();
    if (mounted) {
      setState(() {
        _branches = branches ?? [];
        _loadingBranches = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditing ? 'Adminni tahrirlash' : "Admin qo'shish"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Foydalanuvchi nomi',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Foydalanuvchi nomini kiriting'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: isEditing ? 'Yangi parol (6+ belgi)' : 'Parol',
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Parol kiriting';
                  }
                  if (v.trim().length < 6) {
                    return 'Parol kamida 6 ta belgi bo\'lishi kerak';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Rol',
                  prefixIcon: Icon(Icons.admin_panel_settings_outlined),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'BRANCH_ADMIN', child: Text('Filial Admin')),
                  DropdownMenuItem(
                      value: 'SUPER_ADMIN', child: Text('Super Admin')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedRole = value;
                      if (value == 'SUPER_ADMIN') {
                        _selectedBranchId = null;
                      }
                    });
                  }
                },
              ),
              if (_selectedRole == 'BRANCH_ADMIN') ...[
                const SizedBox(height: 12),
                _loadingBranches
                    ? const Center(child: CircularProgressIndicator())
                    : DropdownButtonFormField<int>(
                        initialValue: _selectedBranchId,
                        decoration: const InputDecoration(
                          labelText: 'Filial',
                          prefixIcon: Icon(Icons.business_outlined),
                        ),
                        items: _branches
                            .map((b) => DropdownMenuItem(
                                value: b.id, child: Text(b.name)))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedBranchId = value),
                        validator: (v) => v == null ? 'Filial tanlang' : null,
                      ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Bekor qilish'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(isEditing ? 'Saqlash' : "Qo'shish"),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final bloc = context.read<AdminBloc>();
      if (isEditing) {
        bloc.add(AdminUpdate(
          id: widget.admin!.id,
          username: _usernameController.text.trim(),
          password: _passwordController.text.trim(),
          role: _selectedRole,
          branchId: _selectedRole == 'BRANCH_ADMIN' ? _selectedBranchId : null,
        ));
      } else {
        bloc.add(AdminCreate(
          username: _usernameController.text.trim(),
          password: _passwordController.text.trim(),
          role: _selectedRole,
          branchId: _selectedRole == 'BRANCH_ADMIN' ? _selectedBranchId : null,
        ));
      }
      Navigator.pop(context);
    }
  }
}

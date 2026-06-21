import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/branch_model.dart';
import '../bloc/branch_bloc.dart';

class BranchesPage extends StatelessWidget {
  const BranchesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BranchBloc>()..add(BranchLoadAll()),
      child: const _BranchesView(),
    );
  }
}

class _BranchesView extends StatelessWidget {
  const _BranchesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Filiallar'),
        backgroundColor: AppColors.gradientStart,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocConsumer<BranchBloc, BranchState>(
        listener: (context, state) {
          if (state is BranchError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
          if (state is BranchActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is BranchLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is BranchLoaded) {
            if (state.branches.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.business_outlined, size: 72,
                        color: AppColors.neutral400),
                    const SizedBox(height: 16),
                    Text('Hali filiallar yo\'q',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: () => _showBranchDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Filial qo\'shish'),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<BranchBloc>().add(BranchLoadAll()),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.branches.length,
                itemBuilder: (context, index) =>
                    _BranchCard(branch: state.branches[index]),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBranchDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showBranchDialog(BuildContext context, [BranchModel? branch]) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<BranchBloc>(),
        child: BranchFormDialog(branch: branch),
      ),
    );
  }
}

class _BranchCard extends StatelessWidget {
  final BranchModel branch;

  const _BranchCard({required this.branch});

  @override
  Widget build(BuildContext context) {
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
            color: AppColors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.business_rounded, color: AppColors.primary),
        ),
        title: Text(
          branch.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (branch.address != null && branch.address!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.location_on_outlined, size: 14,
                    color: AppColors.neutral500),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(branch.address!,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.neutral600)),
                ),
              ]),
            ],
            if (branch.phoneNumber != null && branch.phoneNumber!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Row(children: [
                const Icon(Icons.phone_outlined, size: 14,
                    color: AppColors.neutral500),
                const SizedBox(width: 4),
                Text(branch.phoneNumber!,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.neutral600)),
              ]),
            ],
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
            PopupMenuItem(value: 'delete', child: Text('O\'chirish')),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<BranchBloc>(),
        child: BranchFormDialog(branch: branch),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Filialni o\'chirish'),
        content: Text(
            '${branch.name} filialini o\'chirishni tasdiqlaysizmi?\n\nBu amalni bekor qilib bo\'lmaydi.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Bekor qilish'),
          ),
          FilledButton(
            onPressed: () {
              context.read<BranchBloc>().add(BranchDelete(branch.id));
              Navigator.pop(dialogContext);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('O\'chirish'),
          ),
        ],
      ),
    );
  }
}

class BranchFormDialog extends StatefulWidget {
  final BranchModel? branch;

  const BranchFormDialog({super.key, this.branch});

  @override
  State<BranchFormDialog> createState() => _BranchFormDialogState();
}

class _BranchFormDialogState extends State<BranchFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;

  bool get isEditing => widget.branch != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.branch?.name);
    _addressController = TextEditingController(text: widget.branch?.address);
    _phoneController = TextEditingController(text: widget.branch?.phoneNumber);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditing ? 'Filialni tahrirlash' : 'Filial qo\'shish'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Filial nomi',
                prefixIcon: Icon(Icons.business_outlined),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Filial nomini kiriting' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Manzil (ixtiyoriy)',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Telefon (ixtiyoriy)',
                prefixIcon: Icon(Icons.phone_outlined),
                hintText: '+998XXXXXXXXX',
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Bekor qilish'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(isEditing ? 'Saqlash' : 'Qo\'shish'),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final bloc = context.read<BranchBloc>();
      final name = _nameController.text.trim();
      final address = _addressController.text.trim();
      final phone = _phoneController.text.trim();
      if (isEditing) {
        bloc.add(BranchUpdate(
          id: widget.branch!.id,
          name: name,
          address: address.isNotEmpty ? address : null,
          phoneNumber: phone.isNotEmpty ? phone : null,
        ));
      } else {
        bloc.add(BranchCreate(
          name: name,
          address: address.isNotEmpty ? address : null,
          phoneNumber: phone.isNotEmpty ? phone : null,
        ));
      }
      Navigator.pop(context);
    }
  }
}

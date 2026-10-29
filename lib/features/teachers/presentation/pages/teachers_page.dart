import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/branch/branch_selection_cubit.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/phone_formatter.dart';
import '../../../../core/utils/uzbek_phone_formatter.dart';
import '../../data/models/teacher_model.dart';
import '../bloc/teacher_bloc.dart';

class TeachersPage extends StatelessWidget {
  const TeachersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final branchId = context.watch<BranchSelectionCubit>().state.selectedBranchId;
    return KeyedSubtree(
      key: ValueKey(branchId),
      child: BlocProvider(
        create: (_) => getIt<TeacherBloc>()..add(TeacherLoadAll()),
        child: const TeachersView(),
      ),
    );
  }
}

class TeachersView extends StatefulWidget {
  const TeachersView({super.key});

  @override
  State<TeachersView> createState() => _TeachersViewState();
}

class _TeachersViewState extends State<TeachersView> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teachers'),
      ),
      body: BlocConsumer<TeacherBloc, TeacherState>(
        listenWhen: (_, curr) =>
            curr is TeacherError ||
            curr is TeacherActionSuccess ||
            curr is TeacherSamePersonConfirmationRequired,
        buildWhen: (_, curr) =>
            curr is! TeacherActionSuccess &&
            curr is! TeacherSamePersonConfirmationRequired,
        listener: (context, state) {
          if (state is TeacherSamePersonConfirmationRequired) {
            _confirmSamePerson(context, state);
          }
          if (state is TeacherError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
          if (state is TeacherActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is TeacherLoading && state is! TeacherLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TeacherLoaded) {
            if (state.teachers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_off_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No teachers yet',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () => _showTeacherDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Teacher'),
                    ),
                  ],
                ),
              );
            }
            final q = _query.trim().toLowerCase();
            final filtered = q.isEmpty
                ? state.teachers
                : state.teachers
                    .where((t) =>
                        t.fullName.toLowerCase().contains(q) ||
                        t.phoneNumber.toLowerCase().contains(q))
                    .toList();
            return Column(
              children: [
                _buildSearchBar(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<TeacherBloc>().add(TeacherLoadAll());
                    },
                    child: filtered.isEmpty
                        ? _buildNoResults(context)
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              return _TeacherCard(teacher: filtered[index]);
                            },
                          ),
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTeacherDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.neutral200),
          boxShadow: [
            BoxShadow(
              color: AppColors.neutral900.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _query = value),
          decoration: InputDecoration(
            hintText: 'O\'qituvchilarni qidirish...',
            hintStyle: TextStyle(
              color: AppColors.neutral400,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(Icons.search_rounded, color: AppColors.neutral400),
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close_rounded, color: AppColors.neutral400),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildNoResults(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        Center(
          child: Column(
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 56,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 12),
              Text(
                'Natija topilmadi',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                '"${_searchController.text}" bo\'yicha o\'qituvchi yo\'q',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// The phone number entered already belongs to another teacher. On the backend
  /// that number IS the teacher's identity, so going ahead makes them one person:
  /// a single login, and each seeing the other's groups. Right for one teacher
  /// working in several branches, wrong for two people sharing a phone — only the
  /// admin knows which, so it is never assumed.
  void _confirmSamePerson(
    BuildContext context,
    TeacherSamePersonConfirmationRequired state,
  ) {
    final bloc = context.read<TeacherBloc>();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.people_outline),
        title: const Text('Bir xil o\'qituvchimi?'),
        content: Text(state.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Bekor qilish'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              bloc.add(state.retryEvent);
            },
            child: const Text('Ha, bir xil odam'),
          ),
        ],
      ),
    );
  }

  void _showTeacherDialog(BuildContext context, [TeacherModel? teacher]) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<TeacherBloc>(),
        child: TeacherFormDialog(teacher: teacher),
      ),
    );
  }
}

class _TeacherCard extends StatelessWidget {
  final TeacherModel teacher;

  const _TeacherCard({required this.teacher});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            teacher.fullName.substring(0, 1).toUpperCase(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        title: Text(teacher.fullName),
        subtitle: Row(
          children: [
            Text(teacher.phoneNumber),
            const SizedBox(width: 8),
            Icon(
              teacher.hasLogin ? Icons.lock_open : Icons.lock_outline,
              size: 14,
              color: teacher.hasLogin
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).disabledColor,
            ),
            const SizedBox(width: 2),
            Text(
              teacher.hasLogin ? 'Login bor' : 'Login yo\'q',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: teacher.hasLogin
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).disabledColor,
                  ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Income',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '${teacher.totalIncome.toStringAsFixed(0)} UZS',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditDialog(context);
                } else if (value == 'delete') {
                  _showDeleteDialog(context);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
        onTap: () => context.push('${Routes.teachers}/${teacher.id}'),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<TeacherBloc>(),
        child: TeacherFormDialog(teacher: teacher),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Teacher'),
        content: Text('Are you sure you want to delete ${teacher.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<TeacherBloc>().add(TeacherDelete(teacher.id));
              Navigator.pop(dialogContext);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class TeacherFormDialog extends StatefulWidget {
  final TeacherModel? teacher;

  const TeacherFormDialog({super.key, this.teacher});

  @override
  State<TeacherFormDialog> createState() => _TeacherFormDialogState();
}

class _TeacherFormDialogState extends State<TeacherFormDialog> {
  static final _phoneRegExp = RegExp(r'^\+998[0-9]{9}$');

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;

  bool get isEditing => widget.teacher != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.teacher?.fullName);
    _phoneController = TextEditingController(
      text: widget.teacher != null
          ? PhoneValidator.toDisplayFormat(widget.teacher!.phoneNumber)
          : '+998 ',
    );
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditing ? 'Edit Teacher' : 'Add Teacher'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter full name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone_outlined),
                hintText: '+998 XX XXX XX XX',
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [UzbekPhoneNumberFormatter()],
              validator: (value) {
                final digits = (value ?? '').replaceAll(' ', '');
                if (digits.isEmpty || digits == '+998') {
                  return 'Please enter phone number';
                }
                if (!_phoneRegExp.hasMatch(digits)) {
                  return 'Format: +998 XX XXX XX XX';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: isEditing
                    ? (widget.teacher?.hasLogin ?? false
                        ? 'Yangi parol'
                        : 'Parol')
                    : 'Parol',
                prefixIcon: const Icon(Icons.lock_outline),
                // The login username IS the phone number; setting a password
                // enables (or resets) the teacher's login. Blank keeps it as-is.
                helperText: isEditing && (widget.teacher?.hasLogin ?? false)
                    ? "Bo'sh qoldirilsa, parol o'zgarmaydi. Login: telefon raqami"
                    : "Parol kiriting — o'qituvchi telefon raqami bilan kiradi",
              ),
              obscureText: true,
            ),
          ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(isEditing ? 'Update' : 'Create'),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final bloc = context.read<TeacherBloc>();
      final password = _passwordController.text;
      final passwordArg = password.isEmpty ? null : password;
      // Username is always the phone number: leave it null so the backend
      // defaults the login username to the teacher's phone number.
      if (isEditing) {
        bloc.add(TeacherUpdate(
          id: widget.teacher!.id,
          fullName: _nameController.text.trim(),
          phoneNumber: _phoneController.text.replaceAll(' ', ''),
          username: null,
          password: passwordArg,
        ));
      } else {
        bloc.add(TeacherCreate(
          fullName: _nameController.text.trim(),
          phoneNumber: _phoneController.text.replaceAll(' ', ''),
          username: null,
          password: passwordArg,
        ));
      }
      Navigator.pop(context);
    }
  }
}
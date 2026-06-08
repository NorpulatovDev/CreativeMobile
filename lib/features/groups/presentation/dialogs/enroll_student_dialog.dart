import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/uzbek_phone_formatter.dart';
import '../../../students/data/models/student_model.dart';
import '../bloc/enroll_student_cubit.dart';

class EnrollStudentDialog extends StatefulWidget {
  final VoidCallback onEnrolled;
  final ValueChanged<String> onError;

  const EnrollStudentDialog({
    super.key,
    required this.onEnrolled,
    required this.onError,
  });

  @override
  State<EnrollStudentDialog> createState() => _EnrollStudentDialogState();
}

class _EnrollStudentDialogState extends State<EnrollStudentDialog> {
  bool _showForm = false;
  String _prefillName = '';

  void _openForm(String name) => setState(() {
        _showForm = true;
        _prefillName = name;
      });

  void _backToSearch() {
    context.read<EnrollStudentCubit>().reset();
    setState(() => _showForm = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EnrollStudentCubit, EnrollStudentState>(
      listener: (context, state) {
        if (state is EnrollStudentSuccess) {
          Navigator.pop(context);
          widget.onEnrolled();
        } else if (state is EnrollStudentError) {
          Navigator.pop(context);
          widget.onError(state.message);
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        clipBehavior: Clip.hardEdge,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450, maxHeight: 620),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            transitionBuilder: _slideTransition,
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.topCenter,
              children: [...previous, if (current != null) current],
            ),
            child: _showForm
                ? _NewStudentForm(
                    key: const ValueKey('form'),
                    prefillName: _prefillName,
                    onBack: _backToSearch,
                  )
                : _SearchView(
                    key: const ValueKey('search'),
                    onAddNew: _openForm,
                  ),
          ),
        ),
      ),
    );
  }

  static Widget _slideTransition(Widget child, Animation<double> animation) {
    final isForm = child.key == const ValueKey('form');
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(isForm ? 1.0 : -1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: child,
    );
  }
}

// ─── Search view ──────────────────────────────────────────────────────────────

class _SearchView extends StatefulWidget {
  final ValueChanged<String> onAddNew;

  const _SearchView({super.key, required this.onAddNew});

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _DialogHeader(
          icon: Icons.person_search_rounded,
          color: AppColors.success,
          title: 'O\'quvchi qo\'shish',
          subtitle: 'Mavjud o\'quvchini qidiring yoki yangi qo\'shing',
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: TextField(
            controller: _controller,
            autofocus: true,
            onChanged: (v) => context.read<EnrollStudentCubit>().search(v),
            decoration: InputDecoration(
              hintText: 'Ism yoki telefon raqam...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        _controller.clear();
                        context.read<EnrollStudentCubit>().search('');
                      },
                    )
                  : null,
            ),
          ),
        ),
        Flexible(child: _SearchResults(currentQuery: _controller.text)),
        _AddNewButton(
          onTap: () => widget.onAddNew(_controller.text.trim()),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _SearchResults extends StatelessWidget {
  final String currentQuery;

  const _SearchResults({required this.currentQuery});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EnrollStudentCubit, EnrollStudentState>(
      builder: (context, state) {
        if (state is EnrollStudentIdle) {
          return _Prompt(
            icon: Icons.manage_search_rounded,
            text: 'Qidirish uchun kamida 2 ta harf kiriting',
          );
        }
        if (state is EnrollStudentSearching || state is EnrollStudentEnrolling) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 28),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.success),
            ),
          );
        }
        if (state is EnrollStudentResults) {
          if (state.students.isEmpty) {
            return _Prompt(
              icon: Icons.person_off_outlined,
              text: '"${state.query}" bo\'yicha hech kim topilmadi',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            shrinkWrap: true,
            itemCount: state.students.length,
            itemBuilder: (context, i) =>
                _StudentTile(student: state.students[i]),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _StudentTile extends StatelessWidget {
  final StudentModel student;

  const _StudentTile({required this.student});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: CircleAvatar(
        backgroundColor: AppColors.success.withValues(alpha: 0.12),
        child: Text(
          student.fullName.isNotEmpty ? student.fullName[0].toUpperCase() : '?',
          style: const TextStyle(
              fontWeight: FontWeight.w700, color: AppColors.success),
        ),
      ),
      title: Text(student.fullName,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(student.parentPhoneNumber,
          style: const TextStyle(fontSize: 12, color: AppColors.neutral500)),
      onTap: () => context.read<EnrollStudentCubit>().enroll(student.id),
    );
  }
}

class _AddNewButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddNewButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.add_rounded, size: 18),
        label: const Text('Yangi o\'quvchi qo\'shish'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(46),
          foregroundColor: AppColors.success,
          side: BorderSide(color: AppColors.success.withValues(alpha: 0.5)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

class _Prompt extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Prompt({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 36, color: AppColors.neutral300),
          const SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.neutral400, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ─── New student form (inline) ────────────────────────────────────────────────

class _NewStudentForm extends StatefulWidget {
  final String prefillName;
  final VoidCallback onBack;

  const _NewStudentForm({
    super.key,
    required this.prefillName,
    required this.onBack,
  });

  @override
  State<_NewStudentForm> createState() => _NewStudentFormState();
}

class _NewStudentFormState extends State<_NewStudentForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  final _parentNameController = TextEditingController();
  final _phoneController = TextEditingController(text: '+998 ');

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.prefillName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _parentNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<EnrollStudentCubit>().createAndEnroll(
          StudentRequest(
            fullName: _nameController.text.trim(),
            parentName: _parentNameController.text.trim().isEmpty
                ? 'Unknown'
                : _parentNameController.text.trim(),
            parentPhoneNumber: _phoneController.text.replaceAll(' ', ''),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DialogHeader(
            icon: Icons.person_add_alt_1_rounded,
            color: AppColors.success,
            title: 'Yangi o\'quvchi',
            subtitle: 'Ma\'lumotlarni to\'ldiring va guruhga qo\'shing',
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              color: AppColors.success,
              onPressed: widget.onBack,
              tooltip: 'Orqaga',
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _FormField(
                    controller: _nameController,
                    label: 'O\'quvchi ismi',
                    hint: 'Ism Familiya',
                    icon: Icons.person_outline_rounded,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Ismni kiriting'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  _FormField(
                    controller: _parentNameController,
                    label: 'Ota-ona ismi (ixtiyoriy)',
                    hint: 'Ism Familiya',
                    icon: Icons.supervisor_account_outlined,
                    validator: (_) => null,
                  ),
                  const SizedBox(height: 14),
                  // ── Phone field with Uzbek formatter ──────────────────
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Telefon raqami',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutral700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [UzbekPhoneNumberFormatter()],
                        validator: (v) => (v == null || v.length < 17)
                            ? 'Telefon raqamini to\'liq kiriting'
                            : null,
                        decoration: const InputDecoration(
                          hintText: '+998 XX XXX XX XX',
                          prefixIcon: Icon(
                            Icons.phone_outlined,
                            size: 20,
                            color: AppColors.neutral400,
                          ),
                          helperText: 'Format: +998 97 123 45 67',
                          helperStyle: TextStyle(
                            fontSize: 11,
                            color: AppColors.neutral400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<EnrollStudentCubit, EnrollStudentState>(
                    builder: (context, state) {
                      final loading = state is EnrollStudentEnrolling;
                      return ElevatedButton(
                        onPressed: loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Text(
                                'Qo\'shish',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 15),
                              ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

class _DialogHeader extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final Widget? leading;

  const _DialogHeader({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 20, 18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border(
          bottom: BorderSide(color: color.withValues(alpha: 0.12)),
        ),
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 4),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.neutral500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String? Function(String?) validator;

  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral700)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20, color: AppColors.neutral400),
          ),
          validator: validator,
        ),
      ],
    );
  }
}

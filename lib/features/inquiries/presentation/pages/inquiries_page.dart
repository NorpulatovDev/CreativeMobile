import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/branch/branch_selection_cubit.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/phone_formatter.dart';
import '../../data/models/inquiry_group_model.dart';
import '../../data/models/inquiry_model.dart';
import '../bloc/inquiry_bloc.dart';
import '../bloc/inquiry_group_bloc.dart';
import '../extensions/inquiry_status_extension.dart';

Future<void> _launchUrl(BuildContext context, String url, String fallbackLabel) async {
  final uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(
          content: Text(fallbackLabel),
          behavior: SnackBarBehavior.floating,
        ));
    }
  }
}

class InquiriesPage extends StatelessWidget {
  const InquiriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final branchId =
        context.watch<BranchSelectionCubit>().state.selectedBranchId;
    return KeyedSubtree(
      key: ValueKey(branchId),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => getIt<InquiryBloc>()..add(InquiryLoadAll()),
          ),
          BlocProvider(
            create: (_) =>
                getIt<InquiryGroupBloc>()..add(InquiryGroupLoadAll()),
          ),
        ],
        child: const _InquiriesTabView(),
      ),
    );
  }
}

class _InquiriesTabView extends StatelessWidget {
  const _InquiriesTabView();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: AppColors.surfaceLight,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'So\'rovlar',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.neutral900,
            ),
          ),
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.neutral500,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600),
            unselectedLabelStyle:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            tabs: const [
              Tab(text: 'Guruhlar'),
              Tab(text: 'Barcha so\'rovlar'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _GroupsTab(),
            _AllInquiriesTab(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Tab 1 — Inquiry Groups
// ─────────────────────────────────────────────────────────────

class _GroupsTab extends StatelessWidget {
  const _GroupsTab();

  void _showSnackBar(BuildContext context, String message, Color color,
      IconData icon) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Row(children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ]),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InquiryGroupBloc, InquiryGroupState>(
      listenWhen: (_, curr) =>
          curr is InquiryGroupError || curr is InquiryGroupActionSuccess,
      listener: (context, state) {
        if (state is InquiryGroupError) {
          _showSnackBar(
              context, state.message, AppColors.error, Icons.error_outline);
        }
        if (state is InquiryGroupActionSuccess) {
          _showSnackBar(context, state.message, AppColors.success,
              Icons.check_circle_outline);
        }
      },
      buildWhen: (_, curr) => curr is! InquiryGroupActionSuccess,
      builder: (context, state) {
        if (state is InquiryGroupLoading) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }

        final groups =
            state is InquiryGroupLoaded ? state.groups : <InquiryGroupModel>[];

        if (groups.isEmpty) {
          return _EmptyGroups(
            onAdd: () => _showCreateGroupDialog(context),
          );
        }

        return Stack(
          children: [
            ListView.separated(
              padding:
                  const EdgeInsets.fromLTRB(20, 16, 20, 100),
              itemCount: groups.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _GroupCard(
                group: groups[index],
                onTap: () => context.push(
                  '${Routes.inquiries}/groups/${groups[index].id}',
                  extra: groups[index],
                ),
                onDelete: () =>
                    _showDeleteGroupDialog(context, groups[index]),
              ),
            ),
            Positioned(
              right: 20,
              bottom: 24,
              child: FloatingActionButton.extended(
                heroTag: 'add_group',
                onPressed: () => _showCreateGroupDialog(context),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 4,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Guruh qo\'shish',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<InquiryGroupBloc>(),
        child: const _CreateGroupDialog(),
      ),
    );
  }

  void _showDeleteGroupDialog(
      BuildContext context, InquiryGroupModel group) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                child: Icon(Icons.delete_outline_rounded,
                    size: 32, color: AppColors.error),
              ),
              const SizedBox(height: 20),
              Text(
                'Guruhni o\'chirish',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Text(
                '"${group.name}" guruhini o\'chirishni xohlaysizmi?\nFaqat bo\'sh guruhlar o\'chiriladi.',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.neutral500),
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
                        context
                            .read<InquiryGroupBloc>()
                            .add(InquiryGroupDelete(group.id));
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

class _EmptyGroups extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyGroups({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.folder_outlined,
                size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          Text(
            'Guruhlar yo\'q',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.neutral700,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Birinchi so\'rovlar guruhini yarating',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.neutral500),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: onAdd,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 14),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Guruh qo\'shish',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final InquiryGroupModel group;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _GroupCard({
    required this.group,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
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
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Icon(Icons.folder_rounded,
                      color: AppColors.primary, size: 24),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${group.inquiryCount} ta so\'rov',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral500,
                          ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert_rounded,
                    color: AppColors.neutral400),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                onSelected: (value) {
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_rounded,
                            size: 20, color: AppColors.error),
                        const SizedBox(width: 12),
                        Text('O\'chirish',
                            style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
              Icon(Icons.chevron_right_rounded,
                  color: AppColors.neutral400),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateGroupDialog extends StatefulWidget {
  const _CreateGroupDialog();

  @override
  State<_CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<_CreateGroupDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.folder_outlined,
                        color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Yangi guruh',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Guruh nomi',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral700,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                autofocus: true,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Guruh nomini kiriting'
                    : null,
                decoration: InputDecoration(
                  hintText: 'Masalan: Math Beginner',
                  prefixIcon: Icon(Icons.folder_outlined,
                      color: AppColors.neutral400),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _submitting
                          ? null
                          : () => Navigator.pop(context),
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
                        backgroundColor: AppColors.primary,
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
                          : const Text('Qo\'shish'),
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

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _submitting = true);
      context
          .read<InquiryGroupBloc>()
          .add(InquiryGroupCreate(_nameController.text.trim()));
      Navigator.pop(context);
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Tab 2 — All Inquiries
// ─────────────────────────────────────────────────────────────

class _AllInquiriesTab extends StatefulWidget {
  const _AllInquiriesTab();

  @override
  State<_AllInquiriesTab> createState() => _AllInquiriesTabState();
}

class _AllInquiriesTabState extends State<_AllInquiriesTab> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  InquiryStatus? _selectedStatus;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Row(children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ]),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
  }

  void _filterByStatus(InquiryStatus? status) {
    setState(() => _selectedStatus = status);
    if (status == null) {
      context.read<InquiryBloc>().add(InquiryLoadAll());
    } else {
      context.read<InquiryBloc>().add(InquiryLoadByStatus(status));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InquiryBloc, InquiryState>(
      listenWhen: (_, curr) =>
          curr is InquiryError || curr is InquiryActionSuccess,
      buildWhen: (_, curr) => curr is! InquiryActionSuccess,
      listener: (context, state) {
        if (state is InquiryError) {
          _showSnackBar(state.message, AppColors.error, Icons.error_outline);
        }
        if (state is InquiryActionSuccess) {
          _showSnackBar(
              state.message, AppColors.success, Icons.check_circle_outline);
        }
      },
      builder: (context, state) {
        return Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(20, 12, 20, 12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.neutral200),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (v) => setState(
                                () => _searchQuery = v.toLowerCase()),
                            decoration: InputDecoration(
                              hintText: 'Qidirish...',
                              hintStyle: TextStyle(
                                  color: AppColors.neutral400,
                                  fontWeight: FontWeight.w400),
                              prefixIcon: Icon(Icons.search_rounded,
                                  color: AppColors.neutral400),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(Icons.close_rounded,
                                          color: AppColors.neutral400),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _searchQuery = '');
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                            ),
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            _FilterChip(
                              label: 'Barchasi',
                              isSelected: _selectedStatus == null,
                              onTap: () => _filterByStatus(null),
                            ),
                            const SizedBox(width: 8),
                            ...[
                              InquiryStatus.newInquiry,
                              InquiryStatus.contacted,
                            ].map(
                              (s) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _FilterChip(
                                  label: s.displayName,
                                  icon: s.icon,
                                  color: s.color,
                                  isSelected: _selectedStatus == s,
                                  onTap: () => _filterByStatus(s),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                if (state is InquiryLoading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary),
                    ),
                  )
                else if (state is InquiryLoaded)
                  _buildList(context, state.inquiries)
                else
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
            Positioned(
              right: 20,
              bottom: 24,
              child: FloatingActionButton.extended(
                heroTag: 'add_inquiry',
                onPressed: () => _showInquiryDialog(context),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 4,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Qo\'shish',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildList(BuildContext context, List<InquiryModel> inquiries) {
    final filtered = _searchQuery.isEmpty
        ? inquiries
        : inquiries.where((i) {
            return i.fullName.toLowerCase().contains(_searchQuery) ||
                i.parentName.toLowerCase().contains(_searchQuery) ||
                i.parentPhoneNumber.contains(_searchQuery) ||
                (i.inquiryGroupName
                        ?.toLowerCase()
                        .contains(_searchQuery) ??
                    false);
          }).toList();

    if (inquiries.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.contact_phone_rounded,
                    size: 48, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              Text('So\'rovlar yo\'q',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.neutral700,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text('Birinchi so\'rov qo\'shing',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.neutral500)),
            ],
          ),
        ),
      );
    }

    if (filtered.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.search_off_rounded,
                    size: 48, color: AppColors.neutral400),
              ),
              const SizedBox(height: 24),
              Text('Natija topilmadi',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.neutral700,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _InquiryCard(
              inquiry: filtered[index],
              onEdit: () => _showInquiryDialog(context, filtered[index]),
              onDelete: () => _showDeleteDialog(context, filtered[index]),
            ),
          ),
          childCount: filtered.length,
        ),
      ),
    );
  }

  void _showInquiryDialog(BuildContext context, [InquiryModel? inquiry]) {
    final groups =
        context.read<InquiryGroupBloc>().state is InquiryGroupLoaded
            ? (context.read<InquiryGroupBloc>().state as InquiryGroupLoaded)
                .groups
            : <InquiryGroupModel>[];

    showDialog(
      context: context,
      builder: (dialogContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<InquiryBloc>()),
          BlocProvider.value(value: context.read<InquiryGroupBloc>()),
        ],
        child: InquiryFormDialog(inquiry: inquiry, groups: groups),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, InquiryModel inquiry) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: AppColors.errorLight, shape: BoxShape.circle),
                child: Icon(Icons.delete_outline_rounded,
                    size: 32, color: AppColors.error),
              ),
              const SizedBox(height: 20),
              Text('So\'rovni o\'chirish',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Text(
                '${inquiry.fullName}ning so\'rovini o\'chirishni xohlaysizmi?',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.neutral500),
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
                        context
                            .read<InquiryBloc>()
                            .add(InquiryDelete(inquiry.id));
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

// ─────────────────────────────────────────────────────────────
// Shared widgets
// ─────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.icon,
    this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? chipColor
                : chipColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? chipColor
                  : chipColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon,
                    size: 16,
                    color: isSelected ? Colors.white : chipColor),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : chipColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InquiryActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _InquiryActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}

class _InquiryCard extends StatelessWidget {
  final InquiryModel inquiry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _InquiryCard({
    required this.inquiry,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) {
      if (diff.inHours == 0) return '${diff.inMinutes} daqiqa oldin';
      return '${diff.inHours} soat oldin';
    } else if (diff.inDays == 1) {
      return 'Kecha';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} kun oldin';
    }
    const months = [
      'Yan', 'Fev', 'Mar', 'Apr', 'May', 'Iyun',
      'Iyul', 'Avg', 'Sen', 'Okt', 'Noy', 'Dek',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: inquiry.status.color.withValues(alpha: 0.3),
                width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.neutral900.withValues(alpha: 0.03),
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
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: inquiry.status.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        inquiry.fullName.isNotEmpty
                            ? inquiry.fullName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: inquiry.status.color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          inquiry.fullName,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded,
                                size: 12, color: AppColors.neutral400),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(inquiry.createdAt),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.neutral400),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _InquiryActionButton(
                    icon: Icons.call_rounded,
                    color: AppColors.success,
                    onTap: () => _launchUrl(
                      context,
                      'tel:${inquiry.parentPhoneNumber}',
                      inquiry.parentPhoneNumber,
                    ),
                  ),
                  const SizedBox(width: 4),
                  _InquiryActionButton(
                    icon: Icons.sms_rounded,
                    color: AppColors.primary,
                    onTap: () => _launchUrl(
                      context,
                      'sms:${inquiry.parentPhoneNumber}',
                      inquiry.parentPhoneNumber,
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert_rounded,
                        color: AppColors.neutral400),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    onSelected: (value) {
                      if (value == 'edit') onEdit();
                      if (value == 'delete') onDelete();
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(children: [
                          Icon(Icons.edit_rounded,
                              size: 20, color: AppColors.neutral600),
                          const SizedBox(width: 12),
                          const Text('Tahrirlash'),
                        ]),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(children: [
                          Icon(Icons.delete_rounded,
                              size: 20, color: AppColors.error),
                          const SizedBox(width: 12),
                          Text('O\'chirish',
                              style: TextStyle(color: AppColors.error)),
                        ]),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: inquiry.status.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(inquiry.status.icon,
                        size: 16, color: inquiry.status.color),
                    const SizedBox(width: 6),
                    Text(
                      inquiry.status.displayName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: inquiry.status.color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.phone_outlined,
                label: PhoneValidator.toDisplayFormat(
                    inquiry.parentPhoneNumber),
              ),
              if (inquiry.inquiryGroupName != null &&
                  inquiry.inquiryGroupName!.isNotEmpty) ...[
                const SizedBox(height: 6),
                _InfoRow(
                  icon: Icons.folder_outlined,
                  label: inquiry.inquiryGroupName!,
                ),
              ],
              if (inquiry.notes != null && inquiry.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.neutral50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.note_outlined,
                          size: 16, color: AppColors.neutral500),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          inquiry.notes!,
                          style: TextStyle(
                              fontSize: 13, color: AppColors.neutral600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.neutral400),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.neutral600),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Inquiry Form Dialog (shared, used from both tabs and detail)
// ─────────────────────────────────────────────────────────────

class InquiryFormDialog extends StatefulWidget {
  final InquiryModel? inquiry;
  final List<InquiryGroupModel> groups;
  final InquiryGroupModel? preselectedGroup;

  const InquiryFormDialog({
    super.key,
    this.inquiry,
    required this.groups,
    this.preselectedGroup,
  });

  @override
  State<InquiryFormDialog> createState() => _InquiryFormDialogState();
}

class _InquiryFormDialogState extends State<InquiryFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController =
      TextEditingController(text: widget.inquiry?.fullName);
  late final TextEditingController _phoneController = TextEditingController(
    text: widget.inquiry != null
        ? PhoneValidator.toDisplayFormat(widget.inquiry!.parentPhoneNumber)
        : '+998 ',
  );
  late final TextEditingController _notesController =
      TextEditingController(text: widget.inquiry?.notes);

  late InquiryStatus _selectedStatus =
      widget.inquiry?.status ?? InquiryStatus.newInquiry;
  InquiryGroupModel? _selectedGroup;
  bool _submitting = false;

  bool get isEditing => widget.inquiry != null;

  @override
  void initState() {
    super.initState();
    _selectedGroup = widget.preselectedGroup ??
        (widget.inquiry?.inquiryGroupId != null
            ? widget.groups
                .where((g) => g.id == widget.inquiry!.inquiryGroupId)
                .firstOrNull
            : null);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isEditing
                          ? Icons.edit_rounded
                          : Icons.contact_phone_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing
                              ? 'So\'rovni tahrirlash'
                              : 'Yangi so\'rov',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isEditing
                              ? 'Ma\'lumotlarni yangilash'
                              : 'So\'rov ma\'lumotlarini kiriting',
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
            Flexible(
              child: SingleChildScrollView(
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
                      _buildPhoneField(),
                      if (widget.preselectedGroup == null) ...[
                        const SizedBox(height: 16),
                        _buildGroupDropdown(),
                      ],
                      if (isEditing) ...[
                        const SizedBox(height: 16),
                        Text('Holat',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.neutral700)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [InquiryStatus.newInquiry, InquiryStatus.contacted].map((status) {
                            final isSelected = _selectedStatus == status;
                            return InkWell(
                              onTap: () =>
                                  setState(() => _selectedStatus = status),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? status.color
                                      : status.color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: status.color,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(status.icon,
                                        size: 16,
                                        color: isSelected
                                            ? Colors.white
                                            : status.color),
                                    const SizedBox(width: 6),
                                    Text(
                                      status.displayName,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? Colors.white
                                            : status.color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _notesController,
                        label: 'Izohlar (ixtiyoriy)',
                        hint: 'Qo\'shimcha ma\'lumotlar',
                        icon: Icons.note_outlined,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.neutral50,
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(24)),
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
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Text(isEditing ? 'Yangilash' : 'Qo\'shish'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupDropdown() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Guruh',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral700)),
          const SizedBox(height: 8),
          DropdownButtonFormField<InquiryGroupModel>(
            initialValue: _selectedGroup,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.folder_outlined,
                  color: AppColors.neutral400),
              hintText: 'Guruhni tanlang',
            ),
            items: widget.groups
                .map((g) => DropdownMenuItem(value: g, child: Text(g.name)))
                .toList(),
            onChanged: (value) => setState(() => _selectedGroup = value),
            validator: (value) =>
                value == null ? 'Guruhni tanlang' : null,
          ),
        ],
      );

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral700)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
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
          Text('Telefon raqami',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral700)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [UzbekPhoneNumberFormatter()],
            validator: (value) {
              if (value == null || value.length < 17) {
                return 'Telefon raqamini to\'liq kiriting';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: '+998 XX XXX XX XX',
              prefixIcon: Icon(Icons.phone_outlined,
                  color: AppColors.neutral400),
              helperText: 'Format: +998 97 123 45 67',
              helperStyle:
                  TextStyle(fontSize: 11, color: AppColors.neutral400),
            ),
          ),
        ],
      );

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _submitting = true);
      final bloc = context.read<InquiryBloc>();
      final digitsOnly =
          _phoneController.text.replaceAll(RegExp(r'\D'), '');
      final formattedPhone = '+$digitsOnly';

      if (isEditing) {
        bloc.add(InquiryUpdate(
          id: widget.inquiry!.id,
          fullName: _nameController.text.trim(),
          parentName: 'Unknown',
          parentPhoneNumber: formattedPhone,
          inquiryGroupId: _selectedGroup!.id,
          status: _selectedStatus,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        ));
      } else {
        bloc.add(InquiryCreate(
          fullName: _nameController.text.trim(),
          parentName: 'Unknown',
          parentPhoneNumber: formattedPhone,
          inquiryGroupId: _selectedGroup!.id,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        ));
      }
      Navigator.pop(context);
    }
  }
}

class UzbekPhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '+998 ',
        selection: TextSelection.collapsed(offset: 5),
      );
    }

    String body = digits;
    if (body.startsWith('998')) body = body.substring(3);
    if (body.length > 9) body = body.substring(0, 9);

    final buffer = StringBuffer()..write('+998 ');
    if (body.isNotEmpty) {
      buffer.write(body.substring(0, body.length >= 2 ? 2 : body.length));
      if (body.length > 2) buffer.write(' ');
    }
    if (body.length > 2) {
      buffer.write(body.substring(2, body.length >= 5 ? 5 : body.length));
      if (body.length > 5) buffer.write(' ');
    }
    if (body.length > 5) {
      buffer.write(body.substring(5, body.length >= 7 ? 7 : body.length));
      if (body.length > 7) buffer.write(' ');
    }
    if (body.length > 7) buffer.write(body.substring(7));

    final formattedText = buffer.toString();
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

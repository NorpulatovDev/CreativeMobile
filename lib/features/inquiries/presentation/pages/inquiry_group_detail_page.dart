import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../groups/data/models/group_model.dart';
import '../../../groups/presentation/bloc/group_bloc.dart';
import '../../data/models/inquiry_group_model.dart';
import '../../data/models/inquiry_model.dart';
import '../bloc/inquiry_bloc.dart';
import '../bloc/inquiry_group_bloc.dart';
import '../extensions/inquiry_status_extension.dart';
import '../widgets/sms_campaign_sheet.dart';
import 'inquiries_page.dart';

Future<void> _launch(BuildContext context, String url, String fallbackLabel) async {
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

class InquiryGroupDetailPage extends StatelessWidget {
  final InquiryGroupModel group;

  const InquiryGroupDetailPage({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<InquiryBloc>()..add(InquiryLoadAll()),
        ),
        BlocProvider(
          create: (_) =>
              getIt<InquiryGroupBloc>()..add(InquiryGroupLoadAll()),
        ),
        BlocProvider(
          create: (_) => getIt<GroupBloc>()..add(GroupLoadAll()),
        ),
      ],
      child: _InquiryGroupDetailView(group: group),
    );
  }
}

class _InquiryGroupDetailView extends StatefulWidget {
  final InquiryGroupModel group;

  const _InquiryGroupDetailView({required this.group});

  @override
  State<_InquiryGroupDetailView> createState() =>
      _InquiryGroupDetailViewState();
}

class _InquiryGroupDetailViewState extends State<_InquiryGroupDetailView> {
  InquiryStatus? _selectedStatus;

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

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<InquiryBloc, InquiryState>(
          listenWhen: (_, curr) =>
              curr is InquiryError || curr is InquiryActionSuccess,
          listener: (context, state) {
            if (state is InquiryError) {
              _showSnackBar(
                  state.message, AppColors.error, Icons.error_outline);
            }
            if (state is InquiryActionSuccess) {
              _showSnackBar(state.message, AppColors.success,
                  Icons.check_circle_outline);
            }
          },
        ),
        BlocListener<InquiryGroupBloc, InquiryGroupState>(
          listenWhen: (_, curr) =>
              curr is InquiryGroupError || curr is InquiryGroupActionSuccess,
          listener: (context, state) {
            if (state is InquiryGroupError) {
              _showSnackBar(
                  state.message, AppColors.error, Icons.error_outline);
            }
            if (state is InquiryGroupActionSuccess) {
              _showSnackBar(state.message, AppColors.success,
                  Icons.check_circle_outline);
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: AppColors.surfaceLight,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.group.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral900,
                ),
              ),
              BlocBuilder<InquiryBloc, InquiryState>(
                buildWhen: (_, curr) => curr is InquiryLoaded,
                builder: (context, state) {
                  final count = state is InquiryLoaded
                      ? state.inquiries
                          .where((i) => i.inquiryGroupId == widget.group.id)
                          .length
                      : widget.group.inquiryCount;
                  return Text(
                    '$count ta so\'rov',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.neutral500,
                      fontWeight: FontWeight.w400,
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            BlocBuilder<InquiryBloc, InquiryState>(
              buildWhen: (_, curr) => curr is InquiryLoaded,
              builder: (context, state) {
                final inquiries = state is InquiryLoaded
                    ? state.inquiries
                        .where((i) => i.inquiryGroupId == widget.group.id)
                        .toList()
                    : <InquiryModel>[];
                return IconButton(
                  icon: const Icon(Icons.campaign_rounded),
                  color: AppColors.primary,
                  tooltip: 'SMS kampaniyasi',
                  onPressed: () => _showSmsCampaign(context, inquiries),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextButton.icon(
                onPressed: () => _showMigrateDialog(context),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.success.withValues(alpha: 0.1),
                  foregroundColor: AppColors.success,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.transfer_within_a_station_rounded,
                    size: 18),
                label: const Text('Ko\'chirish',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
        body: BlocBuilder<InquiryBloc, InquiryState>(
          buildWhen: (_, curr) => curr is! InquiryActionSuccess,
          builder: (context, state) {
            if (state is InquiryLoading) {
              return const Center(
                  child:
                      CircularProgressIndicator(color: AppColors.primary));
            }

            final allInquiries = state is InquiryLoaded
                ? state.inquiries
                    .where((i) => i.inquiryGroupId == widget.group.id)
                    .toList()
                : <InquiryModel>[];

            final inquiries = _selectedStatus == null
                ? allInquiries
                : allInquiries
                    .where((i) => i.status == _selectedStatus)
                    .toList();

            return Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _StatusChip(
                                label: 'Barchasi',
                                isSelected: _selectedStatus == null,
                                onTap: () =>
                                    setState(() => _selectedStatus = null),
                              ),
                              const SizedBox(width: 8),
                              ...[
                                InquiryStatus.newInquiry,
                                InquiryStatus.contacted,
                              ].map((s) => Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: _StatusChip(
                                      label: s.displayName,
                                      icon: s.icon,
                                      color: s.color,
                                      isSelected: _selectedStatus == s,
                                      onTap: () => setState(
                                          () => _selectedStatus = s),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (allInquiries.isEmpty)
                      SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.contact_phone_rounded,
                                    size: 48, color: AppColors.primary),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Bu guruhda so\'rovlar yo\'q',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: AppColors.neutral700,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Birinchi so\'rov qo\'shing',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: AppColors.neutral500),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (inquiries.isEmpty)
                      SliverFillRemaining(
                        child: Center(
                          child: Text(
                            'Bu statusda so\'rovlar yo\'q',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.neutral500),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _DetailInquiryCard(
                                inquiry: inquiries[index],
                                groups: context.read<InquiryGroupBloc>().state
                                        is InquiryGroupLoaded
                                    ? (context.read<InquiryGroupBloc>().state
                                            as InquiryGroupLoaded)
                                        .groups
                                    : [],
                                onEdit: () => _showEditDialog(
                                    context, inquiries[index]),
                                onDelete: () => _showDeleteDialog(
                                    context, inquiries[index]),
                              ),
                            ),
                            childCount: inquiries.length,
                          ),
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  ],
                ),
                Positioned(
                  right: 20,
                  bottom: 24,
                  child: FloatingActionButton.extended(
                    onPressed: () => _showAddInquiryDialog(context),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('So\'rov qo\'shish',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showAddInquiryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<InquiryBloc>()),
          BlocProvider.value(value: context.read<InquiryGroupBloc>()),
        ],
        child: InquiryFormDialog(
          groups: const [],
          preselectedGroup: widget.group,
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, InquiryModel inquiry) {
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

  void _showSmsCampaign(BuildContext context, List<InquiryModel> inquiries) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SmsCampaignSheet(
        group: widget.group,
        inquiries: inquiries,
      ),
    );
  }

  void _showMigrateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<InquiryBloc>()),
          BlocProvider.value(value: context.read<InquiryGroupBloc>()),
          BlocProvider.value(value: context.read<GroupBloc>()),
        ],
        child: _MigrateDialog(inquiryGroup: widget.group),
      ),
    );
  }
}

class _MigrateDialog extends StatefulWidget {
  final InquiryGroupModel inquiryGroup;

  const _MigrateDialog({required this.inquiryGroup});

  @override
  State<_MigrateDialog> createState() => _MigrateDialogState();
}

class _MigrateDialogState extends State<_MigrateDialog> {
  GroupModel? _selectedGroup;
  String? _groupError;
  bool _submitting = false;
  List<GroupModel> _groups = [];

  @override
  void initState() {
    super.initState();
    final s = context.read<GroupBloc>().state;
    if (s is GroupLoaded) _groups = s.groups;
  }

  Future<void> _pickGroup() async {
    final picked = await showModalBottomSheet<GroupModel>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _GroupPickerSheet(
        groups: _groups,
        selectedId: _selectedGroup?.id,
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedGroup = picked;
        _groupError = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GroupBloc, GroupState>(
      listener: (context, state) {
        if (state is GroupLoaded) setState(() => _groups = state.groups);
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.transfer_within_a_station_rounded,
                        color: AppColors.success, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Guruhga ko\'chirish',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(
                          '"${widget.inquiryGroup.name}" guruhi so\'rovlari',
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
              const SizedBox(height: 16),
              BlocBuilder<InquiryBloc, InquiryState>(
                buildWhen: (_, curr) => curr is InquiryLoaded,
                builder: (context, state) {
                  final count = state is InquiryLoaded
                      ? state.inquiries
                          .where((i) => i.inquiryGroupId == widget.inquiryGroup.id)
                          .length
                      : widget.inquiryGroup.inquiryCount;
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 18, color: AppColors.warning),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '$count ta kutayotgan so\'rov o\'quvchiga aylantiriladi.',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.neutral700),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Text('Maqsad guruh',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral700)),
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
                      Icon(Icons.groups_rounded,
                          color: _groupError != null
                              ? AppColors.error
                              : AppColors.neutral400),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedGroup != null
                              ? '${_selectedGroup!.name} (${_selectedGroup!.teacherName})'
                              : 'Guruhni tanlang',
                          style: TextStyle(
                            fontSize: 16,
                            color: _selectedGroup != null
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
                  child: Text(_groupError!,
                      style:
                          TextStyle(color: AppColors.error, fontSize: 12)),
                ),
              const SizedBox(height: 24),
              Row(
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
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('Ko\'chirish',
                              style:
                                  TextStyle(fontWeight: FontWeight.w600)),
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
    if (_selectedGroup == null) {
      setState(() => _groupError = 'Guruhni tanlang');
      return;
    }
    setState(() => _submitting = true);
    context.read<InquiryGroupBloc>().add(
          InquiryGroupMigrate(
            inquiryGroupId: widget.inquiryGroup.id,
            groupId: _selectedGroup!.id,
          ),
        );
    Navigator.pop(context);
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
                Text('Guruhni tanlang',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral900)),
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
                        onTap: () => Navigator.pop(context, group),
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
                            style: const TextStyle(
                                fontWeight: FontWeight.w600)),
                        subtitle: Text(group.teacherName,
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.neutral500)),
                        trailing: isSelected
                            ? Icon(Icons.check_circle_rounded,
                                color: AppColors.primary)
                            : null,
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _DetailInquiryCard extends StatelessWidget {
  final InquiryModel inquiry;
  final List<InquiryGroupModel> groups;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DetailInquiryCard({
    required this.inquiry,
    required this.groups,
    required this.onEdit,
    required this.onDelete,
  });

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
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: inquiry.status.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    inquiry.fullName.isNotEmpty
                        ? inquiry.fullName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: inquiry.status.color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inquiry.fullName,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: inquiry.status.color
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(inquiry.status.icon,
                                  size: 12,
                                  color: inquiry.status.color),
                              const SizedBox(width: 4),
                              Text(
                                inquiry.status.displayName,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: inquiry.status.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (inquiry.notes != null &&
                            inquiry.notes!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.note_outlined,
                              size: 14, color: AppColors.neutral400),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              _ActionButton(
                icon: Icons.call_rounded,
                color: AppColors.success,
                onTap: () => _launch(
                  context,
                  'tel:${inquiry.parentPhoneNumber}',
                  inquiry.parentPhoneNumber,
                ),
              ),
              const SizedBox(width: 4),
              _ActionButton(
                icon: Icons.sms_rounded,
                color: AppColors.primary,
                onTap: () => _launch(
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
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
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

class _StatusChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusChip({
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
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                    size: 14,
                    color: isSelected ? Colors.white : chipColor),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
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

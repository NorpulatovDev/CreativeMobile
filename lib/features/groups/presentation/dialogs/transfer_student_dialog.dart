import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../branches/data/models/branch_model.dart';
import '../../../groups/data/models/group_model.dart';
import '../bloc/transfer_branch_cubit.dart';
import '../bloc/transfer_student_cubit.dart';

/// Where the selected students are being moved.
enum _TransferMode { group, branch }

/// Which screen of the wizard is showing.
///
/// Non-super-admins never see [chooseMode] / branch steps — they land straight
/// on [groupPicker], exactly as before this dialog gained the branch option.
enum _Step { chooseMode, groupPicker, branchPicker, branchGroupPicker }

class TransferStudentDialog extends StatefulWidget {
  final List<int> studentIds;
  final VoidCallback onSuccess;
  final ValueChanged<String> onError;

  /// Only super-admins may move students to another branch.
  final bool isSuperAdmin;

  /// The branch the students currently belong to (the app's selected branch).
  /// Required for the branch flow; null disables it.
  final int? fromBranchId;

  const TransferStudentDialog({
    super.key,
    required this.studentIds,
    required this.onSuccess,
    required this.onError,
    this.isSuperAdmin = false,
    this.fromBranchId,
  });

  @override
  State<TransferStudentDialog> createState() => _TransferStudentDialogState();
}

class _TransferStudentDialogState extends State<TransferStudentDialog> {
  final _searchController = TextEditingController();

  late _Step _step;
  _TransferMode _mode = _TransferMode.group;

  // Group mode
  GroupModel? _selectedGroup;

  // Branch mode
  BranchModel? _selectedBranch;
  GroupModel? _selectedBranchGroup;

  String _query = '';
  bool _transferPayment = true;

  bool get _branchEnabled => widget.isSuperAdmin && widget.fromBranchId != null;

  @override
  void initState() {
    super.initState();
    if (_branchEnabled) {
      _step = _Step.chooseMode;
    } else {
      _step = _Step.groupPicker;
      context.read<TransferStudentCubit>().loadGroups();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetSearch() {
    _searchController.clear();
    _query = '';
  }

  void _continueFromMode() {
    if (_mode == _TransferMode.group) {
      setState(() {
        _step = _Step.groupPicker;
        _resetSearch();
      });
      context.read<TransferStudentCubit>().loadGroups();
    } else {
      setState(() {
        _step = _Step.branchPicker;
        _resetSearch();
      });
      context.read<TransferBranchCubit>().loadBranches();
    }
  }

  void _back() {
    setState(() {
      _resetSearch();
      if (_step == _Step.branchGroupPicker) {
        _selectedBranchGroup = null;
        _step = _Step.branchPicker;
        context.read<TransferBranchCubit>().loadBranches();
      } else {
        // groupPicker or branchPicker → back to the mode chooser
        _selectedGroup = null;
        _selectedBranch = null;
        _step = _Step.chooseMode;
      }
    });
  }

  List<GroupModel> _filterGroups(List<GroupModel> groups) {
    if (_query.trim().isEmpty) return groups;
    final q = _query.trim().toLowerCase();
    return groups
        .where((g) =>
            g.name.toLowerCase().contains(q) ||
            g.teacherName.toLowerCase().contains(q))
        .toList();
  }

  List<BranchModel> _filterBranches(List<BranchModel> branches) {
    if (_query.trim().isEmpty) return branches;
    final q = _query.trim().toLowerCase();
    return branches
        .where((b) =>
            b.name.toLowerCase().contains(q) ||
            (b.address ?? '').toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<TransferStudentCubit, TransferStudentState>(
          listener: (context, state) {
            if (state is TransferSuccess) {
              Navigator.pop(context);
              widget.onSuccess();
            } else if (state is TransferError && state.groups.isEmpty) {
              Navigator.pop(context);
              widget.onError(state.message);
            }
          },
        ),
        BlocListener<TransferBranchCubit, TransferBranchState>(
          listener: (context, state) {
            if (state is TransferBranchSuccess) {
              Navigator.pop(context);
              widget.onSuccess();
            } else if (state is TransferBranchError &&
                state.branches.isEmpty &&
                state.groups.isEmpty) {
              Navigator.pop(context);
              widget.onError(state.message);
            }
          },
        ),
      ],
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        clipBehavior: Clip.hardEdge,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450, maxHeight: 560),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              ..._buildBody(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBody() {
    switch (_step) {
      case _Step.chooseMode:
        return [_buildModeChooser()];
      case _Step.groupPicker:
        return [
          _buildSearch('Guruh nomini qidiring...'),
          Flexible(child: _buildGroupList()),
          _buildPaymentCheckbox(),
          _buildGroupConfirmButton(),
        ];
      case _Step.branchPicker:
        return [
          _buildSearch('Filial nomini qidiring...'),
          Flexible(child: _buildBranchList()),
        ];
      case _Step.branchGroupPicker:
        return [
          _buildSearch('Guruh nomini qidiring...'),
          Flexible(child: _buildBranchGroupList()),
          _buildPaymentCheckbox(),
          _buildBranchConfirmButton(),
        ];
    }
  }

  String _title() {
    switch (_step) {
      case _Step.chooseMode:
        return 'O\'quvchini o\'tkazish';
      case _Step.groupPicker:
        return 'Guruhga o\'tkazish';
      case _Step.branchPicker:
        return 'Filialga o\'tkazish';
      case _Step.branchGroupPicker:
        return _selectedBranch?.name ?? 'Filial guruhi';
    }
  }

  bool get _showBack => _branchEnabled && _step != _Step.chooseMode;

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 20, 18),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        border: Border(
          bottom: BorderSide(color: AppColors.primary.withValues(alpha: 0.12)),
        ),
      ),
      child: Row(
        children: [
          if (_showBack)
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: _back,
              splashRadius: 20,
            )
          else
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.swap_horiz_rounded,
                  color: AppColors.primary, size: 20),
            ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title(),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.studentIds.length} ta o\'quvchi tanlangan',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.neutral500),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.pop(context),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildModeChooser() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _modeTile(
            mode: _TransferMode.group,
            icon: Icons.groups_rounded,
            title: 'Boshqa guruhga',
            subtitle: 'Shu filialdagi boshqa guruhga o\'tkazish',
          ),
          const SizedBox(height: 10),
          _modeTile(
            mode: _TransferMode.branch,
            icon: Icons.apartment_rounded,
            title: 'Boshqa filialga',
            subtitle: 'Boshqa filialdagi guruhga o\'tkazish',
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _continueFromMode,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Davom etish',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ],
      ),
    );
  }

  Widget _modeTile({
    required _TransferMode mode,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final selected = _mode == mode;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => setState(() => _mode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.06)
              : AppColors.neutral50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.4)
                : AppColors.neutral200,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.neutral100,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon,
                  color: selected ? AppColors.primary : AppColors.neutral600,
                  size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: selected
                            ? AppColors.primary
                            : AppColors.neutral900,
                      )),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.neutral500)),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? AppColors.primary : AppColors.neutral300,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearch(String hint) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        onChanged: (v) => setState(() {
          _query = v;
          // Typing changes the visible list, so drop any now-hidden selection
          // (matches the original group-picker behaviour).
          _selectedGroup = null;
          _selectedBranchGroup = null;
        }),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => setState(_resetSearch),
                )
              : null,
        ),
      ),
    );
  }

  Widget _emptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.group_off_outlined, size: 36, color: AppColors.neutral300),
          const SizedBox(height: 10),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.neutral400, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _loading() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 28),
      child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }

  // ---- Group mode (unchanged behaviour) ----

  Widget _buildGroupList() {
    return BlocBuilder<TransferStudentCubit, TransferStudentState>(
      builder: (context, state) {
        if (state is TransferGroupsLoading) return _loading();

        List<GroupModel> groups = const [];
        if (state is TransferGroupsLoaded) groups = state.groups;
        if (state is TransferInProgress) groups = state.groups;
        if (state is TransferError) groups = state.groups;

        final filtered = _filterGroups(groups);
        if (filtered.isEmpty) {
          return _emptyState(_query.isEmpty
              ? 'Boshqa guruhlar mavjud emas'
              : '"$_query" bo\'yicha guruh topilmadi');
        }
        return _groupTiles(
          filtered,
          selectedId: _selectedGroup?.id,
          onTap: (g) => setState(() => _selectedGroup = g),
        );
      },
    );
  }

  Widget _buildGroupConfirmButton() {
    return BlocBuilder<TransferStudentCubit, TransferStudentState>(
      builder: (context, state) {
        final isLoading = state is TransferInProgress;
        return _confirmButton(
          isLoading: isLoading,
          enabled: !isLoading && _selectedGroup != null,
          idleLabel: _selectedGroup == null
              ? 'Guruh tanlang'
              : '${widget.studentIds.length} ta o\'quvchini o\'tkazish',
          onPressed: () => context.read<TransferStudentCubit>().transfer(
                studentIds: widget.studentIds,
                toGroupId: _selectedGroup!.id,
                transferAllPayments: _transferPayment,
              ),
        );
      },
    );
  }

  // ---- Branch mode ----

  Widget _buildBranchList() {
    return BlocBuilder<TransferBranchCubit, TransferBranchState>(
      builder: (context, state) {
        if (state is TransferBranchesLoading) return _loading();

        List<BranchModel> branches = const [];
        if (state is TransferBranchesLoaded) branches = state.branches;
        if (state is TransferBranchError) branches = state.branches;

        final filtered = _filterBranches(branches);
        if (filtered.isEmpty) {
          return _emptyState(_query.isEmpty
              ? 'Boshqa filiallar mavjud emas'
              : '"$_query" bo\'yicha filial topilmadi');
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shrinkWrap: true,
          itemCount: filtered.length,
          itemBuilder: (context, i) {
            final branch = filtered[i];
            return ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.apartment_rounded,
                    color: AppColors.neutral600, size: 20),
              ),
              title: Text(branch.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral900)),
              subtitle: (branch.address != null && branch.address!.isNotEmpty)
                  ? Text(branch.address!,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.neutral500))
                  : null,
              trailing: const Icon(Icons.chevron_right_rounded,
                  color: AppColors.neutral400),
              onTap: () {
                setState(() {
                  _selectedBranch = branch;
                  _selectedBranchGroup = null;
                  _step = _Step.branchGroupPicker;
                  _resetSearch();
                });
                context.read<TransferBranchCubit>().selectBranch(branch);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildBranchGroupList() {
    return BlocBuilder<TransferBranchCubit, TransferBranchState>(
      builder: (context, state) {
        if (state is TransferBranchGroupsLoading) return _loading();

        List<GroupModel> groups = const [];
        if (state is TransferBranchGroupsLoaded) groups = state.groups;
        if (state is TransferBranchInProgress) groups = state.groups;
        if (state is TransferBranchError) groups = state.groups;

        final filtered = _filterGroups(groups);
        if (filtered.isEmpty) {
          return _emptyState(_query.isEmpty
              ? 'Bu filialda guruhlar mavjud emas'
              : '"$_query" bo\'yicha guruh topilmadi');
        }
        return _groupTiles(
          filtered,
          selectedId: _selectedBranchGroup?.id,
          onTap: (g) => setState(() => _selectedBranchGroup = g),
        );
      },
    );
  }

  Widget _buildBranchConfirmButton() {
    return BlocBuilder<TransferBranchCubit, TransferBranchState>(
      builder: (context, state) {
        final isLoading = state is TransferBranchInProgress;
        return _confirmButton(
          isLoading: isLoading,
          enabled: !isLoading && _selectedBranchGroup != null,
          idleLabel: _selectedBranchGroup == null
              ? 'Guruh tanlang'
              : '${widget.studentIds.length} ta o\'quvchini o\'tkazish',
          onPressed: () => context.read<TransferBranchCubit>().transfer(
                studentIds: widget.studentIds,
                branch: _selectedBranch!,
                targetGroupId: _selectedBranchGroup!.id,
                transferAllPayments: _transferPayment,
              ),
        );
      },
    );
  }

  // ---- Shared pieces ----

  Widget _groupTiles(
    List<GroupModel> groups, {
    required int? selectedId,
    required ValueChanged<GroupModel> onTap,
  }) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      shrinkWrap: true,
      itemCount: groups.length,
      itemBuilder: (context, i) {
        final group = groups[i];
        final isSelected = selectedId == group.id;
        return ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          tileColor:
              isSelected ? AppColors.primary.withValues(alpha: 0.08) : null,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : AppColors.neutral100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                group.name.isNotEmpty ? group.name[0].toUpperCase() : 'G',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color:
                      isSelected ? AppColors.primary : AppColors.neutral600,
                ),
              ),
            ),
          ),
          title: Text(
            group.name,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.primary : AppColors.neutral900,
            ),
          ),
          subtitle: Text(
            group.teacherName,
            style: const TextStyle(fontSize: 12, color: AppColors.neutral500),
          ),
          trailing: isSelected
              ? const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary)
              : null,
          onTap: () => onTap(group),
        );
      },
    );
  }

  Widget _buildPaymentCheckbox() {
    return InkWell(
      onTap: () => setState(() => _transferPayment = !_transferPayment),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _transferPayment
                ? AppColors.primary.withValues(alpha: 0.06)
                : AppColors.neutral50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _transferPayment
                  ? AppColors.primary.withValues(alpha: 0.25)
                  : AppColors.neutral200,
            ),
          ),
          child: Row(
            children: [
              Checkbox(
                value: _transferPayment,
                onChanged: (v) => setState(() => _transferPayment = v ?? true),
                activeColor: AppColors.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Barcha to\'lovlarni ko\'chirish',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _transferPayment
                            ? AppColors.primary
                            : AppColors.neutral600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ushbu o\'quvchining barcha to\'lovlari yangi guruhga o\'tkaziladi',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.neutral400),
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

  Widget _confirmButton({
    required bool isLoading,
    required bool enabled,
    required String idleLabel,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: FilledButton(
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Text(idleLabel,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 15)),
      ),
    );
  }
}

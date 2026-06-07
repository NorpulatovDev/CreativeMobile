import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../groups/data/models/group_model.dart';
import '../bloc/transfer_student_cubit.dart';

class TransferStudentDialog extends StatefulWidget {
  final List<int> studentIds;
  final VoidCallback onSuccess;
  final ValueChanged<String> onError;

  const TransferStudentDialog({
    super.key,
    required this.studentIds,
    required this.onSuccess,
    required this.onError,
  });

  @override
  State<TransferStudentDialog> createState() => _TransferStudentDialogState();
}

class _TransferStudentDialogState extends State<TransferStudentDialog> {
  final _searchController = TextEditingController();
  GroupModel? _selectedGroup;
  String _query = '';
  bool _transferPayment = true;

  @override
  void initState() {
    super.initState();
    context.read<TransferStudentCubit>().loadGroups();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<GroupModel> _filtered(List<GroupModel> groups) {
    if (_query.trim().isEmpty) return groups;
    final q = _query.trim().toLowerCase();
    return groups
        .where((g) =>
            g.name.toLowerCase().contains(q) ||
            g.teacherName.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransferStudentCubit, TransferStudentState>(
      listener: (context, state) {
        if (state is TransferSuccess) {
          Navigator.pop(context);
          widget.onSuccess();
        } else if (state is TransferError && state is! TransferGroupsLoading) {
          if (state.groups.isEmpty) {
            Navigator.pop(context);
            widget.onError(state.message);
          }
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        clipBehavior: Clip.hardEdge,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450, maxHeight: 560),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              _buildSearch(),
              Flexible(child: _buildGroupList()),
              _buildPaymentCheckbox(),
              _buildConfirmButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

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
                  'Guruhga o\'tkazish',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.studentIds.length} ta o\'quvchi tanlanган',
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

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        onChanged: (v) => setState(() {
          _query = v;
          _selectedGroup = null;
        }),
        decoration: InputDecoration(
          hintText: 'Guruh nomini qidiring...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _query = '';
                      _selectedGroup = null;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildGroupList() {
    return BlocBuilder<TransferStudentCubit, TransferStudentState>(
      builder: (context, state) {
        if (state is TransferGroupsLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 28),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        List<GroupModel> groups = [];
        if (state is TransferGroupsLoaded) groups = state.groups;
        if (state is TransferInProgress) groups = state.groups;
        if (state is TransferError) groups = state.groups;

        final filtered = _filtered(groups);

        if (filtered.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.group_off_outlined,
                    size: 36, color: AppColors.neutral300),
                const SizedBox(height: 10),
                Text(
                  _query.isEmpty
                      ? 'Boshqa guruhlar mavjud emas'
                      : '"$_query" bo\'yicha guruh topilmadi',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppColors.neutral400, fontSize: 13),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shrinkWrap: true,
          itemCount: filtered.length,
          itemBuilder: (context, i) {
            final group = filtered[i];
            final isSelected = _selectedGroup?.id == group.id;
            return ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              tileColor: isSelected
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : null,
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
                    group.name.isNotEmpty
                        ? group.name[0].toUpperCase()
                        : 'G',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.neutral600,
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
                style: const TextStyle(
                    fontSize: 12, color: AppColors.neutral500),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check_circle_rounded,
                      color: AppColors.primary)
                  : null,
              onTap: () => setState(() => _selectedGroup = group),
            );
          },
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
                onChanged: (v) =>
                    setState(() => _transferPayment = v ?? true),
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
                      'Ushbu guruhda qilingan barcha to\'lovlar yangi guruhga o\'tkaziladi',
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

  Widget _buildConfirmButton() {
    return BlocBuilder<TransferStudentCubit, TransferStudentState>(
      builder: (context, state) {
        final isLoading = state is TransferInProgress;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: FilledButton(
            onPressed: (isLoading || _selectedGroup == null)
                ? null
                : () => context.read<TransferStudentCubit>().transfer(
                      studentIds: widget.studentIds,
                      toGroupId: _selectedGroup!.id,
                      transferAllPayments: _transferPayment,
                    ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    _selectedGroup == null
                        ? 'Guruh tanlang'
                        : '${widget.studentIds.length} ta o\'quvchini o\'tkazish',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15),
                  ),
          ),
        );
      },
    );
  }
}

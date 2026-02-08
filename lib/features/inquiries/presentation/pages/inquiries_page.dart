import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/phone_formatter.dart';
import '../../data/models/inquiry_model.dart';
import '../bloc/inquiry_bloc.dart';
import '../extensions/inquiry_status_extension.dart';

class InquiriesPage extends StatelessWidget {
  const InquiriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<InquiryBloc>()..add(InquiryLoadAll()),
      child: const InquiriesView(),
    );
  }
}

class InquiriesView extends StatefulWidget {
  const InquiriesView({super.key});

  @override
  State<InquiriesView> createState() => _InquiriesViewState();
}

class _InquiriesViewState extends State<InquiriesView> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  InquiryStatus? _selectedStatus;

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
              title: const Text(
                'So\'rovlar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral900,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.surfaceLight,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.neutral200),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neutral900.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) =>
                          setState(() => _searchQuery = value.toLowerCase()),
                      decoration: InputDecoration(
                        hintText: 'Qidirish...',
                        hintStyle: TextStyle(
                          color: AppColors.neutral400,
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: AppColors.neutral400,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: AppColors.neutral400,
                                ),
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
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                // Status filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'Barchasi',
                        isSelected: _selectedStatus == null,
                        onTap: () => _filterByStatus(null),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: InquiryStatus.newInquiry.displayName,
                        icon: InquiryStatus.newInquiry.icon,
                        color: InquiryStatus.newInquiry.color,
                        isSelected: _selectedStatus == InquiryStatus.newInquiry,
                        onTap: () => _filterByStatus(InquiryStatus.newInquiry),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: InquiryStatus.contacted.displayName,
                        icon: InquiryStatus.contacted.icon,
                        color: InquiryStatus.contacted.color,
                        isSelected: _selectedStatus == InquiryStatus.contacted,
                        onTap: () => _filterByStatus(InquiryStatus.contacted),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: InquiryStatus.enrolled.displayName,
                        icon: InquiryStatus.enrolled.icon,
                        color: InquiryStatus.enrolled.color,
                        isSelected: _selectedStatus == InquiryStatus.enrolled,
                        onTap: () => _filterByStatus(InquiryStatus.enrolled),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: InquiryStatus.rejected.displayName,
                        icon: InquiryStatus.rejected.icon,
                        color: InquiryStatus.rejected.color,
                        isSelected: _selectedStatus == InquiryStatus.rejected,
                        onTap: () => _filterByStatus(InquiryStatus.rejected),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          BlocConsumer<InquiryBloc, InquiryState>(
            listener: (context, state) {
              if (state is InquiryError) {
                _showSnackBar(
                  state.message,
                  AppColors.error,
                  Icons.error_outline,
                );
              }
              if (state is InquiryActionSuccess) {
                _showSnackBar(
                  state.message,
                  AppColors.success,
                  Icons.check_circle_outline,
                );
              }
            },
            builder: (context, state) {
              if (state is InquiryLoading && state is! InquiryLoaded) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }
              if (state is InquiryLoaded) {
                final filteredInquiries = _searchQuery.isEmpty
                    ? state.inquiries
                    : state.inquiries
                          .where(
                            (i) =>
                                i.fullName.toLowerCase().contains(
                                  _searchQuery,
                                ) ||
                                i.parentName.toLowerCase().contains(
                                  _searchQuery,
                                ) ||
                                i.parentPhoneNumber.contains(_searchQuery) ||
                                (i.interestedCourses?.toLowerCase().contains(
                                      _searchQuery,
                                    ) ??
                                    false),
                          )
                          .toList();

                if (state.inquiries.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.contact_phone_rounded,
                              size: 48,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'So\'rovlar yo\'q',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: AppColors.neutral700,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Birinchi so\'rov qo\'shing',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.neutral500),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (filteredInquiries.isEmpty) {
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
                            child: Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: AppColors.neutral400,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Natija topilmadi',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: AppColors.neutral700,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
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
                          inquiry: filteredInquiries[index],
                          onEdit: () => _showInquiryDialog(
                            context,
                            filteredInquiries[index],
                          ),
                          onDelete: () => _showDeleteDialog(
                            context,
                            filteredInquiries[index],
                          ),
                        ),
                      ),
                      childCount: filteredInquiries.length,
                    ),
                  ),
                );
              }
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showInquiryDialog(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Qo\'shish',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _showInquiryDialog(BuildContext context, [InquiryModel? inquiry]) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<InquiryBloc>(),
        child: InquiryFormDialog(inquiry: inquiry),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, InquiryModel inquiry) {
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
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  size: 32,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'So\'rovni o\'chirish',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Text(
                '${inquiry.fullName}ning so\'rovini o\'chirishni xohlaysizmi?',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.neutral500),
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
                        context.read<InquiryBloc>().add(
                          InquiryDelete(inquiry.id),
                        );
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
            color: isSelected ? chipColor : chipColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? chipColor : chipColor.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? Colors.white : chipColor,
                ),
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
      if (diff.inHours == 0) {
        return '${diff.inMinutes} daqiqa oldin';
      }
      return '${diff.inHours} soat oldin';
    } else if (diff.inDays == 1) {
      return 'Kecha';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} kun oldin';
    } else {
      const months = [
        'Yan',
        'Fev',
        'Mar',
        'Apr',
        'May',
        'Iyun',
        'Iyul',
        'Avg',
        'Sen',
        'Okt',
        'Noy',
        'Dek',
      ];
      return '${date.day} ${months[date.month - 1]}';
    }
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
              color: inquiry.status.color.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.neutral900.withOpacity(0.03),
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
                      color: inquiry.status.color.withOpacity(0.1),
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
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 12,
                              color: AppColors.neutral400,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(inquiry.createdAt),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.neutral400),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert_rounded,
                      color: AppColors.neutral400,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit();
                      } else if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_rounded,
                              size: 20,
                              color: AppColors.neutral600,
                            ),
                            const SizedBox(width: 12),
                            const Text('Tahrirlash'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_rounded,
                              size: 20,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'O\'chirish',
                              style: TextStyle(color: AppColors.error),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: inquiry.status.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      inquiry.status.icon,
                      size: 16,
                      color: inquiry.status.color,
                    ),
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
              // _InfoRow for Parent Name remains in the Card so you can see details,
              // but we removed the input from the Dialog.

              // const SizedBox(height: 6),
              _InfoRow(
                icon: Icons.phone_outlined,
                label: PhoneValidator.toDisplayFormat(
                  inquiry.parentPhoneNumber,
                ),
              ),
              if (inquiry.interestedCourses != null &&
                  inquiry.interestedCourses!.isNotEmpty) ...[
                const SizedBox(height: 6),
                _InfoRow(
                  icon: Icons.school_outlined,
                  label: inquiry.interestedCourses!,
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
                      Icon(
                        Icons.note_outlined,
                        size: 16,
                        color: AppColors.neutral500,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          inquiry.notes!,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.neutral600,
                          ),
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
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.neutral600),
          ),
        ),
      ],
    );
  }
}

class InquiryFormDialog extends StatefulWidget {
  final InquiryModel? inquiry;

  const InquiryFormDialog({super.key, this.inquiry});

  @override
  State<InquiryFormDialog> createState() => _InquiryFormDialogState();
}

class _InquiryFormDialogState extends State<InquiryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController = TextEditingController(
    text: widget.inquiry?.fullName,
  );

  // REMOVED: _parentNameController

  late final TextEditingController _phoneController = TextEditingController(
    text: widget.inquiry != null
        ? PhoneValidator.toDisplayFormat(widget.inquiry!.parentPhoneNumber)
        : '+998 ',
  );
  late final TextEditingController _coursesController = TextEditingController(
    text: widget.inquiry?.interestedCourses,
  );
  late final TextEditingController _notesController = TextEditingController(
    text: widget.inquiry?.notes,
  );
  late InquiryStatus _selectedStatus =
      widget.inquiry?.status ?? InquiryStatus.newInquiry;
  bool _submitting = false;
  bool get isEditing => widget.inquiry != null;

  @override
  void dispose() {
    _nameController.dispose();
    // REMOVED: _parentNameController.dispose();
    _phoneController.dispose();
    _coursesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
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
                          isEditing ? 'So\'rovni tahrirlash' : 'Yangi so\'rov',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isEditing
                              ? 'Ma\'lumotlarni yangilash'
                              : 'So\'rov ma\'lumotlarini kiriting',
                          style: Theme.of(context).textTheme.bodySmall
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
                      // REMOVED: Parent Name TextField
                      _buildPhoneField(),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _coursesController,
                        label: 'Qiziqish bildirgan kurslar (ixtiyoriy)',
                        hint: 'Masalan: Ingliz tili, Matematika',
                        icon: Icons.school_outlined,
                      ),
                      if (isEditing) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Holat',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.neutral700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: InquiryStatus.values.map((status) {
                            final isSelected = _selectedStatus == status;
                            return InkWell(
                              onTap: () =>
                                  setState(() => _selectedStatus = status),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? status.color
                                      : status.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: status.color,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      status.icon,
                                      size: 16,
                                      color: isSelected
                                          ? Colors.white
                                          : status.color,
                                    ),
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
                  bottom: Radius.circular(24),
                ),
              ),
              child: Row(
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
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.neutral700,
        ),
      ),
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
      Text(
        'Telefon raqami',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.neutral700,
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        inputFormatters: [
          // Use the safe formatter here
          UzbekPhoneNumberFormatter(),
        ],
        // Check for valid length (e.g. 17 chars for "+998 90 123 45 67")
        validator: (value) {
          if (value == null || value.length < 17) {
            return 'Telefon raqamini to\'liq kiriting';
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: '+998 XX XXX XX XX',
          prefixIcon: Icon(Icons.phone_outlined, color: AppColors.neutral400),
          helperText: 'Format: +998 97 123 45 67',
          helperStyle: TextStyle(fontSize: 11, color: AppColors.neutral400),
        ),
      ),
    ],
  );

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _submitting = true);
      final bloc = context.read<InquiryBloc>();

      // 1. Remove all non-digit characters (leaves only 998901234567)
      final digitsOnly = _phoneController.text.replaceAll(RegExp(r'\D'), '');

      // 2. Add the plus sign back
      final formattedPhone = '+$digitsOnly';

      if (isEditing) {
        bloc.add(
          InquiryUpdate(
            id: widget.inquiry!.id,
            fullName: _nameController.text.trim(),
            parentName: 'Unknown',
            parentPhoneNumber: formattedPhone, // Sends +998901234567
            interestedCourses: _coursesController.text.trim().isEmpty
                ? null
                : _coursesController.text.trim(),
            status: _selectedStatus,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          ),
        );
      } else {
        bloc.add(
          InquiryCreate(
            fullName: _nameController.text.trim(),
            parentName: 'Unknown',
            parentPhoneNumber: formattedPhone, // Sends +998901234567
            interestedCourses: _coursesController.text.trim().isEmpty
                ? null
                : _coursesController.text.trim(),
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          ),
        );
      }
      Navigator.pop(context);
    }
  }
}

// Add this class at the bottom of the file if you haven't
// updated your core/utils/phone_formatter.dart yet.
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
    if (body.startsWith('998')) {
      body = body.substring(3);
    }

    if (body.length > 9) {
      body = body.substring(0, 9);
    }

    final buffer = StringBuffer();
    buffer.write('+998 ');

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

    if (body.length > 7) {
      buffer.write(body.substring(7));
    }

    final formattedText = buffer.toString();

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

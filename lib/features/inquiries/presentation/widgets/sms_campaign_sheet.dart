import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/sms_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/inquiry_group_model.dart';
import '../../data/models/inquiry_model.dart';

class SmsCampaignSheet extends StatefulWidget {
  final InquiryGroupModel group;
  final List<InquiryModel> inquiries;

  const SmsCampaignSheet({
    super.key,
    required this.group,
    required this.inquiries,
  });

  @override
  State<SmsCampaignSheet> createState() => _SmsCampaignSheetState();
}

class _SmsCampaignSheetState extends State<SmsCampaignSheet> {
  static const _keyPrefix = 'sms_template_';

  final _controller = TextEditingController();
  bool _loading = true;
  final Set<int> _sentIds = {};

  @override
  void initState() {
    super.initState();
    _loadTemplate();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _loadTemplate() {
    final prefs = getIt<SharedPreferences>();
    final saved = prefs.getString('$_keyPrefix${widget.group.id}');
    if (saved != null) _controller.text = saved;
    setState(() => _loading = false);
  }

  void _saveTemplate() {
    getIt<SharedPreferences>()
        .setString('$_keyPrefix${widget.group.id}', _controller.text);
  }

  void _insertPlaceholder(String placeholder) {
    final text = _controller.text;
    final sel = _controller.selection;
    final start = sel.start.clamp(0, text.length);
    final end = sel.end.clamp(0, text.length);
    final newText = text.replaceRange(start, end, placeholder);
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + placeholder.length),
    );
    _saveTemplate();
  }

  String _render(String studentName) => _controller.text
      .replaceAll('{ismi}', studentName)
      .replaceAll('{guruh}', widget.group.name);

  void _showPermissionSettingsDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('SMS ruxsati kerak'),
        content: const Text(
          'SMS yuborish uchun ilova sozlamalaridan SMS ruxsatini yoqing.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: const Text('Sozlamalar'),
          ),
        ],
      ),
    );
  }

  Future<void> _send(int inquiryId, String phone, String studentName) async {
    _saveTemplate();
    final result =
        await getIt<SmsService>().send(phone, _render(studentName));
    if (!mounted) return;
    if (result == SmsResult.sent) {
      setState(() => _sentIds.add(inquiryId));
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(
          content: Text('SMS yuborildi: $studentName'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
        ));
    } else if (result == SmsResult.permissionPermanentlyDenied) {
      _showPermissionSettingsDialog();
    } else if (result == SmsResult.permissionDenied) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(
          content: const Text('SMS ruxsati berilmagan'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ));
    } else if (result == SmsResult.failed) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(
          content: Text('SMS yuborib bo\'lmadi: $phone'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final template = _controller.text.trim();
    final preview = template.isEmpty ? null : _render('Abdulloh');

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        if (_loading) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }

        return Column(
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
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.campaign_rounded,
                        color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SMS kampaniyasi',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.neutral900,
                          ),
                        ),
                        Text(
                          widget.group.name,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.neutral500),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                children: [
                  _SectionLabel('Xabar shabloni'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _controller,
                    maxLines: 4,
                    onChanged: (_) => _saveTemplate(),
                    decoration: const InputDecoration(
                      hintText: 'Xabar matnini kiriting...',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text('Qo\'shish:',
                          style: TextStyle(
                              fontSize: 13, color: AppColors.neutral500)),
                      const SizedBox(width: 10),
                      _PlaceholderChip(
                        label: '+ Ismi',
                        onTap: () => _insertPlaceholder('{ismi}'),
                      ),
                      const SizedBox(width: 8),
                      _PlaceholderChip(
                        label: '+ Guruh',
                        onTap: () => _insertPlaceholder('{guruh}'),
                      ),
                    ],
                  ),
                  if (preview != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.visibility_outlined,
                                  size: 14, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Text(
                                'Ko\'rinish',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(preview,
                              style: const TextStyle(
                                  fontSize: 14, color: AppColors.neutral700)),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  _SectionLabel(
                      'So\'rovchilar (${widget.inquiries.length})'),
                  const SizedBox(height: 10),
                  if (widget.inquiries.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text('So\'rovlar yo\'q',
                            style: TextStyle(color: AppColors.neutral400)),
                      ),
                    )
                  else
                    ...widget.inquiries.map(
                      (inquiry) => _StudentRow(
                        inquiry: inquiry,
                        canSend: template.isNotEmpty,
                        sent: _sentIds.contains(inquiry.id),
                        onSend: () => _send(
                            inquiry.id,
                            inquiry.parentPhoneNumber,
                            inquiry.fullName),
                      ),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.neutral700,
        ),
      );
}

class _PlaceholderChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PlaceholderChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _StudentRow extends StatelessWidget {
  final InquiryModel inquiry;
  final bool canSend;
  final bool sent;
  final VoidCallback onSend;

  const _StudentRow({
    required this.inquiry,
    required this.canSend,
    required this.sent,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                inquiry.fullName.isNotEmpty
                    ? inquiry.fullName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
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
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                Text(
                  inquiry.parentPhoneNumber,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.neutral500),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: (canSend && !sent) ? onSend : null,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: sent
                    ? AppColors.success.withValues(alpha: 0.1)
                    : canSend
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.neutral100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    sent ? Icons.check_rounded : Icons.sms_rounded,
                    size: 16,
                    color: sent
                        ? AppColors.success
                        : canSend
                            ? AppColors.primary
                            : AppColors.neutral400,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    sent ? 'Yuborildi' : 'Yuborish',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: sent
                          ? AppColors.success
                          : canSend
                              ? AppColors.primary
                              : AppColors.neutral400,
                    ),
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

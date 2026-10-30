import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/sms_template_renderer.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/sms_template_model.dart';
import '../bloc/sms_templates_cubit.dart';

const _titles = {
  SmsTemplateType.paymentReceived: "To'lov qabul qilindi",
  SmsTemplateType.attendanceAbsent: 'Darsga kelmadi',
};

const _descriptions = {
  SmsTemplateType.paymentReceived: "To'lov qo'shilganda ota-onaga yuboriladi",
  SmsTemplateType.attendanceAbsent:
      'Davomatda kelmagan deb belgilanganlarning ota-onasiga yuboriladi',
};

const _placeholderLabels = {
  'oquvchi': "O'quvchi ismi",
  'oy': 'Oy',
  'summa': 'Summa',
  'sana': 'Sana',
  'guruh': 'Guruh',
  'oqituvchi': "O'qituvchi",
};

// Sample values for the live preview.
const _sample = {
  'oquvchi': 'Ali Valiyev',
  'oy': 'Oktyabr',
  'summa': '500000',
  'sana': '30.10.2026',
  'guruh': 'English A1',
  'oqituvchi': 'Dilnoza Karimova',
};

/// SUPER_ADMIN: edit the texts of the automatic SMS sent to parents.
class SmsTemplatesPage extends StatelessWidget {
  const SmsTemplatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SmsTemplatesCubit(getIt())..load(),
      child: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('SMS shablonlari',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
      ),
      body: BlocConsumer<SmsTemplatesCubit, SmsTemplatesState>(
        listenWhen: (_, curr) => curr is SmsTemplatesLoaded && curr.message != null,
        listener: (context, state) {
          final s = state as SmsTemplatesLoaded;
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(SnackBar(
              content: Text(s.message!),
              backgroundColor: s.isError ? AppColors.error : AppColors.success,
              behavior: SnackBarBehavior.floating,
            ));
        },
        builder: (context, state) {
          if (state is SmsTemplatesLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SmsTemplatesError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.neutral600)),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => context.read<SmsTemplatesCubit>().load(),
                      child: const Text('Qayta urinish'),
                    ),
                  ],
                ),
              ),
            );
          }
          final loaded = state as SmsTemplatesLoaded;
          return RefreshIndicator(
            onRefresh: () => context.read<SmsTemplatesCubit>().load(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: loaded.templates.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final t = loaded.templates[i];
                return _TemplateCard(
                  template: t,
                  saving: loaded.savingType == t.type,
                  onTap: () => _openEditor(context, t),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _openEditor(BuildContext context, SmsTemplateModel template) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<SmsTemplatesCubit>(),
        child: _EditSheet(template: template),
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final SmsTemplateModel template;
  final bool saving;
  final VoidCallback onTap;

  const _TemplateCard({
    required this.template,
    required this.saving,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor =
        template.customized ? AppColors.primary : AppColors.neutral500;
    return Material(
      color: AppColors.surfaceLight,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: saving ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.sms_rounded, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(_titles[template.type] ?? template.type,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                  if (saving)
                    const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        template.customized ? "O'zgartirilgan" : 'Standart',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: badgeColor),
                      ),
                    ),
                ],
              ),
              if (_descriptions[template.type] != null) ...[
                const SizedBox(height: 4),
                Text(_descriptions[template.type]!,
                    style:
                        TextStyle(fontSize: 12, color: AppColors.neutral500)),
              ],
              const SizedBox(height: 12),
              Text(template.body,
                  style: TextStyle(
                      fontSize: 14, height: 1.4, color: AppColors.neutral700)),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditSheet extends StatefulWidget {
  final SmsTemplateModel template;

  const _EditSheet({required this.template});

  @override
  State<_EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends State<_EditSheet> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.template.body);
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _insert(String key) {
    final token = '{$key}';
    final sel = _controller.selection;
    final text = _controller.text;
    final start = sel.isValid ? sel.start : text.length;
    final end = sel.isValid ? sel.end : text.length;
    _controller.value = TextEditingValue(
      text: text.replaceRange(start, end, token),
      selection: TextSelection.collapsed(offset: start + token.length),
    );
    setState(() {});
  }

  Future<void> _run(Future<bool> Function() action) async {
    setState(() => _busy = true);
    final ok = await action();
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SmsTemplatesCubit>();
    final text = _controller.text;
    final preview = renderSmsTemplate(text, _sample);
    // Rough GSM-7 segmenting; Latin Uzbek fits, apostrophes included.
    final parts = preview.isEmpty ? 0 : (preview.length / 153).ceil();
    final canSave = text.trim().isNotEmpty && text.length <= 1000 && !_busy;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.neutral300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(_titles[widget.template.type] ?? widget.template.type,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              minLines: 4,
              maxLines: 10,
              maxLength: 1000,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(hintText: 'SMS matni'),
            ),
            const SizedBox(height: 4),
            Text("O'zgaruvchi qo'shish:",
                style: TextStyle(fontSize: 13, color: AppColors.neutral600)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final p in widget.template.placeholders)
                  ActionChip(
                    label: Text('${_placeholderLabels[p] ?? p}  {$p}'),
                    onPressed: _busy ? null : () => _insert(p),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text("Ko'rinishi",
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral700)),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(preview.isEmpty ? '—' : preview,
                  style: const TextStyle(fontSize: 14, height: 1.4)),
            ),
            const SizedBox(height: 4),
            Text('${preview.length} belgi · ~$parts ta SMS',
                style: TextStyle(fontSize: 12, color: AppColors.neutral500)),
            const SizedBox(height: 20),
            Row(
              children: [
                if (widget.template.customized) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _busy
                          ? null
                          : () => _run(() => cubit.reset(widget.template.type)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: AppColors.neutral300),
                      ),
                      child: const Text('Standartga qaytarish'),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: canSave
                        ? () => _run(
                            () => cubit.save(widget.template.type, text.trim()))
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Saqlash',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

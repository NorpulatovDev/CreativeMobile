import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../data/repositories/sms_link_repository.dart';

class SmsLinkDialog extends StatefulWidget {
  final int studentId;
  final String studentName;
  final String? currentCode;
  final bool isLinked;
  final VoidCallback onSuccess;

  const SmsLinkDialog({
    super.key,
    required this.studentId,
    required this.studentName,
    this.currentCode,
    required this.isLinked,
    required this.onSuccess,
  });

  @override
  State<SmsLinkDialog> createState() => _SmsLinkDialogState();
}

class _SmsLinkDialogState extends State<SmsLinkDialog> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _loading = false;
  bool _linkByCode = true;

  @override
  void initState() {
    super.initState();
    _codeController.text = widget.currentCode ?? '';
  }

  @override
  void dispose() {
    _codeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isLinked ? 'SMS Link Status' : 'Link SMS Notifications'),
      content: widget.isLinked
          ? _buildLinkedContent()
          : _buildLinkForm(),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        if (!widget.isLinked)
          FilledButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Link'),
          ),
      ],
    );
  }

  Widget _buildLinkedContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.check_circle,
          size: 64,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          '${widget.studentName} is linked for SMS notifications',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        if (widget.currentCode != null) ...[
          const SizedBox(height: 8),
          Text(
            'Code: ${widget.currentCode}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ],
    );
  }

  Widget _buildLinkForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Link ${widget.studentName} for SMS notifications',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('By Code')),
              ButtonSegment(value: false, label: Text('By Phone')),
            ],
            selected: {_linkByCode},
            onSelectionChanged: (value) {
              setState(() => _linkByCode = value.first);
            },
          ),
          const SizedBox(height: 16),
          if (_linkByCode) ...[
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'SMS Link Code',
                hintText: 'STU-XXXXX',
                prefixIcon: Icon(Icons.qr_code),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the SMS link code';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
          ],
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              hintText: '+998XXXXXXXXX',
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter phone number';
              }
              if (!RegExp(r'^\+998[0-9]{9}$').hasMatch(value)) {
                return 'Format: +998XXXXXXXXX';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loading = true);

    final repository = getIt<SmsLinkRepository>();
    final phone = _phoneController.text.trim();

    if (_linkByCode) {
      final code = _codeController.text.trim();
      final (response, failure) = await repository.linkByCode(code, phone);

      if (mounted) {
        setState(() => _loading = false);
        if (failure != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${response!.fullName} linked successfully')),
          );
          Navigator.pop(context);
          widget.onSuccess();
        }
      }
    } else {
      final (responses, failure) = await repository.linkByPhone(phone);

      if (mounted) {
        setState(() => _loading = false);
        if (failure != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        } else {
          final count = responses?.length ?? 0;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$count student(s) linked successfully')),
          );
          Navigator.pop(context);
          widget.onSuccess();
        }
      }
    }
  }
}

/// A simple button to show SMS link status and open link dialog
class SmsLinkStatusButton extends StatelessWidget {
  final int studentId;
  final String studentName;
  final String? smsLinkCode;
  final bool smsLinked;
  final VoidCallback onStatusChanged;

  const SmsLinkStatusButton({
    super.key,
    required this.studentId,
    required this.studentName,
    this.smsLinkCode,
    required this.smsLinked,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(
        smsLinked ? Icons.notifications_active : Icons.notifications_off,
        size: 18,
        color: smsLinked
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.outline,
      ),
      label: Text(smsLinked ? 'SMS Linked' : 'Link SMS'),
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) => SmsLinkDialog(
            studentId: studentId,
            studentName: studentName,
            currentCode: smsLinkCode,
            isLinked: smsLinked,
            onSuccess: onStatusChanged,
          ),
        );
      },
    );
  }
}
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/theme/app_theme.dart';

/// Central place to see and grant the device permissions the app needs.
///
/// Permissions are otherwise only ever asked for at the moment they are used —
/// `SmsService.send()` requests SMS mid-send — which is a bad time to discover
/// the permission was permanently denied, because Android will not show the
/// system prompt again and the send just fails. Here the admin can see the state
/// up front and fix it, including jumping to system settings when Android has
/// stopped asking.
class PermissionsPage extends StatefulWidget {
  const PermissionsPage({super.key});

  @override
  State<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage>
    with WidgetsBindingObserver {
  PermissionStatus? _smsStatus;
  bool _requesting = false;

  /// True once a request has come back without being granted — meaning asking
  /// again will not produce a prompt, so the button must switch to settings.
  bool _promptExhausted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// The admin may grant the permission in system settings and come back, so the
  /// status is re-read whenever the app returns to the foreground. Without this
  /// the page would keep showing "denied" after it had been granted.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refresh();
    }
  }

  Future<void> _refresh() async {
    if (kIsWeb) return;
    final status = await Permission.sms.status;
    if (!mounted) return;
    setState(() {
      _smsStatus = status;
      // Granted in system settings and came back — the prompt is moot now, so
      // stop forcing the settings route.
      if (status.isGranted) _promptExhausted = false;
    });
  }

  Future<void> _requestSms() async {
    setState(() => _requesting = true);

    PermissionStatus status;
    try {
      status = await Permission.sms.request();
    } catch (e) {
      // Never leave the spinner running on a failure — that reads as a dead button.
      if (!mounted) return;
      setState(() => _requesting = false);
      _showMessage('Ruxsat so\'rashda xatolik: $e', offerSettings: true);
      return;
    }

    if (!mounted) return;
    setState(() {
      _smsStatus = status;
      _requesting = false;
      // Android silently stops prompting after repeated refusals, and on some
      // versions still reports plain `denied` rather than `permanentlyDenied`.
      // Either way this request produced no prompt, so from here the only route
      // that works is system settings.
      _promptExhausted = !status.isGranted;
    });

    if (status.isGranted) {
      _showMessage('SMS ruxsati berildi');
    } else {
      _showMessage(
        'Ruxsat berilmadi. Android boshqa so\'ramasligi mumkin — '
        'sozlamalardan qo\'lda yoqing.',
        offerSettings: true,
      );
    }
  }

  /// Every path through a request ends in visible feedback. Without this a
  /// request that Android refuses to prompt for looks like a button that does
  /// nothing at all.
  void _showMessage(String text, {bool offerSettings = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          duration: const Duration(seconds: 6),
          action: offerSettings
              ? SnackBarAction(label: 'Sozlamalar', onPressed: openAppSettings)
              : null,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Ruxsatlar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Ilova qurilmangizdan foydalanishi uchun kerakli ruxsatlar.',
            style: TextStyle(fontSize: 13, color: AppColors.neutral500),
          ),
          const SizedBox(height: 16),
          _PermissionCard(
            icon: Icons.sms_rounded,
            title: 'SMS yuborish',
            description:
                'Davomat va to\'lov xabarlarini shu qurilmaning SIM kartasi '
                'orqali yuborish uchun kerak. Ruxsatsiz SMS yuborilmaydi.',
            status: _smsStatus,
            busy: _requesting,
            promptExhausted: _promptExhausted,
            onRequest: _requestSms,
            onOpenSettings: openAppSettings,
          ),
        ],
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final PermissionStatus? status;
  final bool busy;
  final bool promptExhausted;
  final VoidCallback onRequest;
  final VoidCallback onOpenSettings;

  const _PermissionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.status,
    required this.busy,
    required this.promptExhausted,
    required this.onRequest,
    required this.onOpenSettings,
  });

  /// SMS is sent through an Android platform channel, so on the web build the
  /// permission neither exists nor can be granted — saying so is more honest
  /// than showing a button that cannot work.
  bool get _unsupported => kIsWeb;

  ({String label, Color color, IconData icon}) get _badge {
    if (_unsupported) {
      return (
        label: 'Mavjud emas',
        color: AppColors.neutral500,
        icon: Icons.remove_circle_outline_rounded,
      );
    }
    if (status == null) {
      return (
        label: 'Tekshirilmoqda',
        color: AppColors.neutral500,
        icon: Icons.hourglass_empty_rounded,
      );
    }
    if (status!.isGranted) {
      return (
        label: 'Ruxsat berilgan',
        color: AppColors.successDark,
        icon: Icons.check_circle_rounded,
      );
    }
    if (status!.isPermanentlyDenied) {
      return (
        label: 'Butunlay rad etilgan',
        color: AppColors.errorDark,
        icon: Icons.block_rounded,
      );
    }
    return (
      label: 'Ruxsat berilmagan',
      color: AppColors.warningDark,
      icon: Icons.error_outline_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final badge = _badge;
    final granted = !_unsupported && (status?.isGranted ?? false);
    // Either Android told us outright, or a request came back with no prompt.
    final settingsOnly = !_unsupported &&
        !granted &&
        ((status?.isPermanentlyDenied ?? false) || promptExhausted);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neutral400.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: badge.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: badge.color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: AppColors.neutral600,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(badge.icon, size: 16, color: badge.color),
              const SizedBox(width: 6),
              Text(
                badge.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: badge.color,
                ),
              ),
            ],
          ),
          if (!_unsupported && !granted) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: busy
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  : FilledButton.icon(
                      // Once Android stops prompting, request() returns
                      // immediately without showing anything — the only route
                      // left is the system settings screen.
                      onPressed: settingsOnly ? onOpenSettings : onRequest,
                      icon: Icon(
                        settingsOnly
                            ? Icons.settings_rounded
                            : Icons.lock_open_rounded,
                        size: 18,
                      ),
                      label: Text(
                        settingsOnly ? 'Sozlamalarni ochish' : 'Ruxsat berish',
                      ),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

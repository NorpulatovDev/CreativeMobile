import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../di/injection.dart';
import '../services/sms_service.dart';
import '../theme/app_theme.dart';

class SmsPermissionGate extends StatefulWidget {
  final Widget child;

  const SmsPermissionGate({super.key, required this.child});

  @override
  State<SmsPermissionGate> createState() => _SmsPermissionGateState();
}

class _SmsPermissionGateState extends State<SmsPermissionGate> with WidgetsBindingObserver {
  PermissionStatus _status = PermissionStatus.denied;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_status.isGranted) {
      _checkPermission();
    }
  }

  Future<void> _checkPermission() async {
    final status = await Permission.sms.status;
    if (mounted) setState(() { _status = status; _checking = false; });
  }

  Future<void> _requestPermission() async {
    final status = await getIt<SmsService>().requestPermission();
    if (mounted) setState(() => _status = status);
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_status.isGranted) return widget.child;
    return _PermissionBlockScreen(
      isPermanentlyDenied: _status.isPermanentlyDenied,
      onRequest: _requestPermission,
    );
  }
}

class _PermissionBlockScreen extends StatelessWidget {
  final bool isPermanentlyDenied;
  final VoidCallback onRequest;

  const _PermissionBlockScreen({required this.isPermanentlyDenied, required this.onRequest});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.sms_outlined, size: 48, color: AppColors.primary),
              ),
              const SizedBox(height: 32),
              const Text(
                'SMS ruxsati kerak',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.neutral800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                isPermanentlyDenied
                    ? "SMS ruxsati rad etilgan. Sozlamalar → Ruxsatlar → SMS ni yoqing."
                    : "Bu sahifadan foydalanish uchun SMS yuborish ruxsati talab etiladi.",
                style: const TextStyle(fontSize: 15, color: AppColors.neutral500, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isPermanentlyDenied ? openAppSettings : onRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text(
                    isPermanentlyDenied ? "Sozlamalarni ochish" : "Ruxsat berish",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

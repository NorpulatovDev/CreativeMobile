import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

enum SmsResult { sent, failed, permissionDenied, permissionPermanentlyDenied, notAvailable }

class SmsService {
  static const _channel = MethodChannel('com.example.creative/sms');

  Future<SmsResult> send(String phone, String message) async {
    if (kIsWeb) return SmsResult.notAvailable;

    final status = await Permission.sms.status;
    if (status.isPermanentlyDenied) return SmsResult.permissionPermanentlyDenied;

    if (!status.isGranted) {
      final result = await Permission.sms.request();
      if (result.isPermanentlyDenied) return SmsResult.permissionPermanentlyDenied;
      if (!result.isGranted) return SmsResult.permissionDenied;
    }

    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    try {
      await _channel.invokeMethod('sendSms', {
        'phone': cleaned,
        'message': message,
      });
      return SmsResult.sent;
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') return SmsResult.permissionDenied;
      return SmsResult.failed;
    } catch (_) {
      return SmsResult.notAvailable;
    }
  }
}

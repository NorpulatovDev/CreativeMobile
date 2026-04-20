import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class SmsService {
  static const _channel = MethodChannel('com.example.creative/sms');

  Future<PermissionStatus> requestPermission() => Permission.sms.request();

  Future<SmsResult> send(String phone, String message) async {
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    try {
      await _channel.invokeMethod('sendSms', {
        'phone': cleaned,
        'message': message,
      });
      return SmsResult.sent;
    } on PlatformException catch (e) {
      if (e.code == 'CANCELLED') return SmsResult.cancelled;
      if (e.code == 'PERMISSION_DENIED') return SmsResult.permissionDenied;
      return SmsResult.failed;
    } catch (_) {
      return SmsResult.failed;
    }
  }
}

enum SmsResult { sent, cancelled, permissionDenied, failed }

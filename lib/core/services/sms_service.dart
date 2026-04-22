import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:permission_handler/permission_handler.dart';

enum SmsResult { sent, failed, permissionDenied, permissionPermanentlyDenied, notAvailable }

class SmsService {
  Future<SmsResult> send(String phone, String message) async {
    if (kIsWeb) return SmsResult.notAvailable;

    if (Platform.isAndroid) {
      final status = await Permission.sms.status;
      if (status.isPermanentlyDenied) {
        return SmsResult.permissionPermanentlyDenied;
      }
      if (!status.isGranted) {
        final result = await Permission.sms.request();
        if (result.isPermanentlyDenied) {
          return SmsResult.permissionPermanentlyDenied;
        }
        if (!result.isGranted) {
          return SmsResult.permissionDenied;
        }
      }
    }

    if (Platform.isIOS) {
      final capable = await canSendSMS();
      if (!capable) return SmsResult.notAvailable;
    }

    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    try {
      final result = await sendSMS(
        message: message,
        recipients: [cleaned],
        sendDirect: Platform.isAndroid,
      );
      return result.toLowerCase().contains('sent')
          ? SmsResult.sent
          : SmsResult.failed;
    } catch (_) {
      return SmsResult.failed;
    }
  }
}

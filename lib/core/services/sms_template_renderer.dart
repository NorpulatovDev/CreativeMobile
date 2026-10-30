/// Shared by every place that composes an automatic SMS on this device.
/// Placeholder names and default texts mirror the backend's `SmsTemplateType`.
class SmsTemplateType {
  static const paymentReceived = 'PAYMENT_RECEIVED';
  static const attendanceAbsent = 'ATTENDANCE_ABSENT';

  /// Used when the server and the offline cache are both unavailable.
  static const defaults = <String, String>{
    paymentReceived:
        "Assalomu alaykum!\nCreative O'quv Markazi ma'muriyati sizga ma'lum qiladiki, "
            "{oquvchi}ning {oy} oyi uchun {summa} so'm to'lovi qabul qilindi.\nRahmat!",
    attendanceAbsent:
        "Hurmatli ota-ona,\nCreative O'quv Markazi: {oquvchi} bugun ({sana}) darsga kelmadi.\n"
            "Iltimos, kelmaslik sababini bizga ma'lum qiling.",
  };
}

/// Replaces each `{key}` in [body] with its value; unknown keys are left as-is.
String renderSmsTemplate(String body, Map<String, String> vars) {
  var result = body;
  vars.forEach((key, value) => result = result.replaceAll('{$key}', value));
  return result;
}

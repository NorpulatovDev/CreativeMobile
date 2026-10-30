import 'package:creative/core/services/sms_template_renderer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('default absence template renders the same text as before', () {
    final out = renderSmsTemplate(
      SmsTemplateType.defaults[SmsTemplateType.attendanceAbsent]!,
      {'oquvchi': 'Ali Valiyev', 'sana': '30.10.2026', 'guruh': 'English A1'},
    );
    expect(
      out,
      "Hurmatli ota-ona,\nCreative O'quv Markazi: Ali Valiyev bugun (30.10.2026) darsga kelmadi.\n"
      "Iltimos, kelmaslik sababini bizga ma'lum qiling.",
    );
  });

  test('default payment template renders the same text as before', () {
    final out = renderSmsTemplate(
      SmsTemplateType.defaults[SmsTemplateType.paymentReceived]!,
      {'oquvchi': 'Ali', 'oy': 'Oktyabr', 'summa': '500000', 'guruh': 'G'},
    );
    expect(
      out,
      "Assalomu alaykum!\nCreative O'quv Markazi ma'muriyati sizga ma'lum qiladiki, "
      "Alining Oktyabr oyi uchun 500000 so'm to'lovi qabul qilindi.\nRahmat!",
    );
  });

  test('unknown placeholders are left untouched', () {
    expect(renderSmsTemplate('{oquvchi} {x}', {'oquvchi': 'Ali'}), 'Ali {x}');
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_manager/core/utils/extensions.dart';

void main() {
  group('StringExtensions — isValidMac', () {
    test('يقبل MAC صحيح بنقطتين', () => expect('AA:BB:CC:DD:EE:FF'.isValidMac, isTrue));
    test('يقبل MAC صحيح بشرطة', () => expect('AA-BB-CC-DD-EE-FF'.isValidMac, isTrue));
    test('يقبل MAC بدون فواصل 12 حرف', () => expect('AABBCCDDEEFF'.isValidMac, isTrue));
    test('يرفض MAC ناقص', () => expect('AA:BB:CC'.isValidMac, isFalse));
    test('يرفض نص فارغ', () => expect(''.isValidMac, isFalse));
    test('يرفض IP كـ MAC', () => expect('192.168.1.1'.isValidMac, isFalse));
  });

  group('StringExtensions — formatMac', () {
    test('يُحوّل 12 حرف بدون فواصل', () => expect('AABBCCDDEEFF'.formatMac, 'AA:BB:CC:DD:EE:FF'));
    test('يُحوّل إلى أحرف كبيرة', () => expect('aa:bb:cc:dd:ee:ff'.formatMac, 'AA:BB:CC:DD:EE:FF'));
    test('يُحوّل MAC بشرطة', () => expect('AA-BB-CC-DD-EE-FF'.formatMac, 'AA:BB:CC:DD:EE:FF'));
    test('يُعيد القيمة عند خطأ', () => expect('AA:BB'.formatMac, 'AA:BB'));
  });

  group('StringExtensions — isValidIp', () {
    test('يقبل IP صحيح', () => expect('192.168.1.1'.isValidIp, isTrue));
    test('يقبل 10.0.0.1', () => expect('10.0.0.1'.isValidIp, isTrue));
    test('يرفض رقم > 255', () => expect('192.168.1.256'.isValidIp, isFalse));
    test('يرفض نص عشوائي', () => expect('hello.world'.isValidIp, isFalse));
    test('يرفض IP ناقص', () => expect('192.168.1'.isValidIp, isFalse));
    test('يرفض نص فارغ', () => expect(''.isValidIp, isFalse));
  });

  group('StringExtensions — extractOui', () {
    test('يستخرج أول 6 أحرف', () => expect('AA:BB:CC:DD:EE:FF'.extractOui, 'AABBCC'));
    test('يتعامل مع MAC قصير', () => expect('AA:BB'.extractOui, ''));
  });

  group('IntExtensions — toSpeed', () {
    test('أقل من 1000 → Kbps', () => expect(512.toSpeed, '512 Kbps'));
    test('1000 → Mbps', () => expect(1000.toSpeed, '1.0 Mbps'));
    test('5000 → Mbps', () => expect(5000.toSpeed, '5.0 Mbps'));
    test('500 Kbps صحيح', () => expect(500.toSpeed, '500 Kbps'));
  });

  group('IntExtensions — toFileSize', () {
    test('bytes', () => expect(512.toFileSize, '512 B'));
    test('KB', () => expect(2048.toFileSize, '2.0 KB'));
    test('MB', () => expect(1048576.toFileSize, '1.0 MB'));
  });

  group('DateTimeExtensions', () {
    test('Just now — أقل من دقيقة', () {
      final recent = DateTime.now().subtract(const Duration(seconds: 30));
      expect(recent.formatted, 'Just now');
    });
    test('دقائق', () {
      final minutes = DateTime.now().subtract(const Duration(minutes: 5));
      expect(minutes.formatted, '5m ago');
    });
    test('ساعات', () {
      final hours = DateTime.now().subtract(const Duration(hours: 3));
      expect(hours.formatted, '3h ago');
    });
  });
}

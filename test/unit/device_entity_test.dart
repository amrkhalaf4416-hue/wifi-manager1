import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_manager/domain/entities/device_entity.dart';

void main() {
  const device = DeviceEntity(
    macAddress: 'aa:bb:cc:dd:ee:ff',
    ipAddress: '192.168.1.100',
    displayName: 'My Phone',
    manufacturer: 'Apple',
    deviceType: 'phone',
    isOnline: true,
    isBlocked: false,
    downloadSpeedLimit: 5000,
    uploadSpeedLimit: 2000,
    signalStrength: 85,
  );

  group('DeviceEntity', () {
    test('formattedMac يُحوّل لأحرف كبيرة', () {
      expect(device.formattedMac, 'AA:BB:CC:DD:EE:FF');
    });

    test('hasSpeedLimit: true عند وجود حد', () {
      expect(device.hasSpeedLimit, true);
    });

    test('hasSpeedLimit: false عند عدم وجود حد', () {
      const noLimit = DeviceEntity(
        macAddress: 'AA:BB:CC:DD:EE:FF', ipAddress: '192.168.1.1',
        displayName: 'Test', manufacturer: 'Test', deviceType: 'phone',
        isOnline: true, isBlocked: false,
      );
      expect(noLimit.hasSpeedLimit, false);
    });

    test('speedLimitDisplay يعرض التنزيل والرفع', () {
      expect(device.speedLimitDisplay, contains('↓'));
      expect(device.speedLimitDisplay, contains('↑'));
    });

    test('signalStrengthText: Excellent عند 85', () {
      expect(device.signalStrengthText, 'Excellent');
    });

    test('signalStrengthBars: 4 عند 85', () {
      expect(device.signalStrengthBars, 4);
    });

    test('copyWith يُحدث isBlocked فقط', () {
      final blocked = device.copyWith(isBlocked: true);
      expect(blocked.isBlocked, true);
      expect(blocked.displayName, device.displayName); // لم يتغير
    });

    test('Equatable: جهازان بنفس MAC متساويان', () {
      final copy = device.copyWith();
      expect(device, equals(copy));
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_manager/data/models/router_settings_model.dart';

void main() {
  group('RouterSettingsModel', () {
    test('القيم الافتراضية صحيحة', () {
      const model = RouterSettingsModel();
      expect(model.routerIp, '192.168.1.1');
      expect(model.username, 'admin');
      expect(model.isLoggedIn, false);
      expect(model.isSaveCredentials, true);
    });

    test('baseUrl يُنتج URL صحيح', () {
      const model = RouterSettingsModel(routerIp: '192.168.1.254');
      expect(model.baseUrl, 'http://192.168.1.254');
    });

    test('hasValidSession: false عند عدم تسجيل الدخول', () {
      const model = RouterSettingsModel(isLoggedIn: false);
      expect(model.hasValidSession, false);
    });

    test('hasValidSession: false عند session قديمة > 30 دقيقة', () {
      final old = DateTime.now().subtract(const Duration(minutes: 31));
      final model = RouterSettingsModel(
        isLoggedIn: true,
        sessionCookie: 'token=abc',
        lastLoginTime: old,
      );
      expect(model.hasValidSession, false);
    });

    test('hasValidSession: true عند session حديثة', () {
      final recent = DateTime.now().subtract(const Duration(minutes: 5));
      final model = RouterSettingsModel(
        isLoggedIn: true,
        sessionCookie: 'token=abc',
        lastLoginTime: recent,
      );
      expect(model.hasValidSession, true);
    });

    test('toJson/fromJson: round-trip صحيح', () {
      const original = RouterSettingsModel(
        routerIp: '10.0.0.1',
        username: 'user1',
        password: 'pass123',
        isLoggedIn: true,
        sessionCookie: 'session=xyz',
        routerName: 'MyRouter',
      );
      final json = original.toJson();
      final restored = RouterSettingsModel.fromJson(json);
      expect(restored.routerIp, original.routerIp);
      expect(restored.username, original.username);
      expect(restored.sessionCookie, original.sessionCookie);
      expect(restored.routerName, original.routerName);
    });

    test('copyWith يُحدث الحقول بشكل انتقائي', () {
      const model = RouterSettingsModel(routerIp: '192.168.1.1', username: 'admin');
      final updated = model.copyWith(routerIp: '10.0.0.1');
      expect(updated.routerIp, '10.0.0.1');
      expect(updated.username, 'admin'); // لم يتغير
    });
  });
}

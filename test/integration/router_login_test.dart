import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';
import 'package:wifi_manager/data/datasources/local/settings_local_datasource.dart';
import 'package:wifi_manager/data/datasources/remote/router_remote_datasource.dart';
import 'package:wifi_manager/data/models/router_settings_model.dart';
import 'package:wifi_manager/data/repositories/device_repository_impl.dart';
import 'package:wifi_manager/data/datasources/local/mac_oui_service.dart';

@GenerateMocks([RouterRemoteDataSource, SettingsLocalDataSource, MacOuiService])
import 'router_login_test.mocks.dart';

void main() {
  late MockRouterRemoteDataSource remote;
  late MockSettingsLocalDataSource local;
  late MockMacOuiService ouiService;
  late DeviceRepositoryImpl repo;

  setUp(() {
    remote = MockRouterRemoteDataSource();
    local = MockSettingsLocalDataSource();
    ouiService = MockMacOuiService();
    repo = DeviceRepositoryImpl(remote, local, ouiService);
  });

  group('DeviceRepository Integration', () {
    test('getConnectedDevices: يُثري الأجهزة بالبيانات المحلية', () async {
      // Arrange
      when(remote.getConnectedDevices()).thenAnswer((_) async => []);
      when(local.getDeviceNames()).thenAnswer((_) async => {});
      when(local.getBlockedDevices()).thenAnswer((_) async => []);
      when(local.getSpeedLimits()).thenAnswer((_) async => {});
      when(local.cacheDevices(any)).thenAnswer((_) async {});
      when(local.setLastScan(any)).thenAnswer((_) async {});

      // Act
      final result = await repo.getConnectedDevices();

      // Assert
      result.fold(
        (failure) => fail('Expected success but got: $failure'),
        (devices) => expect(devices, isEmpty),
      );
    });

    test('blockDevice: يُحدّث التخزين المحلي عند النجاح', () async {
      when(remote.blockDevice('AA:BB:CC:DD:EE:FF')).thenAnswer((_) async => true);
      when(local.addBlockedDevice('AA:BB:CC:DD:EE:FF')).thenAnswer((_) async {});

      final result = await repo.blockDevice('AA:BB:CC:DD:EE:FF');

      result.fold(
        (f) => fail('Expected success'),
        (_) {
          verify(local.addBlockedDevice('AA:BB:CC:DD:EE:FF')).called(1);
        },
      );
    });

    test('blockDevice: لا يُحدّث المحلي عند فشل الراوتر', () async {
      when(remote.blockDevice(any)).thenAnswer((_) async => false);

      final result = await repo.blockDevice('AA:BB:CC:DD:EE:FF');

      expect(result.isLeft(), true);
      verifyNever(local.addBlockedDevice(any));
    });

    test('setDeviceName: يحفظ الاسم محلياً', () async {
      when(local.saveDeviceName('AA:BB:CC:DD:EE:FF', 'My Device'))
          .thenAnswer((_) async {});

      final result = await repo.setDeviceName('AA:BB:CC:DD:EE:FF', 'My Device');

      result.fold(
        (f) => fail('Expected success'),
        (_) => verify(local.saveDeviceName('AA:BB:CC:DD:EE:FF', 'My Device')).called(1),
      );
    });
  });
}

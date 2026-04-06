import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi_manager/domain/entities/device_entity.dart';
import 'package:wifi_manager/domain/repositories/device_repository.dart';
import 'package:wifi_manager/presentation/blocs/devices/devices_cubit.dart';

@GenerateMocks([DeviceRepository])
import 'devices_cubit_test.mocks.dart';

// ── Test fixtures ──
final mockDevice = DeviceEntity(
  macAddress: 'AA:BB:CC:DD:EE:FF',
  ipAddress: '192.168.1.100',
  displayName: 'iPhone عمر',
  manufacturer: 'Apple',
  deviceType: 'phone',
  isOnline: true,
  isBlocked: false,
  signalStrength: 85,
);

final mockDevice2 = DeviceEntity(
  macAddress: '11:22:33:44:55:66',
  ipAddress: '192.168.1.101',
  displayName: 'Samsung TV',
  manufacturer: 'Samsung',
  deviceType: 'tv',
  isOnline: true,
  isBlocked: true,
);

void main() {
  late MockDeviceRepository repo;
  late DevicesCubit cubit;

  setUp(() {
    repo = MockDeviceRepository();
    cubit = DevicesCubit(repo);
  });

  tearDown(() => cubit.close());

  // ── loadDevices ──
  group('loadDevices', () {
    blocTest<DevicesCubit, DevicesState>(
      'نجاح: يُصدر loading ثم success مع البيانات',
      build: () {
        when(repo.getCachedDevices()).thenAnswer((_) async => const Right([]));
        when(repo.getConnectedDevices()).thenAnswer((_) async => Right([mockDevice]));
        return cubit;
      },
      act: (c) => c.loadDevices(),
      expect: () => [
        isA<DevicesState>().having((s) => s.status, 'status', DevicesStatus.loading),
        isA<DevicesState>()
            .having((s) => s.status, 'status', DevicesStatus.success)
            .having((s) => s.devices.length, 'devices count', 1)
            .having((s) => s.isFromCache, 'isFromCache', false),
      ],
    );

    blocTest<DevicesCubit, DevicesState>(
      'يعرض الكاش أولاً عند وجود بيانات مُخزنة',
      build: () {
        when(repo.getCachedDevices()).thenAnswer((_) async => Right([mockDevice]));
        when(repo.getConnectedDevices()).thenAnswer((_) async => Right([mockDevice, mockDevice2]));
        return cubit;
      },
      act: (c) => c.loadDevices(),
      expect: () => [
        isA<DevicesState>().having((s) => s.status, 'status', DevicesStatus.loading),
        isA<DevicesState>()
            .having((s) => s.devices.length, 'cached count', 1)
            .having((s) => s.isFromCache, 'isFromCache', true),
        isA<DevicesState>()
            .having((s) => s.devices.length, 'fresh count', 2)
            .having((s) => s.isFromCache, 'isFromCache', false),
      ],
    );

    blocTest<DevicesCubit, DevicesState>(
      'فشل مع قاعدة فارغة: يُصدر failure',
      build: () {
        when(repo.getCachedDevices()).thenAnswer((_) async => const Right([]));
        when(repo.getConnectedDevices()).thenAnswer((_) async => const Left('خطأ في الشبكة'));
        return cubit;
      },
      act: (c) => c.loadDevices(),
      expect: () => [
        isA<DevicesState>().having((s) => s.status, 'status', DevicesStatus.loading),
        isA<DevicesState>()
            .having((s) => s.status, 'status', DevicesStatus.failure)
            .having((s) => s.errorMessage, 'error', 'خطأ في الشبكة'),
      ],
    );

    blocTest<DevicesCubit, DevicesState>(
      'منع الطلبات المتزامنة (mutex)',
      build: () {
        when(repo.getCachedDevices()).thenAnswer((_) async => const Right([]));
        when(repo.getConnectedDevices()).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return Right([mockDevice]);
        });
        return cubit;
      },
      act: (c) async {
        // استدعاءان متزامنان — الثاني يُتجاهل
        c.loadDevices();
        c.loadDevices();
      },
      verify: (c) {
        // تم استدعاء getConnectedDevices مرة واحدة فقط
        verify(repo.getConnectedDevices()).called(1);
      },
    );
  });

  // ── searchDevices ──
  group('searchDevices', () {
    blocTest<DevicesCubit, DevicesState>(
      'يُفلتر بالاسم',
      build: () => cubit,
      seed: () => DevicesState(status: DevicesStatus.success, devices: [mockDevice, mockDevice2]),
      act: (c) => c.searchDevices('apple'),
      expect: () => [
        isA<DevicesState>().having((s) => s.filteredDevices.length, 'filtered', 1),
      ],
    );

    blocTest<DevicesCubit, DevicesState>(
      'يُفلتر بعنوان MAC',
      build: () => cubit,
      seed: () => DevicesState(status: DevicesStatus.success, devices: [mockDevice, mockDevice2]),
      act: (c) => c.searchDevices('AA:BB'),
      expect: () => [
        isA<DevicesState>().having((s) => s.filteredDevices.length, 'filtered', 1),
      ],
    );

    blocTest<DevicesCubit, DevicesState>(
      'بحث فارغ يمسح الفلتر',
      build: () => cubit,
      seed: () => DevicesState(
        status: DevicesStatus.success,
        devices: [mockDevice],
        searchQuery: 'old query',
      ),
      act: (c) => c.clearSearch(),
      expect: () => [
        isA<DevicesState>().having((s) => s.searchQuery, 'searchQuery', isNull),
      ],
    );
  });

  // ── blockDevice ──
  group('blockDevice', () {
    blocTest<DevicesCubit, DevicesState>(
      'نجاح: يُحدّث isBlocked → true',
      build: () {
        when(repo.blockDevice('AA:BB:CC:DD:EE:FF')).thenAnswer((_) async => const Right(null));
        return cubit;
      },
      seed: () => DevicesState(status: DevicesStatus.success, devices: [mockDevice]),
      act: (c) => c.blockDevice('AA:BB:CC:DD:EE:FF'),
      expect: () => [
        isA<DevicesState>().having((s) => s.actionStatus, 'action', DeviceActionStatus.blocking),
        isA<DevicesState>()
            .having((s) => s.actionStatus, 'action', DeviceActionStatus.success)
            .having((s) => s.devices.first.isBlocked, 'isBlocked', true),
      ],
    );

    blocTest<DevicesCubit, DevicesState>(
      'فشل: يُصدر failure مع رسالة خطأ',
      build: () {
        when(repo.blockDevice(any)).thenAnswer((_) async => const Left('فشل الحظر'));
        return cubit;
      },
      seed: () => DevicesState(status: DevicesStatus.success, devices: [mockDevice]),
      act: (c) => c.blockDevice('AA:BB:CC:DD:EE:FF'),
      expect: () => [
        isA<DevicesState>().having((s) => s.actionStatus, 'action', DeviceActionStatus.blocking),
        isA<DevicesState>()
            .having((s) => s.actionStatus, 'action', DeviceActionStatus.failure)
            .having((s) => s.errorMessage, 'error', 'فشل الحظر'),
      ],
    );
  });

  // ── setSpeedLimit ──
  group('setSpeedLimit', () {
    blocTest<DevicesCubit, DevicesState>(
      'يُحدّث speedLimit للجهاز',
      build: () {
        when(repo.setSpeedLimit('AA:BB:CC:DD:EE:FF', 5000, 2000))
            .thenAnswer((_) async => const Right(null));
        return cubit;
      },
      seed: () => DevicesState(status: DevicesStatus.success, devices: [mockDevice]),
      act: (c) => c.setSpeedLimit('AA:BB:CC:DD:EE:FF', 5000, 2000),
      expect: () => [
        isA<DevicesState>().having((s) => s.actionStatus, 'action', DeviceActionStatus.settingSpeed),
        isA<DevicesState>()
            .having((s) => s.devices.first.downloadSpeedLimit, 'download', 5000)
            .having((s) => s.devices.first.uploadSpeedLimit, 'upload', 2000),
      ],
    );
  });

  // ── removeSpeedLimit ──
  group('removeSpeedLimit', () {
    blocTest<DevicesCubit, DevicesState>(
      'يُزيل speedLimit (يُصبح null)',
      build: () {
        when(repo.removeSpeedLimit('AA:BB:CC:DD:EE:FF')).thenAnswer((_) async => const Right(null));
        return cubit;
      },
      seed: () => DevicesState(
        status: DevicesStatus.success,
        devices: [mockDevice.copyWith(downloadSpeedLimit: 5000, uploadSpeedLimit: 2000)],
      ),
      act: (c) => c.removeSpeedLimit('AA:BB:CC:DD:EE:FF'),
      expect: () => [
        isA<DevicesState>().having((s) => s.actionStatus, 'action', DeviceActionStatus.removingSpeed),
        isA<DevicesState>()
            .having((s) => s.devices.first.downloadSpeedLimit, 'download', isNull)
            .having((s) => s.devices.first.uploadSpeedLimit, 'upload', isNull),
      ],
    );
  });

  // ── Computed properties ──
  group('DevicesState computed properties', () {
    test('onlineCount يحسب الأجهزة المتصلة غير المحجوبة', () {
      final state = DevicesState(
        status: DevicesStatus.success,
        devices: [
          mockDevice,   // online, not blocked
          mockDevice2,  // online, blocked
        ],
      );
      expect(state.onlineCount, 1);
    });

    test('blockedCount يحسب الأجهزة المحجوبة', () {
      final state = DevicesState(
        status: DevicesStatus.success,
        devices: [mockDevice, mockDevice2],
      );
      expect(state.blockedCount, 1);
    });

    test('displayDevices يُعيد filteredDevices عند وجود searchQuery', () {
      final state = DevicesState(
        status: DevicesStatus.success,
        devices: [mockDevice, mockDevice2],
        filteredDevices: [mockDevice],
        searchQuery: 'apple',
      );
      expect(state.displayDevices.length, 1);
    });
  });
}

import 'package:dartz/dartz.dart';
import 'package:wifi_manager/domain/entities/device_entity.dart';

abstract class DeviceRepository {
  Future<Either<String, List<DeviceEntity>>> getConnectedDevices();
  Future<Either<String, List<DeviceEntity>>> getCachedDevices();
  Future<Either<String, DeviceEntity>> getDeviceByMac(String macAddress);
  Future<Either<String, void>> setDeviceName(String macAddress, String name);
  Future<Either<String, void>> blockDevice(String macAddress);
  Future<Either<String, void>> unblockDevice(String macAddress);
  Future<Either<String, void>> setSpeedLimit(
    String macAddress, 
    int? downloadSpeed, 
    int? uploadSpeed,
  );
  Future<Either<String, void>> removeSpeedLimit(String macAddress);
  Future<Either<String, List<String>>> getBlockedDevices();
  Future<Either<String, Map<String, Map<String, int?>>>> getSpeedLimits();
}

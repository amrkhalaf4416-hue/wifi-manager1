import 'package:dartz/dartz.dart';
import 'package:wifi_manager/core/utils/extensions.dart';
import 'package:wifi_manager/data/datasources/local/mac_oui_service.dart';
import 'package:wifi_manager/data/datasources/local/settings_local_datasource.dart';
import 'package:wifi_manager/data/datasources/remote/router_remote_datasource.dart';
import 'package:wifi_manager/data/models/device_model.dart';
import 'package:wifi_manager/domain/entities/device_entity.dart';
import 'package:wifi_manager/domain/repositories/device_repository.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final RouterRemoteDataSource _remoteDataSource;
  final SettingsLocalDataSource _localDataSource;
  final MacOuiService _macOuiService;
  
  DeviceRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._macOuiService,
  );
  
  @override
  Future<Either<String, List<DeviceEntity>>> getConnectedDevices() async {
    try {
      // Get devices from router
      final devices = await _remoteDataSource.getConnectedDevices();
      
      // Enrich with local data
      final enrichedDevices = await _enrichDevices(devices);
      
      // Cache devices
      await _localDataSource.cacheDevices(enrichedDevices);
      
      // Update last scan time
      await _localDataSource.setLastScan(DateTime.now());
      
      return Right(_mapToEntities(enrichedDevices));
    } catch (e) {
      // Return cached devices if available
      final cached = await _localDataSource.getCachedDevices();
      if (cached.isNotEmpty) {
        return Right(_mapToEntities(cached));
      }
      return Left('Failed to get devices: $e');
    }
  }
  
  @override
  Future<Either<String, List<DeviceEntity>>> getCachedDevices() async {
    try {
      final devices = await _localDataSource.getCachedDevices();
      return Right(_mapToEntities(devices));
    } catch (e) {
      return Left('Failed to get cached devices: $e');
    }
  }
  
  @override
  Future<Either<String, DeviceEntity>> getDeviceByMac(String macAddress) async {
    try {
      final devices = await _remoteDataSource.getConnectedDevices();
      final device = devices.firstWhere(
        (d) => d.macAddress.toUpperCase() == macAddress.toUpperCase(),
        orElse: () => throw Exception('Device not found'),
      );
      
      final enriched = await _enrichDevice(device);
      return Right(_mapToEntity(enriched));
    } catch (e) {
      // Try from cache
      final cached = await _localDataSource.getCachedDevices();
      final device = cached.firstWhere(
        (d) => d.macAddress.toUpperCase() == macAddress.toUpperCase(),
        orElse: () => throw Exception('Device not found'),
      );
      return Right(_mapToEntity(device));
    }
  }
  
  @override
  Future<Either<String, void>> setDeviceName(String macAddress, String name) async {
    try {
      await _localDataSource.saveDeviceName(macAddress, name);
      return const Right(null);
    } catch (e) {
      return Left('Failed to save device name: $e');
    }
  }
  
  @override
  Future<Either<String, void>> blockDevice(String macAddress) async {
    try {
      final success = await _remoteDataSource.blockDevice(macAddress);
      if (success) {
        await _localDataSource.addBlockedDevice(macAddress);
        return const Right(null);
      }
      return const Left('Failed to block device on router');
    } catch (e) {
      return Left('Failed to block device: $e');
    }
  }
  
  @override
  Future<Either<String, void>> unblockDevice(String macAddress) async {
    try {
      final success = await _remoteDataSource.unblockDevice(macAddress);
      if (success) {
        await _localDataSource.removeBlockedDevice(macAddress);
        return const Right(null);
      }
      return const Left('Failed to unblock device on router');
    } catch (e) {
      return Left('Failed to unblock device: $e');
    }
  }
  
  @override
  Future<Either<String, void>> setSpeedLimit(
    String macAddress, 
    int? downloadSpeed, 
    int? uploadSpeed,
  ) async {
    try {
      final success = await _remoteDataSource.setSpeedLimit(
        macAddress, 
        downloadSpeed, 
        uploadSpeed,
      );
      if (success) {
        await _localDataSource.setSpeedLimit(macAddress, downloadSpeed, uploadSpeed);
        return const Right(null);
      }
      return const Left('Failed to set speed limit on router');
    } catch (e) {
      return Left('Failed to set speed limit: $e');
    }
  }
  
  @override
  Future<Either<String, void>> removeSpeedLimit(String macAddress) async {
    try {
      final success = await _remoteDataSource.removeSpeedLimit(macAddress);
      if (success) {
        await _localDataSource.removeSpeedLimit(macAddress);
        return const Right(null);
      }
      return const Left('Failed to remove speed limit on router');
    } catch (e) {
      return Left('Failed to remove speed limit: $e');
    }
  }
  
  @override
  Future<Either<String, List<String>>> getBlockedDevices() async {
    try {
      final devices = await _localDataSource.getBlockedDevices();
      return Right(devices);
    } catch (e) {
      return Left('Failed to get blocked devices: $e');
    }
  }
  
  @override
  Future<Either<String, Map<String, Map<String, int?>>>> getSpeedLimits() async {
    try {
      final limits = await _localDataSource.getSpeedLimits();
      return Right(limits);
    } catch (e) {
      return Left('Failed to get speed limits: $e');
    }
  }
  
  Future<List<DeviceModel>> _enrichDevices(List<DeviceModel> devices) async {
    final deviceNames = await _localDataSource.getDeviceNames();
    final blockedDevices = await _localDataSource.getBlockedDevices();
    final speedLimits = await _localDataSource.getSpeedLimits();
    
    return Future.wait(devices.map((device) async {
      final mac = device.macAddress.toUpperCase();
      
      // Get manufacturer
      final manufacturer = _macOuiService.lookupManufacturer(mac);
      
      // Detect device type
      final deviceType = _macOuiService.detectDeviceType(
        manufacturer, 
        device.hostname,
      );
      
      // Get custom name
      final customName = deviceNames[mac];
      
      // Check if blocked
      final isBlocked = blockedDevices.contains(mac);
      
      // Get speed limits
      final speedLimit = speedLimits[mac];
      
      return device.copyWith(
        manufacturer: manufacturer,
        deviceType: deviceType,
        customName: customName,
        isBlocked: isBlocked,
        downloadSpeedLimit: speedLimit?['download'],
        uploadSpeedLimit: speedLimit?['upload'],
      );
    }));
  }
  
  Future<DeviceModel> _enrichDevice(DeviceModel device) async {
    final devices = await _enrichDevices([device]);
    return devices.first;
  }
  
  List<DeviceEntity> _mapToEntities(List<DeviceModel> models) {
    return models.map(_mapToEntity).toList();
  }
  
  DeviceEntity _mapToEntity(DeviceModel model) {
    return DeviceEntity(
      macAddress: model.macAddress,
      ipAddress: model.ipAddress,
      displayName: model.displayName,
      manufacturer: model.manufacturer,
      deviceType: model.deviceType,
      isOnline: model.isOnline,
      isBlocked: model.isBlocked,
      downloadSpeedLimit: model.downloadSpeedLimit,
      uploadSpeedLimit: model.uploadSpeedLimit,
      signalStrength: model.signalStrength,
      lastSeen: model.lastSeen,
    );
  }
}

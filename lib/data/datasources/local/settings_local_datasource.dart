import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi_manager/core/constants/app_constants.dart';
import 'package:wifi_manager/data/models/device_model.dart';
import 'package:wifi_manager/data/models/router_settings_model.dart';

abstract class SettingsLocalDataSource {
  Future<RouterSettingsModel> getRouterSettings();
  Future<void> saveRouterSettings(RouterSettingsModel settings);
  Future<void> clearRouterSettings();
  Future<Map<String, String>> getDeviceNames();
  Future<void> saveDeviceName(String macAddress, String name);
  Future<void> removeDeviceName(String macAddress);
  Future<List<String>> getBlockedDevices();
  Future<void> addBlockedDevice(String macAddress);
  Future<void> removeBlockedDevice(String macAddress);
  Future<Map<String, Map<String, int?>>> getSpeedLimits();
  Future<void> setSpeedLimit(String macAddress, int? download, int? upload);
  Future<void> removeSpeedLimit(String macAddress);
  Future<ThemeMode> getThemeMode();
  Future<void> setThemeMode(ThemeMode mode);
  Future<String> getLocale();
  Future<void> setLocale(String locale);
  Future<DateTime?> getLastScan();
  Future<void> setLastScan(DateTime time);
  Future<List<DeviceModel>> getCachedDevices();
  Future<void> cacheDevices(List<DeviceModel> devices);
}

enum ThemeMode { light, dark, system }

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final SharedPreferences _prefs;

  // BUG FIX: الكود القديم كان يفتح Hive boxes في constructor بدون await
  // مما يؤدي إلى race condition عند أول استخدام
  // الإصلاح: lazy initialization مع التحقق قبل كل استخدام
  Box<DeviceModel>? _devicesBox;
  Box<Map>? _speedLimitsBox;

  SettingsLocalDataSourceImpl(this._prefs);

  Future<Box<DeviceModel>> get _devices async {
    if (_devicesBox == null || !_devicesBox!.isOpen) {
      _devicesBox = await Hive.openBox<DeviceModel>(AppConstants.devicesBoxName);
    }
    return _devicesBox!;
  }

  Future<Box<Map>> get _speedLimits async {
    if (_speedLimitsBox == null || !_speedLimitsBox!.isOpen) {
      _speedLimitsBox = await Hive.openBox<Map>('speed_limits');
    }
    return _speedLimitsBox!;
  }

  @override
  Future<RouterSettingsModel> getRouterSettings() async {
    // BUG FIX: الكود القديم كان يستخدم StorageKeys.routerIp لتخزين الـ settings كاملة
    // وهذا مضلل جداً في القراءة
    // الإصلاح: استخدام مفتاح واضح 'router_settings'
    final json = _prefs.getString('router_settings') 
                 ?? _prefs.getString(StorageKeys.routerIp); // backward compat
    if (json == null) return const RouterSettingsModel();
    try {
      return RouterSettingsModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return const RouterSettingsModel();
    }
  }

  @override
  Future<void> saveRouterSettings(RouterSettingsModel settings) async {
    await _prefs.setString('router_settings', jsonEncode(settings.toJson()));
  }

  @override
  Future<void> clearRouterSettings() async {
    await _prefs.remove('router_settings');
    await _prefs.remove(StorageKeys.routerIp); // backward compat
    await _prefs.remove(StorageKeys.sessionCookie);
    await _prefs.remove(StorageKeys.isLoggedIn);
  }

  @override
  Future<Map<String, String>> getDeviceNames() async {
    final json = _prefs.getString(StorageKeys.deviceNames);
    if (json == null) return {};
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return map.map((k, v) => MapEntry(k.toUpperCase(), v.toString()));
    } catch (_) {
      return {};
    }
  }

  @override
  Future<void> saveDeviceName(String macAddress, String name) async {
    final names = await getDeviceNames();
    names[macAddress.toUpperCase()] = name;
    await _prefs.setString(StorageKeys.deviceNames, jsonEncode(names));
  }

  @override
  Future<void> removeDeviceName(String macAddress) async {
    final names = await getDeviceNames();
    names.remove(macAddress.toUpperCase());
    await _prefs.setString(StorageKeys.deviceNames, jsonEncode(names));
  }

  @override
  Future<List<String>> getBlockedDevices() async {
    final json = _prefs.getString(StorageKeys.blockedDevices);
    if (json == null) return [];
    try {
      return (jsonDecode(json) as List).map((e) => e.toString().toUpperCase()).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> addBlockedDevice(String macAddress) async {
    final devices = await getBlockedDevices();
    final mac = macAddress.toUpperCase();
    if (!devices.contains(mac)) {
      devices.add(mac);
      await _prefs.setString(StorageKeys.blockedDevices, jsonEncode(devices));
    }
  }

  @override
  Future<void> removeBlockedDevice(String macAddress) async {
    final devices = await getBlockedDevices();
    devices.remove(macAddress.toUpperCase());
    await _prefs.setString(StorageKeys.blockedDevices, jsonEncode(devices));
  }

  @override
  Future<Map<String, Map<String, int?>>> getSpeedLimits() async {
    final box = await _speedLimits;
    final result = <String, Map<String, int?>>{};
    for (final key in box.keys) {
      final value = box.get(key);
      if (value != null) {
        result[key.toString().toUpperCase()] = {
          'download': value['download'] as int?,
          'upload': value['upload'] as int?,
        };
      }
    }
    return result;
  }

  @override
  Future<void> setSpeedLimit(String macAddress, int? download, int? upload) async {
    final box = await _speedLimits;
    await box.put(macAddress.toUpperCase(), {'download': download, 'upload': upload});
  }

  @override
  Future<void> removeSpeedLimit(String macAddress) async {
    final box = await _speedLimits;
    await box.delete(macAddress.toUpperCase());
  }

  @override
  Future<ThemeMode> getThemeMode() async {
    return switch (_prefs.getString(StorageKeys.themeMode)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _prefs.setString(StorageKeys.themeMode, value);
  }

  @override
  Future<String> getLocale() async =>
      _prefs.getString(StorageKeys.locale) ?? 'ar';

  @override
  Future<void> setLocale(String locale) async =>
      _prefs.setString(StorageKeys.locale, locale);

  @override
  Future<DateTime?> getLastScan() async {
    final value = _prefs.getString(StorageKeys.lastScan);
    if (value == null) return null;
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> setLastScan(DateTime time) async =>
      _prefs.setString(StorageKeys.lastScan, time.toIso8601String());

  @override
  Future<List<DeviceModel>> getCachedDevices() async {
    final box = await _devices;
    return box.values.toList();
  }

  @override
  Future<void> cacheDevices(List<DeviceModel> devices) async {
    final box = await _devices;
    // PERFORMANCE FIX: استخدام putAll بدلاً من put في حلقة واحدة
    await box.clear();
    final map = {for (final d in devices) d.macAddress.toUpperCase(): d};
    await box.putAll(map);
  }
}

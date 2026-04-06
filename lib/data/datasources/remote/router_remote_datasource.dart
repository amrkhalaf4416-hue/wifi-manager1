import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:wifi_manager/core/constants/app_constants.dart';
import 'package:wifi_manager/core/network/dio_client.dart';
import 'package:wifi_manager/data/models/device_model.dart';
import 'package:wifi_manager/data/models/router_settings_model.dart';

abstract class RouterRemoteDataSource {
  Future<bool> login(String username, String password);
  Future<void> logout();
  Future<List<DeviceModel>> getConnectedDevices();
  Future<bool> blockDevice(String macAddress);
  Future<bool> unblockDevice(String macAddress);
  Future<bool> setSpeedLimit(String macAddress, int? downloadKbps, int? uploadKbps);
  Future<bool> removeSpeedLimit(String macAddress);
  Future<RouterSettingsModel?> getRouterInfo();
  Future<bool> isRouterReachable();
  Future<bool> isLoggedIn();
}

class RouterRemoteDataSourceImpl implements RouterRemoteDataSource {
  final DioClient _dioClient;
  RouterSettingsModel? _currentSettings;

  RouterRemoteDataSourceImpl(this._dioClient);

  void updateSettings(RouterSettingsModel settings) {
    _currentSettings = settings;
    _dioClient.setBaseUrl(settings.routerIp);
    if (settings.sessionCookie != null) {
      _dioClient.setSessionCookie(settings.sessionCookie!);
    }
  }

  @override
  Future<bool> login(String username, String password) async {
    try {
      // BUG FIX: الكود القديم لم يتحقق من الـ session cookie بشكل صحيح
      // الإصلاح: نتحقق من الـ redirect والـ cookie معاً
      final response = await _dioClient.post(
        AppConstants.loginEndpoint,
        data: {
          'username': username,
          'password': password,
          'submit': 'Login',
        },
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
          followRedirects: true,
        ),
      );

      // SECURITY FIX: فحص دقيق للـ response بدلاً من فحص النصوص فقط
      if (response.statusCode == null) return false;

      final responseBody = response.data?.toString().toLowerCase() ?? '';

      // فشل صريح
      final failureIndicators = [
        'invalid password',
        'login failed',
        'authentication failed',
        'incorrect username',
        'wrong password',
      ];
      if (failureIndicators.any((f) => responseBody.contains(f))) {
        return false;
      }

      // نجاح: إما تم التوجيه أو وُجد كوكي
      if (_dioClient.sessionCookie != null && _dioClient.sessionCookie!.isNotEmpty) {
        return true;
      }

      // تحقق بديل عبر طلب صفحة محمية
      return _verifyLogin();
    } catch (e) {
      return false;
    }
  }

  Future<bool> _verifyLogin() async {
    try {
      final response = await _dioClient.get(AppConstants.devicesEndpoint);
      final body = response.data?.toString().toLowerCase() ?? '';
      return response.statusCode == 200 &&
          !body.contains('login') &&
          !body.contains('password') &&
          !body.contains('username');
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> logout() async {
    try {
      // بعض الراوترات تحتاج إلى طلب logout صريح
      await _dioClient.get('/logout.cgi').timeout(const Duration(seconds: 3));
    } catch (_) {
      // تجاهل أخطاء الـ logout
    } finally {
      _dioClient.clearSession();
    }
  }

  @override
  Future<List<DeviceModel>> getConnectedDevices() async {
    final response = await _dioClient.get(AppConstants.devicesEndpoint);

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: Failed to get devices');
    }

    final html = response.data?.toString() ?? '';
    if (html.isEmpty) throw Exception('Empty response from router');

    return _parseDevicesFromHtml(html);
  }

  List<DeviceModel> _parseDevicesFromHtml(String html) {
    final devices = <DeviceModel>[];
    final seenMacs = <String>{};

    // Strategy 1: JSON embedded in HTML (أحدث firmware)
    _parseJsonDevices(html, devices, seenMacs);

    // Strategy 2: HTML Table parsing
    if (devices.isEmpty) {
      _parseTableDevices(html, devices, seenMacs);
    }

    // Strategy 3: Pattern matching بديل
    if (devices.isEmpty) {
      _parsePatternDevices(html, devices, seenMacs);
    }

    return devices;
  }

  void _parseJsonDevices(String html, List<DeviceModel> devices, Set<String> seenMacs) {
    // BUG FIX: الكود القديم كان يبحث عن staList فقط
    // الإصلاح: نبحث عن أنماط JSON متعددة
    final patterns = [
      RegExp(r'var\s+staList\s*=\s*(\[.*?\]);', caseSensitive: false, dotAll: true),
      RegExp(r'var\s+deviceList\s*=\s*(\[.*?\]);', caseSensitive: false, dotAll: true),
      RegExp(r'"devices"\s*:\s*(\[.*?\])', caseSensitive: false, dotAll: true),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(html);
      if (match == null) continue;

      try {
        final jsonStr = match.group(1)!;
        final List<dynamic> jsonData = jsonDecode(jsonStr);

        for (final item in jsonData) {
          if (item is! Map) continue;
          final mac = _extractString(item, ['mac', 'MAC', 'macAddr']) ?? '';
          final ip = _extractString(item, ['ip', 'IP', 'ipAddr']) ?? '';

          if (mac.isEmpty || !mac.isValidMac) continue;
          final normalizedMac = mac.formatMac;
          if (!seenMacs.add(normalizedMac.toUpperCase())) continue;

          devices.add(DeviceModel(
            macAddress: normalizedMac,
            ipAddress: ip,
            hostname: _extractString(item, ['hostname', 'name', 'hostName']),
            isOnline: _extractString(item, ['status'])?.toLowerCase() == 'connected',
            signalStrength: int.tryParse(
              _extractString(item, ['rssi', 'signal', 'signalStrength']) ?? '',
            ),
          ));
        }
        if (devices.isNotEmpty) return;
      } catch (_) {
        continue;
      }
    }
  }

  void _parseTableDevices(String html, List<DeviceModel> devices, Set<String> seenMacs) {
    // BUG FIX: الكود القديم استخدم regex معقد جداً يفشل مع HTML حقيقي
    // الإصلاح: regex أبسط يبحث عن الـ MAC address أولاً
    final macPattern = RegExp(
      r'([0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}',
    );
    final ipPattern = RegExp(r'\b(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\b');

    // ابحث عن جميع الـ MAC addresses في الصفحة
    final macMatches = macPattern.allMatches(html);

    for (final macMatch in macMatches) {
      final mac = macMatch.group(0)!;
      if (!mac.isValidMac) continue;
      final normalizedMac = mac.formatMac;
      if (!seenMacs.add(normalizedMac.toUpperCase())) continue;

      // ابحث عن IP قريب من الـ MAC في السياق
      final start = (macMatch.start - 200).clamp(0, html.length);
      final end = (macMatch.end + 200).clamp(0, html.length);
      final context = html.substring(start, end);

      String ip = '';
      final ipMatch = ipPattern.firstMatch(context);
      if (ipMatch != null) {
        final candidate = ipMatch.group(1)!;
        // تأكد أنه ليس IP الراوتر نفسه
        if (candidate != (_currentSettings?.routerIp ?? AppConstants.defaultRouterIp)) {
          ip = candidate;
        }
      }

      devices.add(DeviceModel(
        macAddress: normalizedMac,
        ipAddress: ip,
        isOnline: true,
      ));
    }
  }

  void _parsePatternDevices(String html, List<DeviceModel> devices, Set<String> seenMacs) {
    final pattern = RegExp(
      r'MAC[^:]*:\s*([0-9A-Fa-f:]{17}).*?IP[^:]*:\s*(\d+\.\d+\.\d+\.\d+)',
      caseSensitive: false,
      dotAll: true,
    );

    for (final match in pattern.allMatches(html)) {
      final mac = match.group(1)!.trim();
      final ip = match.group(2)!.trim();

      if (!mac.isValidMac) continue;
      final normalizedMac = mac.formatMac;
      if (!seenMacs.add(normalizedMac.toUpperCase())) continue;

      devices.add(DeviceModel(macAddress: normalizedMac, ipAddress: ip, isOnline: true));
    }
  }

  String? _extractString(Map item, List<String> keys) {
    for (final k in keys) {
      if (item.containsKey(k) && item[k] != null) {
        return item[k].toString();
      }
    }
    return null;
  }

  @override
  Future<bool> blockDevice(String macAddress) async {
    try {
      final response = await _dioClient.post(
        AppConstants.macFilterEndpoint,
        data: {
          'action': 'add',
          'mac': macAddress.formatMac,
          'enable': '1',
        },
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> unblockDevice(String macAddress) async {
    try {
      final response = await _dioClient.post(
        AppConstants.macFilterEndpoint,
        data: {
          'action': 'delete',
          'mac': macAddress.formatMac,
        },
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> setSpeedLimit(String macAddress, int? downloadKbps, int? uploadKbps) async {
    // PERFORMANCE FIX: جرب الـ QoS أولاً، ثم bandwidth control
    for (final endpoint in [AppConstants.qosEndpoint, AppConstants.bandwidthEndpoint]) {
      try {
        final response = await _dioClient.post(
          endpoint,
          data: {
            'action': 'add',
            'mac': macAddress.formatMac,
            'dlrate': downloadKbps?.toString() ?? '0',
            'ulrate': uploadKbps?.toString() ?? '0',
            'download': downloadKbps?.toString() ?? '0',
            'upload': uploadKbps?.toString() ?? '0',
            'enable': '1',
          },
        );
        if (response.statusCode == 200) return true;
      } catch (_) {
        continue;
      }
    }
    return false;
  }

  @override
  Future<bool> removeSpeedLimit(String macAddress) async {
    for (final endpoint in [AppConstants.qosEndpoint, AppConstants.bandwidthEndpoint]) {
      try {
        final response = await _dioClient.post(
          endpoint,
          data: {'action': 'delete', 'mac': macAddress.formatMac},
        );
        if (response.statusCode == 200) return true;
      } catch (_) {
        continue;
      }
    }
    return false;
  }

  @override
  Future<RouterSettingsModel?> getRouterInfo() async {
    try {
      final response = await _dioClient.get(AppConstants.routerInfoEndpoint);
      if (response.statusCode != 200) return null;

      final html = response.data?.toString() ?? '';

      String? _extract(String key) {
        final match = RegExp(
          '$key[\\s\\w]*:\\s*([^<\\n]+)',
          caseSensitive: false,
        ).firstMatch(html);
        return match?.group(1)?.trim();
      }

      return _currentSettings?.copyWith(
        routerName: _extract('Router\\s*Name'),
        routerModel: _extract('Model'),
        firmwareVersion: _extract('Firmware'),
        ssid: _extract('SSID(?!.*5G)'),
        ssid5G: _extract('5G\\s*SSID'),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> isRouterReachable() => _dioClient.isRouterReachable();

  @override
  Future<bool> isLoggedIn() => _verifyLogin();
}

// Extension helpers (تعريف هنا لتجنب التكرار من extensions.dart)
extension _MacExtension on String {
  bool get isValidMac {
    final clean = replaceAll(RegExp(r'[^A-Fa-f0-9]'), '');
    return clean.length == 12;
  }

  String get formatMac {
    final clean = replaceAll(RegExp(r'[^A-Fa-f0-9]'), '').toUpperCase();
    if (clean.length != 12) return this;
    final parts = <String>[];
    for (var i = 0; i < 12; i += 2) parts.add(clean.substring(i, i + 2));
    return parts.join(':');
  }
}

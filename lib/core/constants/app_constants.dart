import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();
  
  // App Info
  static const String appName = 'WiFi Manager';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  
  // Router Defaults (Huawei HG531 V1)
  static const String defaultRouterIp = '192.168.1.1';
  static const String defaultUsername = 'admin';
  static const String defaultPassword = 'admin';
  
  // Router Endpoints
  static const String loginEndpoint = '/login.cgi';
  static const String devicesEndpoint = '/wlstationlist.cmd';
  static const String macFilterEndpoint = '/wlmacflt.cmd';
  static const String qosEndpoint = '/qos.cgi';
  static const String bandwidthEndpoint = '/bandwidthctrl.cgi';
  static const String routerInfoEndpoint = '/routerinfo.cmd';
  
  // Timeouts
  static const int connectionTimeout = 10000; // 10 seconds
  static const int receiveTimeout = 15000; // 15 seconds
  
  // Cache
  static const String cacheBoxName = 'wifi_manager_cache';
  static const String settingsBoxName = 'wifi_manager_settings';
  static const String devicesBoxName = 'wifi_manager_devices';
  static const int maxCacheAge = 3600; // 1 hour in seconds
  
  // Supported Locales
  static const List<Locale> supportedLocales = [
    Locale('ar'),
    Locale('en'),
  ];
  
  static const Locale defaultLocale = Locale('ar');
  
  // Device Icons Mapping (based on MAC OUI)
  static const Map<String, String> deviceTypeIcons = {
    'phone': 'phone',
    'tablet': 'tablet',
    'laptop': 'laptop',
    'desktop': 'desktop',
    'tv': 'tv',
    'gaming': 'gamepad',
    'iot': 'smart_toy',
    'camera': 'camera',
    'printer': 'print',
    'router': 'router',
    'unknown': 'devices',
  };
  
  // Known Device Types by OUI patterns
  static const Map<String, List<String>> knownManufacturers = {
    'Apple': ['Apple, Inc.', 'Apple Inc.'],
    'Samsung': ['Samsung Electronics', 'Samsung'],
    'Huawei': ['Huawei Technologies', 'Huawei'],
    'Xiaomi': ['Xiaomi Communications', 'Xiaomi'],
    'OPPO': ['OPPO Mobile', 'OPPO'],
    'vivo': ['vivo Mobile', 'vivo'],
    'OnePlus': ['OnePlus Technology', 'OnePlus'],
    'Realme': ['Realme Chongqing Mobile', 'Realme'],
    'Sony': ['Sony Corporation', 'Sony'],
    'LG': ['LG Electronics', 'LG'],
    'Nokia': ['Nokia Corporation', 'Nokia'],
    'Microsoft': ['Microsoft Corporation', 'Microsoft'],
    'Dell': ['Dell Inc.', 'Dell'],
    'HP': ['Hewlett-Packard', 'HP'],
    'Lenovo': ['Lenovo Group', 'Lenovo'],
    'ASUS': ['ASUSTek Computer', 'ASUS'],
    'Acer': ['Acer Inc.', 'Acer'],
    'Toshiba': ['Toshiba Corporation', 'Toshiba'],
    'Google': ['Google, Inc.', 'Google'],
    'Amazon': ['Amazon Technologies', 'Amazon'],
    'Raspberry': ['Raspberry Pi Foundation', 'Raspberry'],
    'ESP': ['Espressif Inc.', 'ESP'],
    'Arduino': ['Arduino SA', 'Arduino'],
  };
}

// Storage Keys
class StorageKeys {
  StorageKeys._();
  
  static const String routerIp = 'router_ip';
  static const String routerUsername = 'router_username';
  static const String routerPassword = 'router_password';
  static const String isLoggedIn = 'is_logged_in';
  static const String sessionCookie = 'session_cookie';
  static const String themeMode = 'theme_mode';
  static const String locale = 'locale';
  static const String deviceNames = 'device_names';
  static const String blockedDevices = 'blocked_devices';
  static const String speedLimits = 'speed_limits';
  static const String lastScan = 'last_scan';
}

// Error Messages
class ErrorMessages {
  ErrorMessages._();
  
  static const String connectionTimeout = 'connection_timeout';
  static const String noInternet = 'no_internet';
  static const String routerNotFound = 'router_not_found';
  static const String invalidCredentials = 'invalid_credentials';
  static const String sessionExpired = 'session_expired';
  static const String unknownError = 'unknown_error';
  static const String parsingError = 'parsing_error';
  static const String permissionDenied = 'permission_denied';
}

// Animation Durations
class AnimationDurations {
  AnimationDurations._();
  
  static const Duration short = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration long = Duration(milliseconds: 500);
}

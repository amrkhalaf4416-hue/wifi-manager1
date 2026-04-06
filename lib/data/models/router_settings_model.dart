import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'router_settings_model.g.dart';

@HiveType(typeId: 1)
class RouterSettingsModel extends Equatable {
  @HiveField(0)
  final String routerIp;
  
  @HiveField(1)
  final String username;
  
  @HiveField(2)
  final String password;
  
  @HiveField(3)
  final bool isLoggedIn;
  
  @HiveField(4)
  final String? sessionCookie;
  
  @HiveField(5)
  final DateTime? lastLoginTime;
  
  @HiveField(6)
  final String? routerName;
  
  @HiveField(7)
  final String? routerModel;
  
  @HiveField(8)
  final String? firmwareVersion;
  
  @HiveField(9)
  final String? ssid;
  
  @HiveField(10)
  final String? ssid5G;
  
  @HiveField(11)
  final bool isSaveCredentials;
  
  const RouterSettingsModel({
    this.routerIp = '192.168.1.1',
    this.username = 'admin',
    this.password = 'admin',
    this.isLoggedIn = false,
    this.sessionCookie,
    this.lastLoginTime,
    this.routerName,
    this.routerModel,
    this.firmwareVersion,
    this.ssid,
    this.ssid5G,
    this.isSaveCredentials = true,
  });
  
  String get baseUrl => 'http://$routerIp';
  
  bool get hasValidSession {
    if (!isLoggedIn || sessionCookie == null) return false;
    if (lastLoginTime == null) return false;
    
    // Session expires after 30 minutes of inactivity
    final sessionDuration = DateTime.now().difference(lastLoginTime!);
    return sessionDuration.inMinutes < 30;
  }
  
  RouterSettingsModel copyWith({
    String? routerIp,
    String? username,
    String? password,
    bool? isLoggedIn,
    String? sessionCookie,
    DateTime? lastLoginTime,
    String? routerName,
    String? routerModel,
    String? firmwareVersion,
    String? ssid,
    String? ssid5G,
    bool? isSaveCredentials,
  }) {
    return RouterSettingsModel(
      routerIp: routerIp ?? this.routerIp,
      username: username ?? this.username,
      password: password ?? this.password,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      sessionCookie: sessionCookie ?? this.sessionCookie,
      lastLoginTime: lastLoginTime ?? this.lastLoginTime,
      routerName: routerName ?? this.routerName,
      routerModel: routerModel ?? this.routerModel,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      ssid: ssid ?? this.ssid,
      ssid5G: ssid5G ?? this.ssid5G,
      isSaveCredentials: isSaveCredentials ?? this.isSaveCredentials,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'routerIp': routerIp,
      'username': username,
      'password': password,
      'isLoggedIn': isLoggedIn,
      'sessionCookie': sessionCookie,
      'lastLoginTime': lastLoginTime?.toIso8601String(),
      'routerName': routerName,
      'routerModel': routerModel,
      'firmwareVersion': firmwareVersion,
      'ssid': ssid,
      'ssid5G': ssid5G,
      'isSaveCredentials': isSaveCredentials,
    };
  }
  
  factory RouterSettingsModel.fromJson(Map<String, dynamic> json) {
    return RouterSettingsModel(
      routerIp: json['routerIp'] ?? '192.168.1.1',
      username: json['username'] ?? 'admin',
      password: json['password'] ?? 'admin',
      isLoggedIn: json['isLoggedIn'] ?? false,
      sessionCookie: json['sessionCookie'],
      lastLoginTime: json['lastLoginTime'] != null 
          ? DateTime.parse(json['lastLoginTime']) 
          : null,
      routerName: json['routerName'],
      routerModel: json['routerModel'],
      firmwareVersion: json['firmwareVersion'],
      ssid: json['ssid'],
      ssid5G: json['ssid5G'],
      isSaveCredentials: json['isSaveCredentials'] ?? true,
    );
  }
  
  @override
  List<Object?> get props => [
    routerIp,
    username,
    password,
    isLoggedIn,
    sessionCookie,
    lastLoginTime,
    routerName,
    routerModel,
    firmwareVersion,
    ssid,
    ssid5G,
    isSaveCredentials,
  ];
}

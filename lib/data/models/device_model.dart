import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'device_model.g.dart';

@HiveType(typeId: 0)
class DeviceModel extends Equatable {
  @HiveField(0)
  final String macAddress;
  
  @HiveField(1)
  final String ipAddress;
  
  @HiveField(2)
  final String? hostname;
  
  @HiveField(3)
  final String? customName;
  
  @HiveField(4)
  final String manufacturer;
  
  @HiveField(5)
  final String deviceType;
  
  @HiveField(6)
  final bool isOnline;
  
  @HiveField(7)
  final bool isBlocked;
  
  @HiveField(8)
  final int? downloadSpeedLimit; // in Kbps
  
  @HiveField(9)
  final int? uploadSpeedLimit; // in Kbps
  
  @HiveField(10)
  final int? signalStrength; // 0-100
  
  @HiveField(11)
  final DateTime? lastSeen;
  
  @HiveField(12)
  final DateTime? connectedSince;
  
  @HiveField(13)
  final int? downloadBytes;
  
  @HiveField(14)
  final int? uploadBytes;
  
  const DeviceModel({
    required this.macAddress,
    required this.ipAddress,
    this.hostname,
    this.customName,
    this.manufacturer = 'Unknown',
    this.deviceType = 'unknown',
    this.isOnline = true,
    this.isBlocked = false,
    this.downloadSpeedLimit,
    this.uploadSpeedLimit,
    this.signalStrength,
    this.lastSeen,
    this.connectedSince,
    this.downloadBytes,
    this.uploadBytes,
  });
  
  String get displayName {
    if (customName != null && customName!.isNotEmpty) {
      return customName!;
    }
    if (hostname != null && hostname!.isNotEmpty && hostname != 'unknown') {
      return hostname!;
    }
    return 'Unknown Device';
  }
  
  String get displayMac => macAddress.toUpperCase();
  
  String get oui => macAddress.extractOui;
  
  bool get hasSpeedLimit => downloadSpeedLimit != null || uploadSpeedLimit != null;
  
  String get speedLimitDisplay {
    if (!hasSpeedLimit) return 'Unlimited';
    
    final download = downloadSpeedLimit;
    final upload = uploadSpeedLimit;
    
    if (download != null && upload != null) {
      return '↓${download.toSpeed} ↑${upload.toSpeed}';
    } else if (download != null) {
      return '↓${download.toSpeed}';
    } else if (upload != null) {
      return '↑${upload.toSpeed}';
    }
    
    return 'Unlimited';
  }
  
  String get signalStrengthText {
    final strength = signalStrength ?? 0;
    if (strength >= 80) return 'Excellent';
    if (strength >= 60) return 'Good';
    if (strength >= 40) return 'Fair';
    return 'Weak';
  }
  
  DeviceModel copyWith({
    String? macAddress,
    String? ipAddress,
    String? hostname,
    String? customName,
    String? manufacturer,
    String? deviceType,
    bool? isOnline,
    bool? isBlocked,
    int? downloadSpeedLimit,
    int? uploadSpeedLimit,
    int? signalStrength,
    DateTime? lastSeen,
    DateTime? connectedSince,
    int? downloadBytes,
    int? uploadBytes,
  }) {
    return DeviceModel(
      macAddress: macAddress ?? this.macAddress,
      ipAddress: ipAddress ?? this.ipAddress,
      hostname: hostname ?? this.hostname,
      customName: customName ?? this.customName,
      manufacturer: manufacturer ?? this.manufacturer,
      deviceType: deviceType ?? this.deviceType,
      isOnline: isOnline ?? this.isOnline,
      isBlocked: isBlocked ?? this.isBlocked,
      downloadSpeedLimit: downloadSpeedLimit ?? this.downloadSpeedLimit,
      uploadSpeedLimit: uploadSpeedLimit ?? this.uploadSpeedLimit,
      signalStrength: signalStrength ?? this.signalStrength,
      lastSeen: lastSeen ?? this.lastSeen,
      connectedSince: connectedSince ?? this.connectedSince,
      downloadBytes: downloadBytes ?? this.downloadBytes,
      uploadBytes: uploadBytes ?? this.uploadBytes,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'macAddress': macAddress,
      'ipAddress': ipAddress,
      'hostname': hostname,
      'customName': customName,
      'manufacturer': manufacturer,
      'deviceType': deviceType,
      'isOnline': isOnline,
      'isBlocked': isBlocked,
      'downloadSpeedLimit': downloadSpeedLimit,
      'uploadSpeedLimit': uploadSpeedLimit,
      'signalStrength': signalStrength,
      'lastSeen': lastSeen?.toIso8601String(),
      'connectedSince': connectedSince?.toIso8601String(),
      'downloadBytes': downloadBytes,
      'uploadBytes': uploadBytes,
    };
  }
  
  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      macAddress: json['macAddress'] ?? '',
      ipAddress: json['ipAddress'] ?? '',
      hostname: json['hostname'],
      customName: json['customName'],
      manufacturer: json['manufacturer'] ?? 'Unknown',
      deviceType: json['deviceType'] ?? 'unknown',
      isOnline: json['isOnline'] ?? true,
      isBlocked: json['isBlocked'] ?? false,
      downloadSpeedLimit: json['downloadSpeedLimit'],
      uploadSpeedLimit: json['uploadSpeedLimit'],
      signalStrength: json['signalStrength'],
      lastSeen: json['lastSeen'] != null 
          ? DateTime.parse(json['lastSeen']) 
          : null,
      connectedSince: json['connectedSince'] != null 
          ? DateTime.parse(json['connectedSince']) 
          : null,
      downloadBytes: json['downloadBytes'],
      uploadBytes: json['uploadBytes'],
    );
  }
  
  @override
  List<Object?> get props => [
    macAddress,
    ipAddress,
    hostname,
    customName,
    manufacturer,
    deviceType,
    isOnline,
    isBlocked,
    downloadSpeedLimit,
    uploadSpeedLimit,
    signalStrength,
    lastSeen,
    connectedSince,
    downloadBytes,
    uploadBytes,
  ];
}

// Device Status Enum
enum DeviceStatus {
  online,
  offline,
  blocked,
  limited,
}

extension DeviceStatusExtension on DeviceStatus {
  String get name {
    switch (this) {
      case DeviceStatus.online:
        return 'Online';
      case DeviceStatus.offline:
        return 'Offline';
      case DeviceStatus.blocked:
        return 'Blocked';
      case DeviceStatus.limited:
        return 'Limited';
    }
  }
  
  Color get color {
    switch (this) {
      case DeviceStatus.online:
        return const Color(0xFF4CAF50);
      case DeviceStatus.offline:
        return const Color(0xFF9E9E9E);
      case DeviceStatus.blocked:
        return const Color(0xFFE53935);
      case DeviceStatus.limited:
        return const Color(0xFFFF9800);
    }
  }
}

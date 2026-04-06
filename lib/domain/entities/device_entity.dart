import 'package:equatable/equatable.dart';

class DeviceEntity extends Equatable {
  final String macAddress;
  final String ipAddress;
  final String displayName;
  final String manufacturer;
  final String deviceType;
  final bool isOnline;
  final bool isBlocked;
  final int? downloadSpeedLimit;
  final int? uploadSpeedLimit;
  final int? signalStrength;
  final DateTime? lastSeen;
  
  const DeviceEntity({
    required this.macAddress,
    required this.ipAddress,
    required this.displayName,
    required this.manufacturer,
    required this.deviceType,
    required this.isOnline,
    required this.isBlocked,
    this.downloadSpeedLimit,
    this.uploadSpeedLimit,
    this.signalStrength,
    this.lastSeen,
  });
  
  String get formattedMac => macAddress.toUpperCase();
  
  bool get hasSpeedLimit => downloadSpeedLimit != null || uploadSpeedLimit != null;
  
  String get speedLimitDisplay {
    if (!hasSpeedLimit) return 'Unlimited';
    
    final download = downloadSpeedLimit;
    final upload = uploadSpeedLimit;
    
    if (download != null && upload != null) {
      return '↓${_formatSpeed(download)} ↑${_formatSpeed(upload)}';
    } else if (download != null) {
      return '↓${_formatSpeed(download)}';
    } else if (upload != null) {
      return '↑${_formatSpeed(upload)}';
    }
    
    return 'Unlimited';
  }
  
  String _formatSpeed(int speedKbps) {
    if (speedKbps >= 1000) {
      return '${(speedKbps / 1000).toStringAsFixed(1)} Mbps';
    }
    return '$speedKbps Kbps';
  }
  
  String get signalStrengthText {
    final strength = signalStrength ?? 0;
    if (strength >= 80) return 'Excellent';
    if (strength >= 60) return 'Good';
    if (strength >= 40) return 'Fair';
    return 'Weak';
  }
  
  int get signalStrengthBars {
    final strength = signalStrength ?? 0;
    if (strength >= 80) return 4;
    if (strength >= 60) return 3;
    if (strength >= 40) return 2;
    if (strength >= 20) return 1;
    return 0;
  }
  
  DeviceEntity copyWith({
    String? macAddress,
    String? ipAddress,
    String? displayName,
    String? manufacturer,
    String? deviceType,
    bool? isOnline,
    bool? isBlocked,
    int? downloadSpeedLimit,
    int? uploadSpeedLimit,
    int? signalStrength,
    DateTime? lastSeen,
  }) {
    return DeviceEntity(
      macAddress: macAddress ?? this.macAddress,
      ipAddress: ipAddress ?? this.ipAddress,
      displayName: displayName ?? this.displayName,
      manufacturer: manufacturer ?? this.manufacturer,
      deviceType: deviceType ?? this.deviceType,
      isOnline: isOnline ?? this.isOnline,
      isBlocked: isBlocked ?? this.isBlocked,
      downloadSpeedLimit: downloadSpeedLimit ?? this.downloadSpeedLimit,
      uploadSpeedLimit: uploadSpeedLimit ?? this.uploadSpeedLimit,
      signalStrength: signalStrength ?? this.signalStrength,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
  
  @override
  List<Object?> get props => [
    macAddress,
    ipAddress,
    displayName,
    manufacturer,
    deviceType,
    isOnline,
    isBlocked,
    downloadSpeedLimit,
    uploadSpeedLimit,
    signalStrength,
    lastSeen,
  ];
}

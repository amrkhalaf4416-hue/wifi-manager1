part of 'devices_cubit.dart';

enum DevicesStatus { initial, loading, success, failure }

enum DeviceActionStatus { 
  idle, 
  blocking, 
  unblocking, 
  settingSpeed, 
  removingSpeed, 
  success, 
  failure 
}

class DevicesState extends Equatable {
  final DevicesStatus status;
  final List<DeviceEntity> devices;
  final List<DeviceEntity> filteredDevices;
  final String? searchQuery;
  final String? errorMessage;
  final DeviceActionStatus actionStatus;
  final bool isFromCache;
  
  const DevicesState({
    this.status = DevicesStatus.initial,
    this.devices = const [],
    this.filteredDevices = const [],
    this.searchQuery,
    this.errorMessage,
    this.actionStatus = DeviceActionStatus.idle,
    this.isFromCache = false,
  });
  
  List<DeviceEntity> get displayDevices => 
      searchQuery != null && searchQuery!.isNotEmpty 
          ? filteredDevices 
          : devices;
  
  int get onlineCount => devices.where((d) => d.isOnline && !d.isBlocked).length;
  int get blockedCount => devices.where((d) => d.isBlocked).length;
  int get limitedCount => devices.where((d) => d.hasSpeedLimit).length;
  
  DevicesState copyWith({
    DevicesStatus? status,
    List<DeviceEntity>? devices,
    List<DeviceEntity>? filteredDevices,
    String? searchQuery,
    String? errorMessage,
    DeviceActionStatus? actionStatus,
    bool? isFromCache,
  }) {
    return DevicesState(
      status: status ?? this.status,
      devices: devices ?? this.devices,
      filteredDevices: filteredDevices ?? this.filteredDevices,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
      actionStatus: actionStatus ?? this.actionStatus,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }
  
  @override
  List<Object?> get props => [
    status,
    devices,
    filteredDevices,
    searchQuery,
    errorMessage,
    actionStatus,
    isFromCache,
  ];
}

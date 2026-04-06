import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wifi_manager/domain/entities/device_entity.dart';
import 'package:wifi_manager/domain/repositories/device_repository.dart';

part 'devices_state.dart';

class DevicesCubit extends Cubit<DevicesState> {
  final DeviceRepository _deviceRepository;
  // BUG FIX: إضافة mutex بسيط لمنع تعدد طلبات التحديث المتزامنة
  bool _isLoading = false;

  DevicesCubit(this._deviceRepository) : super(const DevicesState());

  Future<void> loadDevices({bool forceRefresh = false}) async {
    if (_isLoading && !forceRefresh) return; // منع الطلبات المتزامنة
    _isLoading = true;

    try {
      if (!isClosed) emit(state.copyWith(status: DevicesStatus.loading));

      // عرض الكاش أولاً إن لم يكن forceRefresh
      if (!forceRefresh) {
        final cachedResult = await _deviceRepository.getCachedDevices();
        cachedResult.fold(
          (_) {},
          (devices) {
            if (devices.isNotEmpty && !isClosed) {
              emit(state.copyWith(
                status: DevicesStatus.success,
                devices: devices,
                isFromCache: true,
              ));
            }
          },
        );
      }

      // جلب بيانات جديدة
      final result = await _deviceRepository.getConnectedDevices();

      if (isClosed) return;

      result.fold(
        (failure) {
          // إذا عندنا بيانات مُخزنة، لا نُظهر خطأ
          if (state.devices.isEmpty) {
            emit(state.copyWith(
              status: DevicesStatus.failure,
              errorMessage: failure,
            ));
          }
          // نُبقي على البيانات القديمة ونُعلم المستخدم بصمت
        },
        (devices) {
          emit(state.copyWith(
            status: DevicesStatus.success,
            devices: devices,
            isFromCache: false,
            errorMessage: null, // مسح الأخطاء القديمة
          ));
        },
      );
    } finally {
      _isLoading = false;
    }
  }

  Future<void> refreshDevices() => loadDevices(forceRefresh: true);

  Future<void> setDeviceName(String macAddress, String name) async {
    final result = await _deviceRepository.setDeviceName(macAddress, name);
    if (isClosed) return;

    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure)),
      (_) {
        final updated = _updateDevice(
          macAddress,
          (d) => d.copyWith(displayName: name),
        );
        emit(state.copyWith(devices: updated));
      },
    );
  }

  Future<void> blockDevice(String macAddress) async {
    if (isClosed) return;
    emit(state.copyWith(actionStatus: DeviceActionStatus.blocking));

    final result = await _deviceRepository.blockDevice(macAddress);
    if (isClosed) return;

    result.fold(
      (failure) => emit(state.copyWith(
        actionStatus: DeviceActionStatus.failure,
        errorMessage: failure,
      )),
      (_) {
        final updated = _updateDevice(macAddress, (d) => d.copyWith(isBlocked: true));
        emit(state.copyWith(devices: updated, actionStatus: DeviceActionStatus.success));
      },
    );
  }

  Future<void> unblockDevice(String macAddress) async {
    if (isClosed) return;
    emit(state.copyWith(actionStatus: DeviceActionStatus.unblocking));

    final result = await _deviceRepository.unblockDevice(macAddress);
    if (isClosed) return;

    result.fold(
      (failure) => emit(state.copyWith(
        actionStatus: DeviceActionStatus.failure,
        errorMessage: failure,
      )),
      (_) {
        final updated = _updateDevice(macAddress, (d) => d.copyWith(isBlocked: false));
        emit(state.copyWith(devices: updated, actionStatus: DeviceActionStatus.success));
      },
    );
  }

  Future<void> setSpeedLimit(String macAddress, int? downloadKbps, int? uploadKbps) async {
    if (isClosed) return;
    emit(state.copyWith(actionStatus: DeviceActionStatus.settingSpeed));

    final result = await _deviceRepository.setSpeedLimit(macAddress, downloadKbps, uploadKbps);
    if (isClosed) return;

    result.fold(
      (failure) => emit(state.copyWith(
        actionStatus: DeviceActionStatus.failure,
        errorMessage: failure,
      )),
      (_) {
        final updated = _updateDevice(
          macAddress,
          (d) => d.copyWith(
            downloadSpeedLimit: downloadKbps,
            uploadSpeedLimit: uploadKbps,
          ),
        );
        emit(state.copyWith(devices: updated, actionStatus: DeviceActionStatus.success));
      },
    );
  }

  Future<void> removeSpeedLimit(String macAddress) async {
    if (isClosed) return;
    emit(state.copyWith(actionStatus: DeviceActionStatus.removingSpeed));

    final result = await _deviceRepository.removeSpeedLimit(macAddress);
    if (isClosed) return;

    result.fold(
      (failure) => emit(state.copyWith(
        actionStatus: DeviceActionStatus.failure,
        errorMessage: failure,
      )),
      (_) {
        // SCALABILITY FIX: copyWith مع null ينقل القيم الجديدة null (لازم تُعالج في entity)
        final updated = state.devices.map((d) {
          if (d.macAddress.toUpperCase() != macAddress.toUpperCase()) return d;
          return DeviceEntity(
            macAddress: d.macAddress,
            ipAddress: d.ipAddress,
            displayName: d.displayName,
            manufacturer: d.manufacturer,
            deviceType: d.deviceType,
            isOnline: d.isOnline,
            isBlocked: d.isBlocked,
            downloadSpeedLimit: null, // مسح صريح
            uploadSpeedLimit: null,
            signalStrength: d.signalStrength,
            lastSeen: d.lastSeen,
          );
        }).toList();
        emit(state.copyWith(devices: updated, actionStatus: DeviceActionStatus.success));
      },
    );
  }

  void searchDevices(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      emit(state.copyWith(searchQuery: null, filteredDevices: []));
      return;
    }

    final filtered = state.devices.where((d) =>
      d.displayName.toLowerCase().contains(q) ||
      d.macAddress.toLowerCase().contains(q) ||
      d.ipAddress.contains(q) ||
      d.manufacturer.toLowerCase().contains(q)
    ).toList();

    emit(state.copyWith(searchQuery: query, filteredDevices: filtered));
  }

  void clearSearch() => emit(state.copyWith(searchQuery: null, filteredDevices: []));
  void clearError() => !isClosed ? emit(state.copyWith(errorMessage: null)) : null;
  void clearActionStatus() => !isClosed ? emit(state.copyWith(actionStatus: DeviceActionStatus.idle)) : null;

  /// Helper: تحديث جهاز واحد في القائمة بدون نسخ كل القائمة يدوياً في كل مكان
  List<DeviceEntity> _updateDevice(String macAddress, DeviceEntity Function(DeviceEntity) updater) {
    return state.devices.map((d) {
      if (d.macAddress.toUpperCase() != macAddress.toUpperCase()) return d;
      return updater(d);
    }).toList();
  }
}

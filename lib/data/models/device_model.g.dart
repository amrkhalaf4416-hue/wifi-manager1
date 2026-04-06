// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'device_model.dart';

class DeviceModelAdapter extends TypeAdapter<DeviceModel> {
  @override
  final int typeId = 0;

  @override
  DeviceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeviceModel(
      macAddress: fields[0] as String,
      ipAddress: fields[1] as String,
      hostname: fields[2] as String?,
      customName: fields[3] as String?,
      manufacturer: fields[4] as String,
      deviceType: fields[5] as String,
      isOnline: fields[6] as bool,
      isBlocked: fields[7] as bool,
      downloadSpeedLimit: fields[8] as int?,
      uploadSpeedLimit: fields[9] as int?,
      signalStrength: fields[10] as int?,
      lastSeen: fields[11] as DateTime?,
      connectedSince: fields[12] as DateTime?,
      downloadBytes: fields[13] as int?,
      uploadBytes: fields[14] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, DeviceModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.macAddress)
      ..writeByte(1)
      ..write(obj.ipAddress)
      ..writeByte(2)
      ..write(obj.hostname)
      ..writeByte(3)
      ..write(obj.customName)
      ..writeByte(4)
      ..write(obj.manufacturer)
      ..writeByte(5)
      ..write(obj.deviceType)
      ..writeByte(6)
      ..write(obj.isOnline)
      ..writeByte(7)
      ..write(obj.isBlocked)
      ..writeByte(8)
      ..write(obj.downloadSpeedLimit)
      ..writeByte(9)
      ..write(obj.uploadSpeedLimit)
      ..writeByte(10)
      ..write(obj.signalStrength)
      ..writeByte(11)
      ..write(obj.lastSeen)
      ..writeByte(12)
      ..write(obj.connectedSince)
      ..writeByte(13)
      ..write(obj.downloadBytes)
      ..writeByte(14)
      ..write(obj.uploadBytes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

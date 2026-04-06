// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'router_settings_model.dart';

class RouterSettingsModelAdapter extends TypeAdapter<RouterSettingsModel> {
  @override
  final int typeId = 1;

  @override
  RouterSettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RouterSettingsModel(
      routerIp: fields[0] as String,
      username: fields[1] as String,
      password: fields[2] as String,
      isLoggedIn: fields[3] as bool,
      sessionCookie: fields[4] as String?,
      lastLoginTime: fields[5] as DateTime?,
      routerName: fields[6] as String?,
      routerModel: fields[7] as String?,
      firmwareVersion: fields[8] as String?,
      ssid: fields[9] as String?,
      ssid5G: fields[10] as String?,
      isSaveCredentials: fields[11] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, RouterSettingsModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.routerIp)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.password)
      ..writeByte(3)
      ..write(obj.isLoggedIn)
      ..writeByte(4)
      ..write(obj.sessionCookie)
      ..writeByte(5)
      ..write(obj.lastLoginTime)
      ..writeByte(6)
      ..write(obj.routerName)
      ..writeByte(7)
      ..write(obj.routerModel)
      ..writeByte(8)
      ..write(obj.firmwareVersion)
      ..writeByte(9)
      ..write(obj.ssid)
      ..writeByte(10)
      ..write(obj.ssid5G)
      ..writeByte(11)
      ..write(obj.isSaveCredentials);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RouterSettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

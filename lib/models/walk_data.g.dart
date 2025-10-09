// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'walk_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LatLngAdapterAdapter extends TypeAdapter<LatLngAdapter> {
  @override
  final int typeId = 1;

  @override
  LatLngAdapter read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LatLngAdapter(
      latitude: fields[0] as double,
      longitude: fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, LatLngAdapter obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.latitude)
      ..writeByte(1)
      ..write(obj.longitude);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LatLngAdapterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WalkDataAdapter extends TypeAdapter<WalkData> {
  @override
  final int typeId = 2;

  @override
  WalkData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WalkData(
      distanceKm: fields[0] as double,
      durationMicroseconds: fields[1] as int,
      startTime: fields[2] as DateTime,
      pathPoints: (fields[3] as List).cast<LatLngAdapter>(),
      userId: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, WalkData obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.distanceKm)
      ..writeByte(1)
      ..write(obj.durationMicroseconds)
      ..writeByte(2)
      ..write(obj.startTime)
      ..writeByte(3)
      ..write(obj.pathPoints)
      ..writeByte(4)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalkDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

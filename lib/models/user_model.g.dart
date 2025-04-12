// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      name: fields[0] as String,
      schoolLevel: fields[1] as String,
      knownLetters: (fields[2] as List?)?.cast<String>(),
      accuracyByLevel: (fields[3] as Map).cast<int, double>(),
      overallAccuracy: fields[4] as double?,
      gameLevel: fields[5] as int,
      conquest: fields[6] as int,
      firstTrySuccesses: fields[7] as int,
      otherSuccesses: fields[8] as int,
      gamesAccuracy: (fields[9] as Map).map((dynamic k, dynamic v) =>
          MapEntry(k as String, (v as List).cast<double>())),
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.schoolLevel)
      ..writeByte(2)
      ..write(obj.knownLetters)
      ..writeByte(3)
      ..write(obj.accuracyByLevel)
      ..writeByte(4)
      ..write(obj.overallAccuracy)
      ..writeByte(5)
      ..write(obj.gameLevel)
      ..writeByte(6)
      ..write(obj.conquest)
      ..writeByte(7)
      ..write(obj.firstTrySuccesses)
      ..writeByte(8)
      ..write(obj.otherSuccesses)
      ..writeByte(9)
      ..write(obj.gamesAccuracy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

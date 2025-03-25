// Código gerado automaticamente pelo Hive para o modelo do utilizador. Não o fazer á mão!!!

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

// Adaptador usado pelo Hive para ler e escrever objetos do tipo UserModel
class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0; // ID único usado pelo Hive para identificar este tipo

  // Método para converter dados binários em um objeto UserModel
  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte(); // Número de campos serializados
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return UserModel(
      name: fields[0] as String,
      level: fields[1] as String,
      knownLetters: (fields[2] as List?)?.cast<String>(),
    );
  }

  // Método para converter um objeto UserModel em dados binários para armazenamento
  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(3)         // Número de campos
      ..writeByte(0)         // Campo 0: name
      ..write(obj.name)
      ..writeByte(1)         // Campo 1: level
      ..write(obj.level)
      ..writeByte(2)         // Campo 2: knownLetters
      ..write(obj.knownLetters);
  }

  // Necessário para garantir consistência na identificação do adaptador
  @override
  int get hashCode => typeId.hashCode;

  // Verificação de igualdade com outro adaptador
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

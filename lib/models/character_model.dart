import 'package:hive/hive.dart';

part 'character_model.g.dart';

@HiveType(typeId: 1) // ◉ ID único para este modelo
class CharacterModel extends HiveObject {
  @HiveField(0) // ◉ índice 0
  final String character;

  @HiveField(1) // ◉ índice 1
  final String soundPath;

  @HiveField(2)
  final String type; // 'vowel', 'consonant', 'number'

  CharacterModel({
    required this.character,
    required this.soundPath,
    required this.type,
  });
}

/// Preenche a box 'characters' se estiver vazia
Future<void> populateCharactersIfNeeded() async {
  final box = await Hive.openBox<CharacterModel>('characters');

  if (box.isEmpty) {
    final letters = 'ABCDEFGHIJLMNOPQRSTUVXZ'.split('');
    final numbers = '0123456789'.split('');
    final characters = [...letters, ...numbers];

    for (var char in characters) {
      final fileName = '$char.ogg';
      final soundPath = 'assets/sounds/characters/$fileName';

    // Determina tipo
    late String type;
    if ('aeiou'.contains(char.toLowerCase())) {
      type = 'vowel';
    } else if ('bcdfghjlmnpqrstvxz'.contains(char.toLowerCase())) {
      type = 'consonant';
    } else if ('0123456789'.contains(char)) {
      type = 'number';
    }

    final model = CharacterModel(
      character: char,
      soundPath: soundPath,
      type: type,
    );

    await box.add(model);
  }
}
}

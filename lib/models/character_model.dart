import 'package:hive/hive.dart';

part 'character_model.g.dart';

@HiveType(typeId: 1) // ◉ ID único para este modelo
class CharacterModel extends HiveObject {
  @HiveField(0) // ◉ índice 0
  final String character;

  @HiveField(1) // ◉ índice 1
  final String soundPath;

  CharacterModel({
    required this.character,
    required this.soundPath,
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
      final soundPath = 'assets/sounds/words_characters/$fileName';

      final model = CharacterModel(
        character: char,
        soundPath: soundPath,
      );

      await box.add(model);
    }
  }
}

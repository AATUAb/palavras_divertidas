import 'package:audioplayers/audioplayers.dart';
import 'package:hive/hive.dart';
import '../models/character_model.dart';
import '../models/word_model.dart';
import '../widgets/game_item.dart';

class SoundManager {
  static final AudioPlayer _player = AudioPlayer();

  /// Toca o som de um carácter (letra ou número isolado)
  static Future<void> playCharacter(String character) async {
    final box = await Hive.openBox<CharacterModel>('characters');
    final model = box.values.firstWhere(
      (m) => m.character.toLowerCase() == character.toLowerCase(),
      orElse: () => CharacterModel(character: character, soundPath: ''),
    );

    if (model.soundPath.isNotEmpty) {
      final assetPath = model.soundPath.replaceFirst(RegExp(r'^assets/'), '');
      try {
        await _player.play(AssetSource(assetPath));
      } catch (e) {
        print("🔇 Erro ao tocar som do carácter '$character': $e");
      }
    } else {
      print("🔇 Som não encontrado para o carácter '$character'");
    }
  }

  /// Toca o som de uma palavra, procurando pelo texto ou pelo audioFileName
  static Future<void> playWord(String word) async {
    final box = await Hive.openBox<WordModel>('words');
    final model = box.values.firstWhere(
      (m) => m.text.toLowerCase() == word.toLowerCase(),
      orElse: () => WordModel(
        text: word,
        newLetter: '',
        topic: '',
        difficulty: '',
        syllables: [],
        syllableCount: 0,
      ),
    );

    final path = model.audioFileName != null
        ? 'sounds/${model.audioFileName}.ogg'
        : 'sounds/${model.text}.ogg';

    try {
      await _player.play(AssetSource(path));
    } catch (e) {
      print("🔇 Erro ao tocar som da palavra '$word': $e");
    }
  }

  /// Toca som com base no tipo de `GameItem`: carácter ou palavra
  static Future<void> playGameItem(GameItem item) async {
    if (item.isCharacter) {
      await playCharacter(item.content);
    } else if (item.isWord) {
      await playWord(item.content);
    } else {
      print("🔇 Tipo de item não suportado para som: ${item.type}");
    }
  }

  /// Para qualquer som a tocar
  static Future<void> stop() async {
    await _player.stop();
  }
}

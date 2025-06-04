import 'package:audioplayers/audioplayers.dart';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import '../models/character_model.dart';
import '../models/word_model.dart';
import '../widgets/game_item.dart';

class SoundManager {
  static final AudioPlayer _player = AudioPlayer();
  static bool _isStopped = false; 

  /// Toca o som de um carácter (letra ou número isolado)
  static Future<void> playCharacter(String character) async {
    if (_isStopped) return;
    final box = await Hive.openBox<CharacterModel>('characters');
    
    final model = box.values.firstWhere(
      (m) => m.character.toLowerCase() == character.toLowerCase(),
      orElse: () => CharacterModel(
        character: character, 
        soundPath: ''
        ),
    );

    if (model.soundPath.isNotEmpty) {
      final assetPath = model.soundPath.replaceFirst(RegExp(r'^assets/'), '');
      try {
        await _player.play(AssetSource(assetPath));
      } catch (e) {
        debugPrint("🔇 Erro ao tocar som do carácter '$character': $e");
      }
      } else {
        debugPrint("🔇 Som não encontrado para o carácter '$character'");
      }
    }

  /// Toca o som de uma palavra, procurando pelo texto ou pelo audioFileName
  static Box<WordModel>? _wordBox;

static Future<void> playWord(String word) async {
  if (_isStopped) return;
  _wordBox ??= await Hive.openBox<WordModel>('words');

  final model = _wordBox!.values.firstWhere(
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

  final filename = model.audioFileName ?? model.text;
  final rawPath = 'assets/sounds/words/$filename.ogg';
  final assetPath = rawPath.replaceFirst(RegExp(r'^assets/'), '');

  try {
    await _player.play(AssetSource(assetPath));
  } catch (e) {
    debugPrint("🔇 Erro ao tocar som da palavra '$word': $e");
  }
}


  /// Toca som com base no tipo de `GameItem`: carácter ou palavra
 static Future<void> playGameItem(GameItem item) async {
  _isStopped = false;

  final text = item.content.trim();

  // Delay necessário no Flutter Web para evitar erro WebAudioError
  await Future.delayed(const Duration(milliseconds: 300));
  
  if (_isStopped) return;

  if (item.type == GameItemType.character && text.length == 1) {
    await playCharacter(text);
  } else if ((item.type == GameItemType.character && text.length > 1) ||
             item.type == GameItemType.text) {
    await playWord(text);
  } else {
    debugPrint("🔇 Tipo de item não suportado: ${item.type} — $text");
  }
}

  /// Para qualquer som a tocar
  static Future<void> stop() async {
  _isStopped = true;
  await _player.stop();
}
}

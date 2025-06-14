import 'package:audioplayers/audioplayers.dart';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import '../models/character_model.dart';
import '../models/word_model.dart';
import '../widgets/game_item.dart';

class SoundManager {
  static final AudioPlayer _player = AudioPlayer();
  static final AudioPlayer _playerCase = AudioPlayer();
  static bool _isStopped = false; 

  static bool _isIntroGamesPlaying = false;
  static String? _lastIntroGamesFilename;

  static Future<void> play(String assetPath) async {
    if (_isStopped) return;
    try {
      await _player.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('Erro ao tocar som: \$e');
    }
  }

  static Future<void> stopAll() async {
    _isStopped = true;
    await _player.stop();
    await _playerCase.stop();
  }

  static void reset() => _isStopped = false;

  /// Toca o som de um carácter (letra ou número isolado)
  static Future<void> playCharacter(String character, {bool playCaseSuffix = false}) async {
    if (_isStopped) return;
    final box = await Hive.openBox<CharacterModel>('characters');
    
    final model = box.values.firstWhere(
      (m) => m.character.toLowerCase() == character.toLowerCase(),
      orElse: () => CharacterModel(
        character: character, 
        soundPath: '',
        type: '', 
        ),
    );

    if (model.soundPath.isNotEmpty) {
      final assetPath = model.soundPath.replaceFirst(RegExp(r'^assets/'), '');
      try {
        await _player.play(AssetSource(assetPath));

      // Se pediram o sufixo, toca a seguir
      if (playCaseSuffix && (model.type == 'vowel' || model.type == 'consonant')) {
        final caseSuffix = character == character.toUpperCase()
            ? 'uppercase.ogg'
            : 'lowercase.ogg';

      await Future.delayed(const Duration(milliseconds: 1500));
      if (_isStopped) return;
      await _playerCase.play(AssetSource('sounds/characters/$caseSuffix'));
    }

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
    await playCharacter(text, playCaseSuffix: item.playCaseSuffix);
  } else if ((item.type == GameItemType.character && text.length > 1) ||
             item.type == GameItemType.text) {
    await playWord(text);
  } else {
    debugPrint("🔇 Tipo de item não suportado: ${item.type} — $text");
  }
}

 /// Toca som de animações (como confetes, conquistas, fim de jogo)
  static Future<void> playAnimationSound(String filename) async {
    await play('sounds/animations/$filename');
  }

  /// Toca som gerais da aplicação (como música e escolha letras)
  static Future<void> playGeneralSound(String filename) async {
    _isStopped = false;
    await play('sounds/$filename');
  }

  /// Toca som de incio de jogos
  static Future<void> playIntroGames(String filename) async {
  _isStopped = false;
  _isIntroGamesPlaying = true;
  _lastIntroGamesFilename = filename;
  await play('sounds/games/$filename');
}

static Future<void> stopIntroGames() async {
  _isIntroGamesPlaying = false;
  await stop();
}

static bool isIntroGamesPlaying() {
  return _isIntroGamesPlaying;
}

static String? getLastIntroGamesFilename() {
  return _lastIntroGamesFilename;
}


  /// Para qualquer som a tocar
  static Future<void> stop() async {
    _isStopped = true;
    await _player.stop();
    await _playerCase.stop();
  }
}

/*import 'package:audioplayers/audioplayers.dart';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import '../models/character_model.dart';
import '../models/word_model.dart';
import '../widgets/game_item.dart';

class SoundManager {
  static final AudioPlayer _player = AudioPlayer();
  static final AudioPlayer _playerCase = AudioPlayer();
  static bool _isStopped = false;

  static bool _isIntroGamesPlaying = false;
  static String? _lastIntroGamesFilename;

  static bool _isWordPlaying = false;
  static String? _lastWordFilename;

  static bool _isCharacterPlaying = false;
  static String? _lastCharacterFilename;

  static Future<void> play(String assetPath) async {
    if (_isStopped) return;
    try {
      await _player.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('Erro ao tocar som: $e');
    }
  }

  static Future<void> stopAll() async {
    _isStopped = true;
    _isIntroGamesPlaying = false;
    _isWordPlaying = false;
    _isCharacterPlaying = false;
    _lastIntroGamesFilename = null;
    _lastWordFilename = null;
    _lastCharacterFilename = null;
    await _player.stop();
    await _playerCase.stop();
  }

  static void reset() => _isStopped = false;

  // === PLAY CHARACTER ===
  static Future<void> playCharacter(String character, {bool playCaseSuffix = false}) async {
    if (_isStopped) return;
    final box = await Hive.openBox<CharacterModel>('characters');

    final model = box.values.firstWhere(
      (m) => m.character.toLowerCase() == character.toLowerCase(),
      orElse: () => CharacterModel(
        character: character,
        soundPath: '',
        type: '',
      ),
    );

    if (model.soundPath.isNotEmpty) {
      final assetPath = model.soundPath.replaceFirst(RegExp(r'^assets/'), '');
      try {
        _isCharacterPlaying = true;
        _lastCharacterFilename = assetPath;

        await _player.play(AssetSource(assetPath));

        if (playCaseSuffix && (model.type == 'vowel' || model.type == 'consonant')) {
          final caseSuffix = character == character.toUpperCase()
              ? 'uppercase.ogg'
              : 'lowercase.ogg';

          await Future.delayed(const Duration(milliseconds: 1500));
          if (_isStopped) return;
          await _playerCase.play(AssetSource('sounds/characters/$caseSuffix'));
        }
      } catch (e) {
        _isCharacterPlaying = false;
        debugPrint("🔇 Erro ao tocar som do carácter '$character': $e");
      }
    } else {
      debugPrint("🔇 Som não encontrado para o carácter '$character'");
    }
  }

  static Future<void> stopCharacter() async {
    _isCharacterPlaying = false;
    _lastCharacterFilename = null;
    await _player.stop();
  }

  static bool isCharacterPlaying() {
    return _isCharacterPlaying;
  }

  static String? getLastCharacterFilename() {
    return _lastCharacterFilename;
  }

  // === PLAY WORD ===
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
      _isWordPlaying = true;
      _lastWordFilename = filename;
      await _player.play(AssetSource(assetPath));
    } catch (e) {
      _isWordPlaying = false;
      debugPrint("🔇 Erro ao tocar som da palavra '$word': $e");
    }
  }

  static Future<void> stopWord() async {
    _isWordPlaying = false;
    _lastWordFilename = null;
    await _player.stop();
  }

  static bool isWordPlaying() {
    return _isWordPlaying;
  }

  static String? getLastWordFilename() {
    return _lastWordFilename;
  }

  // === PLAY GAME ITEM ===
  static Future<void> playGameItem(GameItem item) async {
    _isStopped = false;

    final text = item.content.trim();

    // Delay necessário no Flutter Web para evitar erro WebAudioError
    await Future.delayed(const Duration(milliseconds: 300));

    if (_isStopped) return;

    if (item.type == GameItemType.character && text.length == 1) {
      await playCharacter(text, playCaseSuffix: item.playCaseSuffix);
    } else if ((item.type == GameItemType.character && text.length > 1) ||
        item.type == GameItemType.text) {
      await playWord(text);
    } else {
      debugPrint("🔇 Tipo de item não suportado: ${item.type} — $text");
    }
  }

  // === PLAY ANIMATION SOUND ===
  static Future<void> playAnimationSound(String filename) async {
    await play('sounds/animations/$filename');
  }

  // === PLAY GENERAL SOUND ===
  static Future<void> playGeneralSound(String filename) async {
    _isStopped = false;
    await play('sounds/$filename');
  }

  // === PLAY INTRO GAMES ===
  static Future<void> playIntroGames(String filename) async {
    _isStopped = false;
    _isIntroGamesPlaying = true;
    _lastIntroGamesFilename = filename;
    await play('sounds/games/$filename');
  }

  static Future<void> stopIntroGames() async {
    _isIntroGamesPlaying = false;
    _lastIntroGamesFilename = null;
    await _player.stop();
  }

  static bool isIntroGamesPlaying() {
    return _isIntroGamesPlaying;
  }

  static String? getLastIntroGamesFilename() {
    return _lastIntroGamesFilename;
  }

  static Future<void> stop() async {
  await _player.stop();
  await _playerCase.stop();
}
}*/

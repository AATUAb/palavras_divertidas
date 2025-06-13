//ficheiro main do jogo de escrita
//writing_game.dart


import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../models/character_model.dart';
import '../widgets/game_item.dart';
import '../widgets/game_super_widget.dart';
import 'package:mundodaspalavras/games/writing_game/tracing/writing_models.dart';
import 'package:mundodaspalavras/games/writing_game/tracing/writing_page.dart';
import 'package:mundodaspalavras/games/writing_game/get_shape_helper/machine_tracing.dart';
import 'package:mundodaspalavras/games/writing_game/get_shape_helper/cursive_tracing.dart';
import 'package:mundodaspalavras/games/writing_game/enums/shape_enums.dart';

class WriteGame extends StatefulWidget {
  final UserModel user;
  const WriteGame({super.key, required this.user});

  @override
  State<WriteGame> createState() => _WriteGameState();
}

class _WriteGameState extends State<WriteGame> {
  final _gamesSuperKey = GlobalKey<GamesSuperWidgetState>();
  final GlobalKey tracingKey = GlobalKey();

  bool hasChallengeStarted = false;
  int currentTry = 1;
  int correctCount = 1;
  List<CharacterModel> _characters = [];
  final List<String> _usedCharacters = [];
  String targetCharacter = '';

  Duration levelTime = const Duration(seconds: 10);
  bool isRoundActive = true;
  bool _isDisposed = false;

  late GameItem referenceItem;
  String tracedCharacter = '';

  bool get isFirstCycle => widget.user.schoolLevel == '1º Ciclo';

  @override
  void dispose() {
    _isDisposed = true;
    _cancelTimers();
    super.dispose();
  }

  Future<void> _applyLevelSettingsAndCharacters() async {
  final lvl = _gamesSuperKey.currentState?.levelManager.level ?? 1;
  final isPreschool = widget.user.schoolLevel == 'Pré-Escolar';
  final isFirstCycle = widget.user.schoolLevel == '1º Ciclo';

  // 1) Ajuste de tempo
  switch (lvl) {
      case 1:
        levelTime = const Duration(seconds: 120);
        break;
      case 2:
        levelTime = const Duration(seconds: 120);
        break;
      default:
        levelTime = const Duration(seconds: 120);
    }

  List<CharacterModel> tempChars = [];

  if (isPreschool || isFirstCycle) {
    // Abre sempre o box de characters
    final box = await Hive.openBox<CharacterModel>('characters');
    final allChars = box.values
        .where((c) => c.character.trim().isNotEmpty)
        .toList();

    // Filtra por tipo consoante nível:
    String targetType;
    if (lvl == 1) {
      targetType = 'number';
    } else if (lvl == 2) {
      targetType = 'vowel';
    } else {
      targetType = 'consonant';
    }

    final filtered = allChars.where((c) => c.type == targetType);

    // Para letras → duplicamos upper/lower; para números basta 1x
    for (var c in filtered) {
      final base = c.character.trim().toLowerCase();

      if (targetType == 'number') {
        tempChars.add(CharacterModel(
          character: base,
          soundPath: c.soundPath,
          type: c.type,
        ));
      } else {
        tempChars.addAll([
          CharacterModel(
            character: base.toUpperCase(),
            soundPath: 'assets/sounds/characters/${base.toUpperCase()}.ogg',
            type: c.type,
          ),
          CharacterModel(
            character: base.toLowerCase(),
            soundPath: 'assets/sounds/characters/${base.toLowerCase()}.ogg',
            type: c.type,
          ),
        ]);
      }
    }
  } else {
    tempChars = [];
  }

  _characters = tempChars;
  if (!mounted || _isDisposed) return;
  setState(() {});
}



  void _cancelTimers() {
    _gamesSuperKey.currentState?.cancelProgressTimer();
  }

  Future<void> _playInstruction() async {
    if (!mounted || _isDisposed) return;
    await _gamesSuperKey.currentState?.playNewChallengeSound(referenceItem);
  }

  Future<void> _generateNewChallenge() async {
  _gamesSuperKey.currentState?.playChallengeHighlight();

  if (!mounted || _isDisposed) return;

  final retryId = _gamesSuperKey.currentState?.peekNextRetryTarget();
  final availableItems = _characters
      .where((c) => !_usedCharacters.contains(c.character))
      .toList();
  final hasRetry = retryId != null;

  // Caso de fim de jogo
  if (availableItems.isEmpty && !hasRetry) {
    _gamesSuperKey.currentState?.showEndOfGameDialog(
      onRestart: () async {
        _usedCharacters.clear();
        await _applyLevelSettingsAndCharacters();
        if (mounted) await _generateNewChallenge();
      },
    );
    return;
  }

  // Seleciona o desafio: retry ou novo
  final selected = retryId != null
      ? _gamesSuperKey.currentState!.safeRetry<CharacterModel>(
          list: _characters,
          retryId: retryId,
          matcher: (c) => c.character == retryId,
          fallback: () => _gamesSuperKey.currentState!.safeSelectItem(
            availableItems: availableItems,
          ),
        )
      : _gamesSuperKey.currentState!.safeSelectItem(
          availableItems: availableItems,
        );

  // Proteção — caso venha um CharacterModel vazio
  targetCharacter = selected.character;
  tracedCharacter = targetCharacter;

  if (targetCharacter.trim().isEmpty) {
    debugPrint('⚠️ TargetCharacter vazio! Skip challenge.');
    return;
  }

  // Regista como já usado
  if (!_usedCharacters.contains(targetCharacter)) {
    _usedCharacters.add(targetCharacter);
  }

  // Prepara referenceItem para som
  referenceItem = GameItem(
    id: targetCharacter,
    type: GameItemType.character,
    content: targetCharacter,
    dx: 0,
    dy: 0,
    backgroundColor: Colors.transparent,
    isCorrect: true,
    playCaseSuffix: true, 
  );

  // Toca som após 50 ms
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await Future.delayed(const Duration(milliseconds: 50));
    if (!mounted || _isDisposed) return;
    await _gamesSuperKey.currentState?.playNewChallengeSound(referenceItem);
  });

  // Reinicia timers
  _cancelTimers();
  setState(() {
    isRoundActive = true;
  });

  // Inicia progress timer
  _gamesSuperKey.currentState?.startProgressTimer(
    levelTime: levelTime,
    onTimeout: () {
      if (!mounted || _isDisposed) return;
      setState(() => isRoundActive = false);
      _gamesSuperKey.currentState?.registerFailedRound(targetCharacter);
      _gamesSuperKey.currentState?.showTimeout(
        applySettings: _applyLevelSettingsAndCharacters,
        generateNewChallenge: _generateNewChallenge,
      );
    },
  );
}


  Widget _buildTopText() {
  final isNumber = RegExp(r'^[0-9]$').hasMatch(targetCharacter);
  final label = isNumber ? 'o número' : 'a letra';

  return Padding(
    padding: EdgeInsets.only(top: 19.h, left: 16.w, right: 16.w),
    child: Text(
      hasChallengeStarted
          ? 'Escreve $label $targetCharacter'
          : 'Vamos praticar a escrita!',
    ),
  );
}


Widget _buildBoard(BuildContext context, _, __) {
  if (!hasChallengeStarted || targetCharacter.isEmpty) {
    return const SizedBox.shrink();
  }

  // 1) Identifica se é número
  const numbers = ['0','1','2','3','4','5','6','7','8','9'];
  final isNumber = numbers.contains(targetCharacter);

  // 2) Só cursiva para **letras** em 1.º Ciclo
  final useCursive = isFirstCycle && !isNumber;

  return Center(
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 28.h),
      child: SizedBox(
        width: 200.w,
        height: 200.h,
        child: Stack(
          alignment: Alignment.center,
          children: [
            TracingCharsGame(
              key: ValueKey(tracedCharacter),
              showAnchor: true,
              stateOfTracing: StateOfTracing.chars,
              // 3) Ajusta engine consoante useCursive
              trackingEngine: useCursive
                  ? CursiveTracking()
                  : TypeExtensionTracking(),
              fontType: useCursive
                  ? FontType.cursive
                  : FontType.machine,
              traceShapeModel: [
                TraceCharsModel(
                  chars: [
                    TraceCharModel(
                      char: tracedCharacter,
                      traceShapeOptions: TraceShapeOptions(
                        innerPaintColor: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
              onGameFinished: (isSuccessful) async {
                  if (!isRoundActive || tracedCharacter.isEmpty) return;
                  final s = _gamesSuperKey.currentState;
                  if (s == null || !isRoundActive) return;

                  setState(() => isRoundActive = false);

                  final item = GameItem(
                    id: targetCharacter,
                    type: GameItemType.character,
                    content: targetCharacter,
                    dx: 0.0,
                    dy: 0.0,
                    isCorrect: true,
                    backgroundColor: Colors.transparent,
                  );

                  item.isTapped = true;

                  final wasSuccessful = isSuccessful == 1;
                  if (wasSuccessful) {
                    _gamesSuperKey.currentState?.registerResponseTimeForCurrentRound(
                      user: widget.user,
                      gameName: 'Escrever',
                    );
                  }

                  await s.checkAnswerSingle(
                    selectedItem: item,
                    target: targetCharacter,
                    retryId: targetCharacter,
                    currentTry: currentTry,
                    applySettings: _applyLevelSettingsAndCharacters,
                    generateNewChallenge: () async {
                      setState(() {
                        tracedCharacter = '';
                        targetCharacter = '';
                      });
                      await Future.delayed(const Duration(milliseconds: 50));
                      await _generateNewChallenge();
                    },
                    cancelTimers: _cancelTimers,
                    showExtraFeedback: () async {
                      await Future.delayed(const Duration(seconds: 1));
                    },
                  );
                  setState(() => currentTry++);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GamesSuperWidget(
      key: _gamesSuperKey,
      user: widget.user,
      gameName: 'Escrever',
      level: (_) => _gamesSuperKey.currentState?.levelManager.level ?? 1,
      currentRound: (_) => 1,
      totalRounds: (_) => 3,
      isFirstCycle: isFirstCycle,
      topTextContent: _buildTopText,
      onRepeatInstruction: _playInstruction,
      introImagePath: 'assets/images/games/write_game.webp',
      introAudioPath: 'write_game.ogg',
      onIntroFinished: () async {
        _usedCharacters.clear();
        await _applyLevelSettingsAndCharacters();
        if (!mounted) return;
        setState(() => hasChallengeStarted = true);
        await _generateNewChallenge();
      },
      builder: _buildBoard,
    );
  }
}














/*


Para mostrtar palavras na primária, de acordo com o que sabe



import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../models/character_model.dart';
import '../models/word_model.dart';
import '../widgets/game_item.dart';
import '../widgets/game_super_widget.dart';
import '../screens/letters_selection.dart';
import 'package:mundodaspalavras/games/writing_game/tracing/writing_models.dart';
import 'package:mundodaspalavras/games/writing_game/tracing/writing_page.dart';
import 'package:mundodaspalavras/games/writing_game/get_shape_helper/machine_tracing.dart';
import 'package:mundodaspalavras/games/writing_game/get_shape_helper/cursive_tracing.dart';
import 'package:mundodaspalavras/games/writing_game/enums/shape_enums.dart';

class WriteGame extends StatefulWidget {
  final UserModel user;
  const WriteGame({Key? key, required this.user}) : super(key: key);

  @override
  State<WriteGame> createState() => _WriteGameState();
}

class _WriteGameState extends State<WriteGame> {
  final _gamesSuperKey = GlobalKey<GamesSuperWidgetState>();
  final GlobalKey tracingKey = GlobalKey();

  bool hasChallengeStarted = false;
  int currentTry = 1;
  int correctCount = 1;
  List<CharacterModel> _characters = [];
  final List<String> _usedCharacters = [];
  String targetCharacter = '';

  Duration levelTime = const Duration(seconds: 10);
  bool isRoundActive = true;
  bool _isDisposed = false;

  late GameItem referenceItem;
  String tracedCharacter = '';

  List<WordModel> _allWords = [];
  List<WordModel> _levelWords = [];
  final List<String> _usedWords = [];
  late WordModel targetWord;
  String tracedWord = '';
  Map<String, bool> tracedLetters = {};
  int levelWords = 1;
  int levelCharacters = 1;

  bool useWordsMode = false;
  bool get isFirstCycle => widget.user.schoolLevel == '1º Ciclo';
  bool get isPreschool => widget.user.schoolLevel == 'Pré-Escolar';
  int get currentLevel {
    return useWordsMode ? levelWords : levelCharacters;
  }


  Future<void> _loadWords() async {
  final box = await Hive.openBox<WordModel>('words');
  _allWords = box.values.toList();
}

  @override
  void dispose() {
    _isDisposed = true;
    _cancelTimers();
    super.dispose();
  }

  void updateLevelAfterRound(bool success) {
  if (useWordsMode) {
    if (success && levelWords < 3) levelWords++;
    if (!success && levelWords > 1) levelWords--;
  } else {
    if (success && levelCharacters < 3) levelCharacters++;
    if (!success && levelCharacters > 1) levelCharacters--;
  }
}

  bool shouldUseCursiveForFirstCycle() {
  if (!isFirstCycle) return false; // só interessa para 1º Ciclo

  final knownLettersRaw = widget.user.knownLetters;
  final knownLetters = expandKnownLetters(knownLettersRaw);

  final onlyVowels = knownLetters
      .toSet()
      .difference({'a', 'e', 'i', 'o', 'u'}).isEmpty;

  return knownLetters.isEmpty || onlyVowels;
}

bool shouldUseWordsMode() {
  final knownLettersRaw = widget.user.knownLetters;
  final knownLetters = expandKnownLetters(knownLettersRaw);

  final onlyVowels = knownLetters
      .toSet()
      .difference({'a', 'e', 'i', 'o', 'u'}).isEmpty;

  return knownLetters.isNotEmpty && !onlyVowels;
}

  bool wordIsPlayable(String word, Set<String> knownLetters) {
  // Remove acentos e normaliza
  final normalizedWord = removeDiacritics(word.toLowerCase());

  // Gera conjunto de letras distintas na palavra
  final wordLetters = normalizedWord
      .split('')
      .where((char) => RegExp(r'[a-z]').hasMatch(char))
      .toSet();

  // A palavra só é jogável se TODAS as letras estiverem nas letras conhecidas
  return wordLetters.every((letter) => knownLetters.contains(letter));
}

String removeDiacritics(String str) {
  const withDiacritics = 'áàâãäçéèêëíìîïóòôõöúùûüÁÀÂÃÄÇÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜ';
  const withoutDiacritics = 'aaaaaceeeeiiiiooooouuuuAAAAACEEEEIIIIOOOOOUUUU';

  for (int i = 0; i < withDiacritics.length; i++) {
    str = str.replaceAll(withDiacritics[i], withoutDiacritics[i]);
  }
  return str;
}

  Future<void> _applyLevelSettingsAndCharacters() async {
  final lvl = _gamesSuperKey.currentState?.levelManager.level ?? 1;
  final isPreschool = widget.user.schoolLevel == 'Pré-Escolar';
  final isFirstCycle = widget.user.schoolLevel == '1º Ciclo';
  useWordsMode = shouldUseWordsMode();


  // 1) Ajuste de tempo
  switch (lvl) {
    case 1: levelTime = const Duration(seconds: 120); break;
    case 2: levelTime = const Duration(seconds: 120); break;
    case 3: levelTime = const Duration(seconds: 120); break;
  }

  const vowels = ['a','e','i','o','u'];
  const consonants = [
    'b','c','d','f','g','h','j','l','m','n','p','q','r','s','t','v','x','z',
  ];
  // força sempre 10 dígitos
  const digits = ['0','1','2','3','4','5','6','7','8','9'];

  List<CharacterModel> tempChars = [];

  if (isPreschool || isFirstCycle) {
    if (lvl == 1) {
      // ——— nível 1: gera manualmente 0–9 ———
      for (var d in digits) {
        tempChars.add(CharacterModel(
          character: d,
          soundPath: 'assets/sounds/characters/$d.ogg',
        ));
      }
      debugPrint('🔢 Gerados ${tempChars.length} dígitos: '
        '${tempChars.map((c) => c.character).join(",")}');
    } else {
      // ——— níveis 2 e 3: vogais/consoantes do Hive ———
      final box = await Hive.openBox<CharacterModel>('characters');
      final allChars = box.values
        .where((c) => c.character.trim().isNotEmpty)
        .toList();

      final rawList = lvl == 2 ? vowels : consonants;
      final filtered = allChars.where((c) {
        return rawList.contains(c.character.trim().toLowerCase());
      });

      for (var c in filtered) {
        final base = c.character.trim().toLowerCase();
        tempChars.addAll([
          CharacterModel(
            character: base.toUpperCase(),
            soundPath:
              'assets/sounds/characters/${base.toUpperCase()}.ogg',
          ),
          CharacterModel(
            character: base.toLowerCase(),
            soundPath:
              'assets/sounds/characters/${base.toLowerCase()}.ogg',
          ),
        ]);
      }
    }
  } else {
    tempChars = [];
  }

  _characters = tempChars;
  if (!mounted || _isDisposed) return;
  setState(() {});

  if (useWordsMode) {
  final lvl = _gamesSuperKey.currentState?.levelManager.level ?? 1;
  late String levelDifficulty;

  switch (lvl) {
    case 1: levelDifficulty = 'baixa'; break;
    case 2: levelDifficulty = 'media'; break;
    default: levelDifficulty = 'dificil';
  }

  final knownLettersRaw = widget.user.knownLetters;
  final expandedLetters = expandKnownLetters(knownLettersRaw);

   _levelWords = _allWords.where((w) {
    return w.difficulty.trim().toLowerCase() == levelDifficulty &&
          !_usedWords.contains(w.text) &&
          w.audioPath.trim().isNotEmpty &&
          w.imagePath.trim().isNotEmpty &&
          w.text.trim().isNotEmpty &&
          expandedLetters.contains(w.newLetter.trim().toLowerCase());
  }).toList();
  }
  }



  void _cancelTimers() {
    _gamesSuperKey.currentState?.cancelProgressTimer();
  }

  Future<void> _playInstruction() async {
    if (!mounted || _isDisposed) return;
    await _gamesSuperKey.currentState?.playNewChallengeSound(referenceItem);
  }

  Future<void> _generateNewChallenge() async {
  _gamesSuperKey.currentState?.playChallengeHighlight();

  if (!mounted || _isDisposed) return;

  // ——————————— WORD MODE ———————————
  if (useWordsMode) {
    final retryId = _gamesSuperKey.currentState?.peekNextRetryTarget();
    final availableWords = _levelWords.where((w) => !_usedWords.contains(w.text)).toList();

    if (availableWords.isEmpty && retryId == null) {
      _gamesSuperKey.currentState?.showEndOfGameDialog(
        onRestart: () async {
          _usedWords.clear();
          await _loadWords();
          await _applyLevelSettingsAndCharacters();
          if (mounted) await _generateNewChallenge();
        },
      );
      return;
    }

    targetWord = retryId != null
    ? _gamesSuperKey.currentState!.safeRetry<WordModel>(
        list: availableWords,
        retryId: retryId,
        matcher: (w) => w.text == retryId,
        fallback: () => _gamesSuperKey.currentState!.safeSelectItem(
          availableItems: availableWords,
        ),
      )
    : _gamesSuperKey.currentState!.safeSelectItem(
        availableItems: availableWords,
      );

    tracedWord = targetWord.text;
    tracedLetters = {
      for (var i = 0; i < tracedWord.length; i++) '$i-${tracedWord[i]}' : false,
    };

    if (!_usedWords.contains(targetWord.text)) {
      _usedWords.add(targetWord.text);
    }

    tracedWord = targetWord.text;

    referenceItem = GameItem(
      id: targetWord.text,
      type: GameItemType.text,
      content: targetWord.audioPath,
      dx: 0,
      dy: 0,
      backgroundColor: Colors.transparent,
      isCorrect: true,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 50));
      if (!mounted || _isDisposed) return;
      await _gamesSuperKey.currentState?.playNewChallengeSound(referenceItem);
    });

    _cancelTimers();
    setState(() {
      isRoundActive = true;
    });

    _gamesSuperKey.currentState?.startProgressTimer(
      levelTime: levelTime,
      onTimeout: () {
        if (!mounted || _isDisposed) return;
        setState(() => isRoundActive = false);
        _gamesSuperKey.currentState?.registerFailedRound(targetWord.text);
        _gamesSuperKey.currentState?.showTimeout(
          applySettings: _applyLevelSettingsAndCharacters,
          generateNewChallenge: _generateNewChallenge,
        );
      },
    );

    return; // ——— Importante! Para não cair no path de characters
  }

  // ——————————— CHARACTER MODE ———————————

  final retryId = _gamesSuperKey.currentState?.peekNextRetryTarget();
  final availableItems =
      _characters.where((c) => !_usedCharacters.contains(c.character)).toList();

  if (availableItems.isEmpty && retryId == null) {
    _gamesSuperKey.currentState?.showEndOfGameDialog(
      onRestart: () async {
        _usedCharacters.clear();
        await _applyLevelSettingsAndCharacters();
        if (mounted) await _generateNewChallenge();
      },
    );
    return;
  }

  final selected = retryId != null
      ? _gamesSuperKey.currentState!.safeRetry<CharacterModel>(
          list: availableItems,
          retryId: retryId,
          matcher: (c) => c.character == retryId,
          fallback: () => _gamesSuperKey.currentState!.safeSelectItem(
            availableItems: availableItems,
          ),
        )
      : _gamesSuperKey.currentState!.safeSelectItem(
          availableItems: availableItems,
        );

  targetCharacter = selected.character;
  tracedCharacter = targetCharacter;

  if (!_usedCharacters.contains(targetCharacter)) {
    _usedCharacters.add(targetCharacter);
  }

  referenceItem = GameItem(
    id: targetCharacter,
    type: GameItemType.character,
    content: targetCharacter,
    dx: 0,
    dy: 0,
    backgroundColor: Colors.transparent,
    isCorrect: true,
  );

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await Future.delayed(const Duration(milliseconds: 50));
    if (!mounted || _isDisposed) return;
    await _gamesSuperKey.currentState?.playNewChallengeSound(referenceItem);
  });

  _cancelTimers();
  setState(() {
    isRoundActive = true;
  });

  _gamesSuperKey.currentState?.startProgressTimer(
    levelTime: levelTime,
    onTimeout: () {
      if (!mounted || _isDisposed) return;
      setState(() => isRoundActive = false);
      _gamesSuperKey.currentState?.registerFailedRound(targetCharacter);
      _gamesSuperKey.currentState?.showTimeout(
        applySettings: _applyLevelSettingsAndCharacters,
        generateNewChallenge: _generateNewChallenge,
      );
    },
  );
}


  Widget _buildTopText() {
    final font = getFontFamily(
  shouldUseCursiveForFirstCycle() ? FontStrategy.cursive : FontStrategy.none,
);

    const numbers = ['0','1','2','3','4','5','6','7','8','9'];
    final isNumber = numbers.contains(targetCharacter);
    final label = isNumber ? 'o número' : 'a letra';

    return Padding(
      padding: EdgeInsets.only(top: 19.h, left: 16.w, right: 16.w),
      child: Text(
        hasChallengeStarted
            ? 'Escreve $label $targetCharacter'
            : 'Vamos praticar a escrita!',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: font,
          fontSize: 25.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }


Widget _buildBoard(BuildContext context, int currentRound, int totalRounds) {
  if (!hasChallengeStarted) return const SizedBox.shrink();

  // Usa o "level" que o GamesSuperWidget já passa → currentRound
  final level = currentRound;

  return useWordsMode
      ? _buildWordBoard(context, level, totalRounds)
      : _buildCharacterBoard(context, level, totalRounds);
}

Widget _buildWordBoard(BuildContext context, int round, int totalRounds) {
  if (!hasChallengeStarted) return const SizedBox.shrink();

  final word = tracedWord;
  final useCursive = isFirstCycle;

  return Center(
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: word.split('').asMap().entries.map((entry) {
          final index = entry.key;
          final letter = entry.value;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: SizedBox(
              width: 50.w,
              height: 180.h,
              child: TracingCharsGame(
                key: ValueKey('$tracedWord-$index-$letter'),
                showAnchor: true,
                stateOfTracing: StateOfTracing.chars,
                trackingEngine: useCursive
                    ? CursiveTracking()
                    : TypeExtensionTracking(),
                fontType: useCursive
                    ? FontType.cursive
                    : FontType.machine,
                traceShapeModel: [
                  TraceCharsModel(
                    chars: [
                      TraceCharModel(
                        char: letter,
                        traceShapeOptions: TraceShapeOptions(
                          innerPaintColor: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
                onGameFinished: (isSuccessful) async {
                  if (!isRoundActive || letter.isEmpty) return;
                  if (isSuccessful == 1) {
                    setState(() {
                      tracedLetters['$index-$letter'] = true;
                    });

                    final allTraced = tracedLetters.values.every((v) => v == true);
                    if (allTraced) {
                      final s = _gamesSuperKey.currentState;
                      if (s == null || !isRoundActive) return;
                      setState(() => isRoundActive = false);

                      final item = GameItem(
                        id: targetWord.text,
                        type: GameItemType.text,
                        content: targetWord.audioFileName ?? '',
                        dx: 0,
                        dy: 0,
                        backgroundColor: Colors.transparent,
                        isCorrect: true,
                      );

                      item.isTapped = true;

                      _gamesSuperKey.currentState?.registerResponseTimeForCurrentRound(
                        user: widget.user,
                        gameName: 'Escrever',
                      );

                      await s.checkAnswerSingle(
                        selectedItem: item,
                        target: targetWord.text,
                        retryId: targetWord.text,
                        currentTry: currentTry,
                        applySettings: _applyLevelSettingsAndCharacters,
                        generateNewChallenge: () async {
                          setState(() {
                            tracedWord = '';
                            tracedLetters.clear();
                          });
                          await Future.delayed(const Duration(milliseconds: 50));
                          await _generateNewChallenge();
                        },
                        cancelTimers: _cancelTimers,
                        showExtraFeedback: () async {
                          await Future.delayed(const Duration(seconds: 1));
                        },
                      );

                      setState(() => currentTry++);
                    }
                  }
                },
              ),
            ),
          );
        }).toList(),
      ),
    ),
  );
}




  Widget _buildCharacterBoard(BuildContext context, _, __) {
  if (!hasChallengeStarted) return const SizedBox.shrink();
  // 1) Identifica se é número
  const numbers = ['0','1','2','3','4','5','6','7','8','9'];
  final isNumber = numbers.contains(targetCharacter);

  // 2) Só cursiva para **letras** em 1.º Ciclo
  final useCursive = isFirstCycle && !isNumber;

  return Center(
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 28.h),
      child: SizedBox(
        width: 200.w,
        height: 200.h,
        child: Stack(
          alignment: Alignment.center,
          children: [
            TracingCharsGame(
              key: ValueKey(tracedCharacter),
              showAnchor: true,
              stateOfTracing: StateOfTracing.chars,
              // 3) Ajusta engine consoante useCursive
              trackingEngine: useCursive
                  ? CursiveTracking()
                  : TypeExtensionTracking(),
              fontType: useCursive
                  ? FontType.cursive
                  : FontType.machine,
              traceShapeModel: [
                TraceCharsModel(
                  chars: [
                    TraceCharModel(
                      char: tracedCharacter,
                      traceShapeOptions: TraceShapeOptions(
                        innerPaintColor: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
              onGameFinished: (isSuccessful) async {
                  if (!isRoundActive || tracedCharacter.isEmpty) return;
                  final s = _gamesSuperKey.currentState;
                  if (s == null || !isRoundActive) return;

                  setState(() => isRoundActive = false);

                  final item = GameItem(
                    id: targetCharacter,
                    type: GameItemType.character,
                    content: targetCharacter,
                    dx: 0.0,
                    dy: 0.0,
                    isCorrect: true,
                    backgroundColor: Colors.transparent,
                  );

                  item.isTapped = true;

                  final wasSuccessful = isSuccessful == 1;
                  if (wasSuccessful) {
                    _gamesSuperKey.currentState?.registerResponseTimeForCurrentRound(
                      user: widget.user,
                      gameName: 'Escrever',
                    );
                  }

                  await s.checkAnswerSingle(
                    selectedItem: item,
                    target: targetCharacter,
                    retryId: targetCharacter,
                    currentTry: currentTry,
                    applySettings: _applyLevelSettingsAndCharacters,
                    generateNewChallenge: () async {
                      setState(() {
                        tracedCharacter = '';
                        targetCharacter = '';
                      });
                      await Future.delayed(const Duration(milliseconds: 50));
                      await _generateNewChallenge();
                    },
                    cancelTimers: _cancelTimers,
                    showExtraFeedback: () async {
                      await Future.delayed(const Duration(seconds: 1));
                    },
                  );
                  setState(() => currentTry++);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GamesSuperWidget(
      key: _gamesSuperKey,
      user: widget.user,
      gameName: 'Escrever',
      level: (_) => _gamesSuperKey.currentState?.levelManager.level ?? 1,
      currentRound: (_) => 1,
      totalRounds: (_) => 3,
      isFirstCycle: isFirstCycle,
      topTextContent: _buildTopText,
      onRepeatInstruction: _playInstruction,
      introImagePath: 'assets/images/games/write_game.webp',
      introAudioPath: 'write_game.ogg',
      onIntroFinished: () async {
        await _loadWords();
        _usedCharacters.clear();
        await _applyLevelSettingsAndCharacters();
        if (!mounted) return;
        setState(() => hasChallengeStarted = true);
        await _generateNewChallenge();
      },
      builder: _buildBoard,
    );
  }
}*/
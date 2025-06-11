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

  bool get isFirstCycle => widget.user.schoolLevel == '1º Ciclo';
  bool get isPreschool => widget.user.schoolLevel == 'Pré-Escolar';

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
      isFirstCycle ? FontStrategy.cursive : FontStrategy.none,
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
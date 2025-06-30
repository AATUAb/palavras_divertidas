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

  // Carrega os caracteres e ajusta o tempo de jogo
  Future<void> _applyLevelSettingsAndCharacters() async {
    final lvl = _gamesSuperKey.currentState?.levelManager.level ?? 1;
    final schoolLevel = widget.user.schoolLevel; // 'Pré-Escolar' ou '1º Ciclo'

    // 1) Tempo por grupo e nível - Tabela do Jogo 2
    const Map<String, List<int>> game2TimesPerLevel = {
      'Pré-Escolar': [15, 10, 10],
      '1º Ciclo': [15, 15, 15],
    };

    // Defensive fallback
    final times = game2TimesPerLevel[schoolLevel] ?? [15, 15, 15];
    levelTime = Duration(seconds: times[(lvl - 1).clamp(0, times.length - 1)]);

    // 2) Preparação dos caracteres
    List<CharacterModel> tempChars = [];

    final isPreschool = schoolLevel == 'Pré-Escolar';
    final isFirstCycle = schoolLevel == '1º Ciclo';

    if (isPreschool || isFirstCycle) {
      // Abre sempre o box de characters
      final box = await Hive.openBox<CharacterModel>('characters');
      final allChars =
          box.values.where((c) => c.character.trim().isNotEmpty).toList();

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
          tempChars.add(
            CharacterModel(
              character: base,
              soundPath: c.soundPath,
              type: c.type,
            ),
          );
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

    final availableItems =
        _characters
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
    final selected =
        retryId != null
            ? _gamesSuperKey.currentState!.safeRetry<CharacterModel>(
              list: _characters,
              retryId: retryId,
              matcher: (c) => c.character == retryId,
              fallback:
                  () => _gamesSuperKey.currentState!.safeSelectItem(
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

  void _showTutorial() {
    final state = _gamesSuperKey.currentState;

    final safeRetryId = hasChallengeStarted ? targetCharacter : null;

    state?.showTutorialDialog(
      retryId: safeRetryId,
      onTutorialClosed: () {
        _generateNewChallenge();
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
    const numbers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
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
                trackingEngine:
                    useCursive ? CursiveTracking() : TypeExtensionTracking(),
                fontType: useCursive ? FontType.cursive : FontType.machine,
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
                    _gamesSuperKey.currentState
                        ?.registerResponseTimeForCurrentRound(
                          user: widget.user,
                          gameName: 'Escrever',
                        );

                    final retryQueue = s.retryQueueContents();
                    if (retryQueue.contains(targetCharacter)) {
                      s.removeFromRetryQueue(targetCharacter);
                    }
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
                  _gamesSuperKey.currentState?.registerCompletedRound(
                    targetCharacter,
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
        if (!_gamesSuperKey.currentState!.isTutorialVisible) {
          _generateNewChallenge();
        }
      },
      onShowTutorial: () {
        _showTutorial();
      },
      builder: _buildBoard,
    );
  }
}

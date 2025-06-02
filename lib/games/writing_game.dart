import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../models/character_model.dart';
import '../widgets/game_item.dart';
import '../widgets/game_super_widget.dart';

import 'package:mundodaspalavras/games/writing_game/tracing/writing_models.dart';
import 'package:mundodaspalavras/games/writing_game/tracing/writing_page.dart';

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
  double progressValue = 1.0;
  bool isRoundActive = true;
  bool _isDisposed = false;
  bool? isCorrect; 

  late GameItem referenceItem;
  Timer? roundTimer, progressTimer;
  late DateTime _startTime;
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

    switch (lvl) {
      case 1:
        levelTime = const Duration(seconds: 10);
        break;
      case 2:
        levelTime = const Duration(seconds: 15);
        break;
      case 3:
        levelTime = const Duration(seconds: 20);
        break;
    }

    final box = await Hive.openBox<CharacterModel>('characters');
    final allChars = box.values.where((c) => c.character.trim().isNotEmpty).toList();

    const vowels = ['a','e','i','o','u'];
    const consonants = ['b','c','d','f','g','h','j','l','m','n','p','q','r','s','t','v','x','z'];
    const numbers = ['0','1','2','3','4','5','6','7','8','9'];

    if (isPreschool) {
      final filteredChars = allChars.where((c) {
        final char = c.character.trim().toLowerCase();
        return switch (lvl) {
          1 => numbers.contains(char),
          2 => vowels.contains(char),
          3 => consonants.contains(char),
          _ => false,
        };
      }).toList();

      final expandedChars = filteredChars.expand((c) {
        final baseChar = c.character.trim().toLowerCase();

        return [
          CharacterModel(
            character: baseChar.toUpperCase(),
            soundPath: 'assets/sounds/characters/${baseChar.toUpperCase()}.ogg',
          ),
          CharacterModel(
            character: baseChar.toLowerCase(),
            soundPath: 'assets/sounds/characters/${baseChar.toLowerCase()}.ogg',
          ),
        ];
      }).toList();

      _characters = expandedChars;
    } else {
      _characters = allChars;
    }

    if (!mounted || _isDisposed) return;
    setState(() {});
  }

  void _cancelTimers() {
    roundTimer?.cancel();
    progressTimer?.cancel();
  }

  Future<void> _playInstruction() async {
    if (!mounted || _isDisposed) return;
    await _gamesSuperKey.currentState?.playNewChallengeSound(referenceItem);
  }

  Future<void> _generateNewChallenge() async {
    _gamesSuperKey.currentState?.playChallengeHighlight();
    if (!mounted || _isDisposed) return;

    final retryId = _gamesSuperKey.currentState?.peekNextRetryTarget();

    final availableItems = _characters.where(
      (c) => !_usedCharacters.contains(c.character),
    ).toList();

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
    _startTime = DateTime.now();

    progressTimer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      if (!mounted || _isDisposed) return t.cancel();
      final elapsed = DateTime.now().difference(_startTime);
      setState(() {
        progressValue = (1.0 - elapsed.inMilliseconds / levelTime.inMilliseconds).clamp(0.0, 1.0);
      });
    });

    roundTimer = Timer(levelTime, () {
      if (!mounted || _isDisposed) return;
      setState(() => isRoundActive = false);
      _cancelTimers();
      _gamesSuperKey.currentState?.registerFailedRound(targetCharacter);
      _gamesSuperKey.currentState?.showTimeout(
        applySettings: _applyLevelSettingsAndCharacters,
        generateNewChallenge: _generateNewChallenge,
      );
    });
  }

  String _randomCase(String char) {
    if (!RegExp(r'[a-zA-Z]').hasMatch(char)) return char;
    return Random().nextBool() ? char.toUpperCase() : char.toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return GamesSuperWidget(
      key: _gamesSuperKey,
      user: widget.user,
      gameName: 'Escrever',
      progressValue: progressValue,
      level: (_) => _gamesSuperKey.currentState?.levelManager.level ?? 1,
      currentRound: (_) => 1,
      totalRounds: (_) => 3,
      isFirstCycle: isFirstCycle,
      topTextContent: _buildTopText,
      onRepeatInstruction: _playInstruction,
      introImagePath: 'assets/images/games/write_game.webp',
      introAudioPath: 'sounds/games/write_game.ogg',
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

  Widget _buildTopText() {
    final font = getFontFamily(
      isFirstCycle ? FontStrategy.slabo : FontStrategy.none,
    );
    return Padding(
      padding: EdgeInsets.only(top: 19.h, left: 16.w, right: 16.w),
      child: Text(
        hasChallengeStarted ? 'Escreve a letra $targetCharacter' : 'Vamos praticar a escrita!',
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
                traceShapeModel: [
                  TraceCharsModel(chars: [
                    TraceCharModel(
                      char: tracedCharacter,
                      traceShapeOptions: const TraceShapeOptions(
                        innerPaintColor: Colors.orange,
                      ),
                    ),
                  ]),
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

                      await Future.delayed(Duration(milliseconds: 50));
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
}

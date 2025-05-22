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

class WriteGame extends StatefulWidget {
  final UserModel user;
  const WriteGame({Key? key, required this.user}) : super(key: key);

  @override
  State<WriteGame> createState() => _WriteGameState();
}

class _WriteGameState extends State<WriteGame> {
  final _gamesSuperKey = GlobalKey<GamesSuperWidgetState>();

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

  late GameItem referenceItem;
  Timer? roundTimer, progressTimer;
  DateTime? _startTime;

  bool get isFirstCycle => widget.user.schoolLevel == '1º Ciclo';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _cancelTimers();
    super.dispose();
  }

  Future<void> _loadCharacters() async {
    final box = await Hive.openBox<CharacterModel>('characters');
    _characters = box.values
        .where((c) => c.character.trim().isNotEmpty)
        .toList();
  }

  Future<void> _applyLevelSettings() async {
    final lvl = _gamesSuperKey.currentState?.levelManager.level ?? 1;
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
    if (!mounted || _isDisposed) return;
    setState(() {});
  }

  void _cancelTimers() {
    roundTimer?.cancel();
    progressTimer?.cancel();
  }

  Future<void> _playInstruction() async {
    if (!mounted || _isDisposed) return;
    await _gamesSuperKey.currentState
        ?.playNewChallengeSound(referenceItem);
  }

  Future<void> _generateNewChallenge() async {
    // sinal visual
    _gamesSuperKey.currentState?.playChallengeHighlight();
    if (!mounted || _isDisposed) return;

    // seleciona letra (retry ou nova)
    final retryId = _gamesSuperKey.currentState?.peekNextRetryTarget();
    final allChars = _characters.map((e) => e.character).toList();
    if (retryId != null) {
      targetCharacter = _gamesSuperKey.currentState!
          .safeRetry<String>(
            list: allChars, retryId: retryId,
            matcher: (c) => c.toLowerCase() == retryId.toLowerCase(),
            fallback: () => _gamesSuperKey.currentState!
                .safeSelectItem(
                  availableItems: allChars
                      .where((c) => !_usedCharacters.contains(c))
                      .toList(),
                ),
          );
    } else {
      targetCharacter = _gamesSuperKey.currentState!
          .safeSelectItem(
            availableItems: allChars
                .where((c) => !_usedCharacters.contains(c))
                .toList(),
          );
    }

    // marca como usada
    if (!_usedCharacters.contains(targetCharacter)) {
      _usedCharacters.add(targetCharacter);
    }

    // prepara áudio
    referenceItem = GameItem(
      id: targetCharacter,
      type: GameItemType.character,
      content: targetCharacter,
      dx: 0.0,                    
      dy: 0.0,                    
      backgroundColor: Colors.transparent,
      isCorrect: true,
    );

    // toca som após build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 50));
      if (!mounted || _isDisposed) return;
      await _gamesSuperKey.currentState
          ?.playNewChallengeSound(referenceItem);
    });

    // inicia cronômetro
    _cancelTimers();
    setState(() => isRoundActive = true);
    _startTime = DateTime.now();
    progressTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (t) {
        if (!mounted || _isDisposed) return t.cancel();
        final elapsed = DateTime.now().difference(_startTime!);
        final frac = elapsed.inMilliseconds / levelTime.inMilliseconds;
        setState(() {
          progressValue = (1.0 - frac).clamp(0.0, 1.0);
        });
      },
    );
    roundTimer = Timer(levelTime, () {
      if (!mounted || _isDisposed) return;
      setState(() => isRoundActive = false);
      _cancelTimers();
      _gamesSuperKey.currentState
          ?.registerFailedRound(targetCharacter);
      _gamesSuperKey.currentState?.showTimeout(
        applySettings: _applyLevelSettings,
        generateNewChallenge: _generateNewChallenge,
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    return GamesSuperWidget(
      key: _gamesSuperKey,
      user: widget.user,
      gameName: 'Escrever',
      progressValue: progressValue,
      level: (_) =>
          _gamesSuperKey.currentState?.levelManager.level ?? 1,
      currentRound: (_) => 1,
      totalRounds: (_) => 3,
      isFirstCycle: isFirstCycle,
      topTextContent: _buildTopText,
      onRepeatInstruction: _playInstruction,
      introImagePath: 'assets/images/games/write_game.webp',
      introAudioPath: 'sounds/games/write_game.ogg',
      onIntroFinished: () async {
        await _loadCharacters();
        await _applyLevelSettings();
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
        hasChallengeStarted
            ? 'Escreve a letra $targetCharacter'
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

  return Align(
    alignment: Alignment.bottomCenter,
    child: Padding(
      padding: EdgeInsets.only(bottom: 5.h), 
      child: SizedBox(
        width: 200.w,
        height: 200.h,
        child: TracingCharsGame(
          key: ValueKey(targetCharacter),
          showAnchor: true,
          traceShapeModel: [
            TraceCharsModel(chars: [
              TraceCharModel(
                char: targetCharacter,
                traceShapeOptions: const TraceShapeOptions(
                  innerPaintColor: Colors.orange,
                ),
              ),
            ]),
          ],
          onGameFinished: (_) async {
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

            await s.checkAnswerSingle(
              selectedItem: item,
              target: targetCharacter,
              retryId: targetCharacter,
              currentTry: currentTry,
              applySettings: _applyLevelSettings,
              generateNewChallenge: _generateNewChallenge,
              cancelTimers: _cancelTimers,
              showExtraFeedback: () async {
                item.isTapped = true;
                await Future.delayed(const Duration(seconds: 1));
              },
            );

            setState(() => currentTry++);
          },
        ),
      ),
    ),
  );
}
}

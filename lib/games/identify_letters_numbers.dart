// Estrutura do jogo 1: Ecrever letras e números

import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/user_model.dart';
import '../widgets/game_item.dart';
import '../widgets/game_super_widget.dart';

class IdentifyLettersNumbers extends StatefulWidget {
  final UserModel user;
  const IdentifyLettersNumbers({super.key, required this.user});

  @override
  State<IdentifyLettersNumbers> createState() => _IdentifyLettersNumbersState();
}

class _IdentifyLettersNumbersState extends State<IdentifyLettersNumbers> {
  final GlobalKey<GamesSuperWidgetState> _gamesSuperKey = GlobalKey();
  bool isRoundActive = true;

  final Random _random = Random();
  final List<String> characters = [
    ...'ABCDEFGHIJLMNOPQRSTUVXZ'.split(''),
    ...'abcdefghijlmnopqrstuvxz'.split(''),
    ...'0123456789'.split(''),
  ];

  int correctCount = 4;
  int wrongCount = 5;
  Duration levelTime = const Duration(seconds: 10);
  int currentTry = 0;
  int foundCorrect = 0;
  String targetCharacter = '';
  List<GameItem> gamesItems = [];
  Timer? roundTimer;
  Timer? progressTimer;
  double progressValue = 1.0;

  bool get isFirstCycle => widget.user.schoolLevel == '1º Ciclo';
  bool _isLetter(String char) => RegExp(r'[a-zA-Z]').hasMatch(char);
  bool _isNumber(String char) => RegExp(r'[0-9]').hasMatch(char);
  String _chooseRandomFont() => _random.nextBool() ? 'Slabo' : 'Cursive';
  Color _generateStrongColor() => [
    Colors.red, Colors.blue, Colors.green, Colors.purple,
    Colors.orange, Colors.pink, Colors.teal,
    Colors.indigo, Colors.deepPurple, Colors.cyan,
  ][_random.nextInt(10)];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await applyLevelSettings();
      generateNewChallenge();
    });
  }

  @override
  void dispose() {
    cancelTimers();
    super.dispose();
  }

  Future<void> applyLevelSettings() async {
    final superState = _gamesSuperKey.currentState;
    if (superState == null) return;

    final currentLevel = superState.levelManager.level;

    setState(() {
      switch (currentLevel) {
        case 1:
          correctCount = 4;
          wrongCount = 8;
          levelTime = const Duration(seconds: 10);
          break;
        case 2:
          correctCount = 5;
          wrongCount = 10;
          levelTime = const Duration(seconds: 15);
          break;
        case 3:
          correctCount = 6;
          wrongCount = 12;
          levelTime = const Duration(seconds: 20);
          break;
      }
    });
  }

  void cancelTimers() {
    roundTimer?.cancel();
    progressTimer?.cancel();
  }

  void generateNewChallenge() {
    if (!mounted) return;
    cancelTimers();

    setState(() {
      isRoundActive = true;
      gamesItems.clear();
      foundCorrect = 0;
      currentTry = 0;
      progressValue = 1.0;
    });

    final String rawChar = characters[_random.nextInt(characters.length)];
    targetCharacter = _isLetter(rawChar)
        ? (_random.nextBool() ? rawChar.toUpperCase() : rawChar.toLowerCase())
        : rawChar;

    final uniqueOptions = <String>{};
    while (uniqueOptions.length < wrongCount) {
      String c = characters[_random.nextInt(characters.length)];
      String option = _isLetter(c)
          ? (_random.nextBool() ? c.toUpperCase() : c.toLowerCase())
          : c;
      if (option.toLowerCase() != targetCharacter.toLowerCase()) {
        uniqueOptions.add(option);
      }
    }

    final correctOptions = List.generate(correctCount, (_) =>
        _random.nextBool() ? targetCharacter.toUpperCase() : targetCharacter.toLowerCase());

    final allOptions = [...uniqueOptions, ...correctOptions]..shuffle();
    final cols = (allOptions.length / 3).ceil();
    final spacingX = 1.0 / (cols + 1);
    final spacingY = 0.18;

    gamesItems = List.generate(allOptions.length, (i) {
      final col = i % cols;
      final row = i ~/ cols;
      final dx = spacingX * (col + 1);
      final dy = 0.45 + spacingY * row;

      return GameItem(
        id: i.toString(),
        type: GameItemType.character,
        content: allOptions[i],
        dx: dx,
        dy: dy,
        fontFamily: isFirstCycle ? _chooseRandomFont() : null,
        backgroundColor: _generateStrongColor(),
        isCorrect: allOptions[i].toLowerCase() == targetCharacter.toLowerCase(),
      );
    });

    setState(() {});

    progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) return timer.cancel();
      setState(() {
        progressValue -= 0.01;
        if (progressValue <= 0) timer.cancel();
      });
    });

    roundTimer = Timer(levelTime, () async {
      if (!mounted) return;
      setState(() => isRoundActive = false);

      final superState = _gamesSuperKey.currentState;
      superState?.showTimeout(
        applySettings: applyLevelSettings,
        generateNewChallenge: () {
          if (!mounted) return;
          generateNewChallenge();
        },
      );
    });
  }

  void handleTap(GameItem item) {
    if (!isRoundActive || item.isTapped) return;

    final superState = _gamesSuperKey.currentState;
    if (superState == null) return;

    setState(() {
      currentTry++;
      item.isTapped = true;
    });

    superState.checkAnswer(
      selectedItem: item,
      target: targetCharacter,
      correctCount: correctCount,
      currentTry: currentTry,
      foundCorrect: foundCorrect,
      applySettings: () async => await applyLevelSettings(),
      generateNewChallenge: () {
        if (!mounted) return;
        generateNewChallenge();
      },
      updateFoundCorrect: (int value) {
        setState(() => foundCorrect = value);
      },
      cancelTimers: cancelTimers,
    );
  }

 @override
  Widget build(BuildContext context) {
    return GamesSuperWidget(
      key: _gamesSuperKey,
      user: widget.user,
      progressValue: progressValue,
      level: (_) => _gamesSuperKey.currentState?.levelManager.level ?? 1,
      currentRound: (_) => 1,
      totalRounds: (_) => 3,
      isFirstCycle: isFirstCycle,
      topTextContent: () => Padding(
        padding: EdgeInsets.only(top: 16.h, bottom: 6.h),
        child: isFirstCycle && _isLetter(targetCharacter)
            ? Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'Encontra a letra '),
                    TextSpan(
                      text: targetCharacter.toUpperCase(),
                      style: TextStyle(fontFamily: 'Slabo', fontSize: 22.sp),
                    ),
                    const TextSpan(text: ', '),
                    TextSpan(
                      text: targetCharacter.toLowerCase(),
                      style: TextStyle(fontFamily: 'Cursive', fontSize: 22.sp),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              )
            : Text(
                _isNumber(targetCharacter)
                    ? "Encontra o número $targetCharacter"
                    : "Encontra a letra ${targetCharacter.toUpperCase()}, ${targetCharacter.toLowerCase()}",
                textAlign: TextAlign.center,
              ),
      ),
      builder: (context, levelManager, user) {
        return Stack(
          children: gamesItems.map((item) {
            return Align(
              alignment: Alignment(item.dx * 2 - 1, item.dy * 2 - 1),
              child: GestureDetector(
                onTap: () => handleTap(item),
                child: item.isTapped
                    ? (item.isCorrect
                        ? _gamesSuperKey.currentState!.correctIcon
                        : _gamesSuperKey.currentState!.wrongIcon)
                    : Container(
                        width: 60.r,
                        height: 60.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: item.backgroundColor,
                          boxShadow: [
                            BoxShadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 4.r),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          item.content,
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: item.fontFamily,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

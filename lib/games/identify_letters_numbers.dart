import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/level_manager.dart';
import '../widgets/games_animations.dart';
import '../widgets/games_design.dart';
import '../models/user_model.dart';
import '../widgets/game_item.dart';

// classe para o jogo de Identificar Letras e Números
class IdentifyLettersNumbersGame extends StatefulWidget {
  final UserModel user;
  const IdentifyLettersNumbersGame({super.key, required this.user});

  @override
  IdentifyLettersNumbersGameState createState() =>
      IdentifyLettersNumbersGameState();
}

// classe para o estado do jogo de Identificar Letras e Números
class IdentifyLettersNumbersGameState
    extends State<IdentifyLettersNumbersGame> {
  late LevelManager levelManager;
  bool isFirstCycle = false;
  bool showSuccessAnimation = false;

  final List<String> characters = [
    ...'ABCDEFGHIJLMNOPQRSTUVXZ'.split(''),
    ...'abcdefghijlmnopqrstuvxz'.split(''),
    ...'0123456789'.split(''),
  ];

  final Random _random = Random();
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

  @override
  void initState() {
    super.initState();
    isFirstCycle = widget.user.schoolLevel == '1º Ciclo';
    levelManager = LevelManager(user: widget.user);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      applyLevelSettings();
      generateNewChallenge();
    });
  }

  @override
  void dispose() {
    roundTimer?.cancel();
    progressTimer?.cancel();
    super.dispose();
  }

  Color _generateStrongColor() {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.teal,
      Colors.indigo,
      Colors.deepPurple,
      Colors.cyan,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  bool _isLetter(String char) => RegExp(r'[a-zA-Z]').hasMatch(char);
  bool _isNumber(String char) => RegExp(r'[0-9]').hasMatch(char);
  String _chooseRandomFont() => _random.nextBool() ? 'Slabo' : 'Cursive';

  void applyLevelSettings() {
    switch (levelManager.level) {
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
  }

  void generateNewChallenge() {
    setState(() {
      gamesItems.clear();
    });
    foundCorrect = 0;
    roundTimer?.cancel();
    progressTimer?.cancel();
    currentTry = 0;
    progressValue = 1.0;

    final String rawChar = characters[_random.nextInt(characters.length)];
    targetCharacter =
        _isLetter(rawChar)
            ? (_random.nextBool()
                ? rawChar.toUpperCase()
                : rawChar.toLowerCase())
            : rawChar;

    Set<String> uniqueOptions = {};
    while (uniqueOptions.length < wrongCount) {
      String c = characters[_random.nextInt(characters.length)];
      String option =
          _isLetter(c)
              ? (_random.nextBool() ? c.toUpperCase() : c.toLowerCase())
              : c;
      if (option.toLowerCase() != targetCharacter.toLowerCase() &&
          !uniqueOptions.any((e) => e.toLowerCase() == option.toLowerCase())) {
        uniqueOptions.add(option);
      }
    }

    List<String> correctOptions = List.generate(correctCount, (_) {
      return _random.nextBool()
          ? targetCharacter.toUpperCase()
          : targetCharacter.toLowerCase();
    });

    final allOptions = [...uniqueOptions, ...correctOptions]..shuffle();
    final cols = (allOptions.length / 3).ceil();
    final spacingX = 1.0 / (cols + 1);
    final spacingY = 0.18;

    List<GameItem> placedItems = [];

    for (int i = 0; i < allOptions.length; i++) {
      final col = i % cols;
      final row = i ~/ cols;
      final dx = spacingX * (col + 1);
      final dy = 0.45 + spacingY * row;

      placedItems.add(
        GameItem(
          id: i.toString(),
          type: GameItemType.character,
          content: allOptions[i],
          dx: dx,
          dy: dy,
          fontFamily: isFirstCycle ? _chooseRandomFont() : null,
          backgroundColor: _generateStrongColor(),
          isCorrect:
              allOptions[i].toLowerCase() == targetCharacter.toLowerCase(),
        ),
      );
    }

    setState(() {
      gamesItems = placedItems;
    });

    final int totalMillis = levelTime.inMilliseconds;
    const tick = Duration(milliseconds: 100);
    int elapsed = 0;

    progressTimer = Timer.periodic(tick, (timer) {
      if (showSuccessAnimation) return;
      setState(() {
        elapsed += tick.inMilliseconds;
        progressValue = 1.0 - (elapsed / totalMillis);
      });
      if (elapsed >= totalMillis) {
        timer.cancel();
      }
    });

    roundTimer = Timer(levelTime, () {
      if (showSuccessAnimation) return;
      GameAnimations.showTimeoutSnackbar(context);
      final bool firstTryCorrect = currentTry == correctCount;

      levelManager.registerRoundWithOptionalFeedback(
        context: context,
        correct: firstTryCorrect,
        applySettings: applyLevelSettings,
        onFinished: generateNewChallenge,
      );
    });
  }

  void checkAnswer(GameItem selectedItem) {
    currentTry++;

    if (selectedItem.content.toLowerCase() == targetCharacter.toLowerCase()) {
      foundCorrect++;
      setState(() {
        selectedItem.isCorrect = true;
        selectedItem.showCheck = true;
        selectedItem.isTapped = true;
      });

      GameAnimations.playCorrectSound();

      if (foundCorrect >= correctCount) {
        roundTimer?.cancel();
        progressTimer?.cancel();
        final bool firstTryCorrect = currentTry == correctCount;

        setState(() {
          showSuccessAnimation = true;
        });

        GameAnimations.successCoffetiesTimed();

        Future.delayed(const Duration(seconds: 1), () {
          if (!mounted) return;

          setState(() {
            showSuccessAnimation = false;
          });

          levelManager.registerRoundWithOptionalFeedback(
            context: context,
            correct: firstTryCorrect,
            applySettings: applyLevelSettings,
            onFinished: generateNewChallenge,
          );
        });
      }
    } else {
      GameAnimations.playWrongSound();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget topTextWidget = Padding(
      padding: EdgeInsets.only(top: 10.h, bottom: 6.h),
      child:
          isFirstCycle && _isLetter(targetCharacter)
              ? Column(
                children: [
                  Text(
                    'Encontra a letra',
                    style: getInstructionFont(isFirstCycle: isFirstCycle),
                  ),
                  CharacterFontVariants(character: targetCharacter),
                ],
              )
              : Text(
                _isNumber(targetCharacter)
                    ? 'Encontra o número $targetCharacter'
                    : 'Encontra a letra ${targetCharacter.toUpperCase()}, ${targetCharacter.toLowerCase()}',
                style: getInstructionFont(isFirstCycle: isFirstCycle),
                textAlign: TextAlign.center,
              ),
    );

    return GamesDesign(
      user: widget.user,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: GameAnimations.buildTopInfo(
              progressValue: progressValue,
              level: levelManager.level,
              currentRound: levelManager.totalRoundsCount + 1,
              totalRounds: levelManager.evaluationRounds,
              topTextWidget: topTextWidget,
            ),
          ),
          ...gamesItems.map((item) {
            return Align(
              alignment: Alignment(item.dx * 2 - 1, item.dy * 2 - 1),
              child:
                  item.isTapped
                      ? const Icon(Icons.check, color: Colors.green, size: 30)
                      : GestureDetector(
                        onTap: () => checkAnswer(item),
                        child: Container(
                          width: 60.r,
                          height: 60.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: item.backgroundColor,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                offset: Offset(2, 2),
                                blurRadius: 4.r,
                              ),
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
          }),
          if (showSuccessAnimation)
            IgnorePointer(
              ignoring: true,
              child: GameAnimations.successCoffetiesTimed(),
            ),
        ],
      ),
    );
  }
}

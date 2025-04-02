import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/level_manager.dart';
import '../widgets/games_animations.dart';
import '../models/user_model.dart';

class IdentifyLettersNumbersGame extends StatefulWidget {
  final UserModel user;

  const IdentifyLettersNumbersGame({super.key, required this.user});

  @override
  IdentifyLettersNumbersGameState createState() =>
      IdentifyLettersNumbersGameState();
}

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
  List<LetterItem> letterItems = [];

  Timer? roundTimer;
  Timer? progressTimer;
  double progressValue = 1.0;

  @override
  void initState() {
    super.initState();
    isFirstCycle = widget.user.level == '1º Ciclo';
    levelManager = LevelManager(user: widget.user);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      applyLevelSettings();
      generateNewChallenge();
    });
  }

  void applyLevelSettings() {
    switch (levelManager.level) {
      case 1:
        correctCount = 4;
        wrongCount = 5;
        levelTime = const Duration(seconds: 10);
        break;
      case 2:
        correctCount = 5;
        wrongCount = 8;
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

    final double minX = 0.05;
    final double maxX = 0.95;
    final double minY = 0.35;
    final double maxY = 0.85;

    final List<LetterItem> placedItems = [];
    final List<Offset> usedPositions = [];

    for (String char in allOptions) {
      double dx, dy;
      Offset pos;
      int attempts = 0;

      do {
        dx = _random.nextDouble() * (maxX - minX) + minX;
        dy = _random.nextDouble() * (maxY - minY) + minY;
        pos = Offset(dx, dy);
        attempts++;
        if (attempts > 100) break;
      } while (_overlaps(pos, usedPositions, 80.r));

      usedPositions.add(pos);
      placedItems.add(
        LetterItem(
          character: char,
          dx: dx,
          dy: dy,
          fontFamily: isFirstCycle ? _chooseRandomFont() : null,
        ),
      );
    }

    setState(() {
      letterItems = placedItems;
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tempo esgotado! ⏰',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(milliseconds: 400),
        ),
      );

      final bool firstTryCorrect = currentTry == correctCount;

      levelManager.registerRoundWithOptionalFeedback(
        context: context,
        correct: firstTryCorrect,
        applySettings: applyLevelSettings,
        onFinished: generateNewChallenge,
      );
    });
  }

  void checkAnswer(LetterItem selectedItem) {
    currentTry++;

    if (selectedItem.character.toLowerCase() == targetCharacter.toLowerCase()) {
      foundCorrect++;
      setState(() {
        letterItems.remove(selectedItem);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Correto! 🎉',
            style: TextStyle(
              fontSize: 16.sp,
              fontFamily: isFirstCycle ? 'Slabo' : null,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(milliseconds: 400),
        ),
      );

      if (foundCorrect >= correctCount) {
        roundTimer?.cancel();
        progressTimer?.cancel();
        final bool firstTryCorrect = currentTry == correctCount;

        setState(() {
          showSuccessAnimation = true;
        });

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tenta novamente!',
            style: TextStyle(
              fontSize: 16.sp,
              fontFamily: isFirstCycle ? 'Slabo' : null,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  bool _overlaps(Offset pos, List<Offset> others, double radius) {
    for (final other in others) {
      final dx = (pos.dx - other.dx) * 1.sw;
      final dy = (pos.dy - other.dy) * 1.sh;
      if (sqrt(dx * dx + dy * dy) < radius) return true;
    }
    return false;
  }

  bool _isLetter(String char) => RegExp(r'[a-zA-Z]').hasMatch(char);
  bool _isNumber(String char) => RegExp(r'[0-9]').hasMatch(char);
  String _chooseRandomFont() => _random.nextBool() ? 'Slabo' : 'Cursive';

  @override
  void dispose() {
    roundTimer?.cancel();
    progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget topTextWidget =
        isFirstCycle && _isLetter(targetCharacter)
            ? Column(
              children: [
                Text(
                  'Encontra a letra',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontFamily: 'Slabo',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      targetCharacter.toUpperCase(),
                      style: TextStyle(fontSize: 24.sp, fontFamily: 'Slabo'),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      targetCharacter.toUpperCase(),
                      style: TextStyle(fontSize: 24.sp, fontFamily: 'Cursive'),
                    ),
                    SizedBox(width: 16.w),
                    Text(
                      targetCharacter.toLowerCase(),
                      style: TextStyle(fontSize: 24.sp, fontFamily: 'Slabo'),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      targetCharacter.toLowerCase(),
                      style: TextStyle(fontSize: 24.sp, fontFamily: 'Cursive'),
                    ),
                  ],
                ),
              ],
            )
            : Text(
              _isNumber(targetCharacter)
                  ? 'Encontra o número $targetCharacter'
                  : 'Encontra a letra ${targetCharacter.toUpperCase()}, ${targetCharacter.toLowerCase()}',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                fontFamily: isFirstCycle ? 'Slabo' : null,
              ),
              textAlign: TextAlign.center,
            );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detetive de letras e números',
          style: TextStyle(fontSize: 18.sp, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 10.h),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      child: topTextWidget,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: LinearProgressIndicator(
                        value: progressValue,
                        minHeight: 8.h,
                        backgroundColor: Colors.grey[300],
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 20.h,
              right: 20.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Level ${levelManager.level}',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    'Round ${levelManager.totalRoundsCount + 1} of ${levelManager.evaluationRounds}',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            ...letterItems.map((item) {
              return Align(
                alignment: Alignment(item.dx * 2 - 1, item.dy * 2 - 1),
                child: TextButton(
                  onPressed: () => checkAnswer(item),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    item.character,
                    style: TextStyle(
                      fontSize: 30.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: item.fontFamily,
                    ),
                  ),
                ),
              );
            }),
            if (showSuccessAnimation)
              IgnorePointer(
                ignoring: true,
                child: Center(child: GameAnimations.successCoffetiesTimed()),
              ),
          ],
        ),
      ),
    );
  }
}

class LetterItem {
  final String character;
  final double dx;
  final double dy;
  final String? fontFamily;

  LetterItem({
    required this.character,
    required this.dx,
    required this.dy,
    this.fontFamily,
  });
}

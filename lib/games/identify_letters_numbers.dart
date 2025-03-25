// Estrutura principal do jogo "Detetive de letras e números"
import 'package:flutter/material.dart';
import 'dart:math';
import '../themes/text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';

class IdentifyLettersNumbersGame extends StatefulWidget {
  const IdentifyLettersNumbersGame({super.key});

  @override
  _IdentifyLettersNumbersGameState createState() =>
      _IdentifyLettersNumbersGameState();
}

class _IdentifyLettersNumbersGameState
    extends State<IdentifyLettersNumbersGame> {
  final List<String> characters = [
    ...'ABCDEFGHIJLMNOPQRSTUVXZ'.split(''),
    ...'abcdefghijlmnopqrstuvxz'.split(''),
    ...'0123456789'.split(''),
  ];

  final Random _random = Random();
  final double spacing = 10;

  int level = 1;
  int correctCount = 4;
  int wrongCount = 5;
  Duration levelTime = const Duration(seconds: 10);

  int totalRounds = 0;
  int firstTryCorrect = 0;
  int currentTry = 0;

  String targetCharacter = '';
  List<_LetterItem> letterItems = [];

  Timer? roundTimer;
  Timer? progressTimer;
  double progressValue = 1.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      applyLevelSettings();
      generateNewChallenge();
    });
  }

  void applyLevelSettings() {
    switch (level) {
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
      default:
        correctCount = 4;
        wrongCount = 5;
        levelTime = const Duration(seconds: 10);
    }
  }

  void generateNewChallenge() {
    foundCorrect = 0;
    double collisionRadius = 80.r;
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
    final double minY = 0.20;
    final double maxY = 0.85;

    final List<_LetterItem> placedItems = [];
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
      } while (_overlaps(pos, usedPositions, collisionRadius));

      usedPositions.add(pos);
      placedItems.add(_LetterItem(character: char, dx: dx, dy: dy));
    }

    setState(() {
      letterItems = placedItems;
    });

    // Iniciar temporizador visual da barra de progresso
    final int totalMillis = levelTime.inMilliseconds;
    const tick = Duration(milliseconds: 100);
    int elapsed = 0;

    progressTimer = Timer.periodic(tick, (timer) {
      setState(() {
        elapsed += tick.inMilliseconds;
        progressValue = 1.0 - (elapsed / totalMillis);
      });

      if (elapsed >= totalMillis) {
        timer.cancel();
      }
    });

    // Timer principal para encerrar a rodada
    roundTimer = Timer(levelTime, () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tempo esgotado! ⏰',
            style: AppTextStyles.body.copyWith(
              fontSize: 16.sp,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      _finishRound(firstTry: false);
    });
  }

  void _finishRound({required bool firstTry}) {
    roundTimer?.cancel();
    progressTimer?.cancel();
    totalRounds++;
    if (firstTry) firstTryCorrect++;

    if (totalRounds >= 4) {
      double accuracy = firstTryCorrect / totalRounds;
      if (accuracy >= 0.8 && level < 3) level++;
      if (accuracy < 0.5 && level > 1) level--;
      totalRounds = 0;
      firstTryCorrect = 0;
      applyLevelSettings();
    }

    generateNewChallenge();
  }

  bool _overlaps(Offset pos, List<Offset> others, double radius) {
    for (final other in others) {
      final dx = (pos.dx - other.dx) * MediaQuery.of(context).size.width;
      final dy = (pos.dy - other.dy) * MediaQuery.of(context).size.height;
      if (sqrt(dx * dx + dy * dy) < radius) return true;
    }
    return false;
  }

  bool _isLetter(String char) => RegExp(r'[a-zA-Z]').hasMatch(char);
  bool _isNumber(String char) => RegExp(r'[0-9]').hasMatch(char);

  int foundCorrect = 0; // Novo estado para contar os acertos na ronda

  void checkAnswer(_LetterItem selectedItem) {
    currentTry++;

    if (selectedItem.character.toLowerCase() == targetCharacter.toLowerCase()) {
      foundCorrect++;

      setState(() {
        letterItems.remove(selectedItem); // Remove só aquele!
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Correto! 🎉',
            style: AppTextStyles.body.copyWith(
              fontSize: 16.sp,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(milliseconds: 100),
        ),
      );

      if (foundCorrect >= correctCount) {
        _finishRound(firstTry: currentTry == correctCount);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tenta novamente!',
            style: AppTextStyles.body.copyWith(
              fontSize: 16.sp,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(milliseconds: 100),
        ),
      );
    }
  }

  @override
  void dispose() {
    roundTimer?.cancel();
    progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String topText =
        _isNumber(targetCharacter)
            ? 'Encontra o número $targetCharacter'
            : 'Encontra a letra ${targetCharacter.toUpperCase()}, ${targetCharacter.toLowerCase()}';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detetive de letras e números',
          style: AppTextStyles.body.copyWith(
            fontSize: 18.sp,
            color: Colors.white,
          ),
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
                      child: Text(
                        topText,
                        style: AppTextStyles.title.copyWith(fontSize: 24.sp),
                        textAlign: TextAlign.center,
                      ),
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
                    style: AppTextStyles.bodyBold.copyWith(fontSize: 30.sp),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class _LetterItem {
  final String character;
  final double dx;
  final double dy;

  _LetterItem({required this.character, required this.dx, required this.dy});
}

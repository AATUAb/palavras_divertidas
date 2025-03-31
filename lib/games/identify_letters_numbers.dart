// Versão atualizada com animação de sucesso
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/level_manager.dart';
import '../widgets/games_animations.dart';

class IdentifyLettersNumbersGame extends StatefulWidget {
  final String userLevel;

  const IdentifyLettersNumbersGame({super.key, required this.userLevel});

  @override
  _IdentifyLettersNumbersGameState createState() => _IdentifyLettersNumbersGameState();
}

class _IdentifyLettersNumbersGameState extends State<IdentifyLettersNumbersGame> {
  late LevelManager levelManager;
  late String userLevel;
  bool isPrimeiroCiclo = false;
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
  List<_LetterItem> letterItems = [];

  Timer? roundTimer;
  Timer? progressTimer;
  double progressValue = 1.0;

  @override
  void initState() {
    super.initState();
    isPrimeiroCiclo = widget.userLevel == '1º Ciclo';
    userLevel = widget.userLevel;
    levelManager = LevelManager();

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
    targetCharacter = _isLetter(rawChar)
        ? (_random.nextBool() ? rawChar.toUpperCase() : rawChar.toLowerCase())
        : rawChar;

    Set<String> uniqueOptions = {};
    while (uniqueOptions.length < wrongCount) {
      String c = characters[_random.nextInt(characters.length)];
      String option = _isLetter(c) ? (_random.nextBool() ? c.toUpperCase() : c.toLowerCase()) : c;
      if (option.toLowerCase() != targetCharacter.toLowerCase() &&
          !uniqueOptions.any((e) => e.toLowerCase() == option.toLowerCase())) {
        uniqueOptions.add(option);
      }
    }

    List<String> correctOptions = List.generate(correctCount, (_) {
      return _random.nextBool() ? targetCharacter.toUpperCase() : targetCharacter.toLowerCase();
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
      } while (_overlaps(pos, usedPositions, 80.r));

      usedPositions.add(pos);
      placedItems.add(
        _LetterItem(
          character: char,
          dx: dx,
          dy: dy,
          fontFamily: userLevel == '1º Ciclo' ? _chooseRandomFont() : null,
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
      if (showSuccessAnimation) return; // pausa temporizador se animação estiver ativa

      setState(() {
        elapsed += tick.inMilliseconds;
        progressValue = 1.0 - (elapsed / totalMillis);
      });
      if (elapsed >= totalMillis) {
        timer.cancel();
      }
    });

    roundTimer = Timer(levelTime, () {
      if (showSuccessAnimation) return; // ignora se animação estiver ativa

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tempo esgotado! ⏰',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(milliseconds: 400),
        ),
      );
      final bool acertouAPrimeira = currentTry == correctCount;

      levelManager.registerRoundWithOptionalFeedback(
        context: context,
        firstTry: acertouAPrimeira,
        applySettings: applyLevelSettings,
        onFinished: generateNewChallenge,
    );
    });
  }

  void _finishRound({required bool firstTry}) {
     roundTimer?.cancel();
    progressTimer?.cancel();
    levelManager.registerRound(firstTry: firstTry);
    applyLevelSettings();
    generateNewChallenge();
  }
    
void checkAnswer(_LetterItem selectedItem) {
  currentTry++;

  if (selectedItem.character.toLowerCase() == targetCharacter.toLowerCase()) {
    foundCorrect++;
    setState(() {
      letterItems.remove(selectedItem);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Correto! 🎉',
            style: TextStyle(
              fontSize: 16.sp,
              fontFamily: isPrimeiroCiclo ? 'Slabo' : null,
              fontWeight: FontWeight.bold,
              color: Colors.white)),
        backgroundColor: Colors.green,
        duration: const Duration(milliseconds: 400),
      ),
    );

    if (foundCorrect >= correctCount) {
      roundTimer?.cancel();
      progressTimer?.cancel();

      // Verifica se o utilizador acertou todos à primeira tentativa
      final bool acertouAPrimeira = currentTry == correctCount;
      roundTimer?.cancel();
      progressTimer?.cancel();

      setState(() {
        showSuccessAnimation = true;
      });

      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          showSuccessAnimation = false; // Mantém a animação de confetes
        });

        // Chama registerRoundWithOptionalFeedback para verificar e mostrar o diálogo de nível
        levelManager.registerRoundWithOptionalFeedback(
          context: context,
          firstTry: acertouAPrimeira,
          applySettings: applyLevelSettings,
          onFinished: generateNewChallenge,
        );
      });
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tenta novamente!',
            style: TextStyle(
              fontSize: 16.sp,
              fontFamily: isPrimeiroCiclo ? 'Slabo' : null,
              fontWeight: FontWeight.bold,
              color: Colors.white)),
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
    final Widget topTextWidget = isPrimeiroCiclo && _isLetter(targetCharacter)
        ? Column(
            children: [
              Text('Encontra a letra', style: TextStyle(fontSize: 20.sp, fontFamily: 'Slabo', fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(targetCharacter.toUpperCase(), style: TextStyle(fontSize: 24.sp, fontFamily: 'Slabo')),
                  SizedBox(width: 8.w),
                  Text(targetCharacter.toUpperCase(), style: TextStyle(fontSize: 24.sp, fontFamily: 'Cursive')),
                  SizedBox(width: 16.w),
                  Text(targetCharacter.toLowerCase(), style: TextStyle(fontSize: 24.sp, fontFamily: 'Slabo')),
                  SizedBox(width: 8.w),
                  Text(targetCharacter.toLowerCase(), style: TextStyle(fontSize: 24.sp, fontFamily: 'Cursive')),
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
              fontFamily: isPrimeiroCiclo ? 'Slabo' : null,
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
            }).toList(),

            if (showSuccessAnimation)
              IgnorePointer(
                ignoring: true,
                child: Center(
                  child: GameAnimations.successCoffetiesTimed(),
                ),
              ),
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
  final String? fontFamily;

  _LetterItem({
    required this.character,
    required this.dx,
    required this.dy,
    this.fontFamily,
  });
}

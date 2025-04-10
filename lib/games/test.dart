import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/level_manager.dart';
import '../widgets/games_animations.dart';
import '../models/user_model.dart';
import '../widgets/game_item.dart';
import '../widgets/games_super_widget.dart';
import '../widgets/conquest_book.dart';
import '../services/hive_service.dart';

class TestGame extends StatefulWidget {
  final UserModel user;
  const TestGame({super.key, required this.user});

  @override
  TestGameState createState() => TestGameState();
}

class TestGameState extends State<TestGame> {
  bool isFirstCycle = false;
  bool showSuccessAnimation = false;
  late LevelManager levelManager;
  bool showConquestAnimation = false; 

  final List<String> characters = [
    ...'ABCDEFGHIJLMNOPQRSTUVXZ'.split(''),
    ...'abcdefghijlmnopqrstuvxz'.split(''),
    ...'0123456789'.split(''),
  ];

  bool _isLetter(String char) => RegExp(r'[a-zA-Z]').hasMatch(char);
  bool _isNumber(String char) => RegExp(r'[0-9]').hasMatch(char);
  String _chooseRandomFont() => _random.nextBool() ? 'Slabo' : 'Cursive';

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

  @override
  void initState() {
    super.initState();
    isFirstCycle = widget.user.schoolLevel == '1º Ciclo';
    levelManager = LevelManager(user: widget.user);
  }

  @override
  void dispose() {
    roundTimer?.cancel();
    progressTimer?.cancel();
    super.dispose();
  }

  void applyLevelSettings(LevelManager levelManager) {
    switch (levelManager.level) {
      case 1:
        correctCount = 4;
        wrongCount = 8;
        levelTime = const Duration(seconds: 15);
        break;
      case 2:
        correctCount = 5;
        wrongCount = 10;
        levelTime = const Duration(seconds: 20);
        break;
      case 3:
        correctCount = 6;
        wrongCount = 12;
        levelTime = const Duration(seconds: 25);
        break;
    }
  }

  void generateNewChallenge(LevelManager levelManager) {
    setState(() => gamesItems.clear());
    foundCorrect = 0;
    roundTimer?.cancel();
    progressTimer?.cancel();
    currentTry = 0;
    progressValue = 1.0;

    final rawChar = characters[_random.nextInt(characters.length)];
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

    List<String> correctOptions = List.generate(
      correctCount,
      (_) =>
          _random.nextBool()
              ? targetCharacter.toUpperCase()
              : targetCharacter.toLowerCase(),
    );

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

    setState(() => gamesItems = placedItems);

    final int totalMillis = levelTime.inMilliseconds;
    const tick = Duration(milliseconds: 100);
    int elapsed = 0;

    progressTimer = Timer.periodic(tick, (timer) {
      if (showSuccessAnimation) return;
      setState(() {
        elapsed += tick.inMilliseconds;
        progressValue = 1.0 - (elapsed / totalMillis);
      });
      if (elapsed >= totalMillis) timer.cancel();
    });

    roundTimer = Timer(levelTime, () {
      if (showSuccessAnimation) return;
      GameAnimations.showTimeoutSnackbar(context);
      final firstTryCorrect = currentTry == correctCount;
      levelManager.registerRoundForLevel(
        context: context,
        correct: firstTryCorrect,
        applySettings: () => applyLevelSettings(levelManager),
        onFinished: () => generateNewChallenge(levelManager),
      );
    });
  }

  Future<void> checkAnswer(GameItem selectedItem, LevelManager levelManager) async {
  currentTry++;
  if (selectedItem.content.toLowerCase() == targetCharacter.toLowerCase()) {
    foundCorrect++;
    GameAnimations.playCorrectSound();
    setState(() {
      selectedItem.isTapped = true;
      selectedItem.isCorrect = true;
    });

    if (foundCorrect >= correctCount) {
      roundTimer?.cancel();
      progressTimer?.cancel();
      final firstTryCorrect = currentTry == correctCount;
      setState(() => showSuccessAnimation = true);
      GameAnimations.coffetiesTimed();

      // Aguardar 1 segundo para mostrar a animação de sucesso (se houver)
      await Future.delayed(const Duration(seconds: 1));

      setState(() => showSuccessAnimation = false);

      // Registrar a rodada
      levelManager.registerRoundForLevel(
        context: context,
        correct: firstTryCorrect,
        applySettings: () => applyLevelSettings(levelManager),
        onFinished: () {
          // Verificar se houve uma conquista
          final oldConquest = widget.user.conquest;

          // Verifica se houve uma conquista
          if (widget.user.conquest > oldConquest) {
            setState(() {
              showConquestAnimation = true; // Exibe animação de conquista
            });

            // Atualiza o número de conquistas no Hive
            final userKey = HiveService.getUserKey();
            HiveService.incrementConquests(userKey);  // Atualiza as conquistas no Hive

            // Ocultar animação de conquista após 1 segundo
            Future.delayed(const Duration(seconds: 1), () {
              setState(() {
                showConquestAnimation = false; // Ocultar animação de conquista
              });

              // Gera uma nova rodada após a animação de conquista
              generateNewChallenge(levelManager);
            });
          } else {
            // Se não houver conquista, apenas gera uma nova rodada
            generateNewChallenge(levelManager);
          }
        },
      );
    }
  } else {
    GameAnimations.playWrongSound();
    setState(() {
      selectedItem.isTapped = true;
      selectedItem.isCorrect = false;
    });
  }
}



  Widget buildGameItem(GameItem item) {
  return Align(
    alignment: Alignment(item.dx * 2 - 1, item.dy * 2 - 1),
    child: GestureDetector(
      onTap: () => checkAnswer(item, levelManager),
      child: Container(
        width: 60.r,
        height: 60.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: item.isTapped ? Colors.transparent : item.backgroundColor, // Torna o item invisível
          boxShadow: item.isTapped ? [] : [ // Remove a sombra quando desaparece
            BoxShadow(
              color: Colors.black26,
              offset: Offset(2, 2),
              blurRadius: 4.r,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: item.isTapped
            ? Icon(
                item.isCorrect ? Icons.check : Icons.close,
                color: item.isCorrect ? Colors.green : Colors.red,
                size: 32.sp,
              )
            : Text(
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
}


  @override
  Widget build(BuildContext context) {
    if (gamesItems.isEmpty) {
      applyLevelSettings(levelManager);
      generateNewChallenge(levelManager);
    }

    return GamesSuperWidget(
      user: widget.user,
      progressValue: progressValue,
      level: (_) => levelManager.level,
      currentRound: (_) => levelManager.totalRoundsCount + 1,
      totalRounds: (_) => levelManager.evaluationRounds,
      topTextContent:
          () => Padding(
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
          ),
      builder: (context, _, __) {
        return Stack(
          children: [
            ...gamesItems.map(buildGameItem),
            buildSuccessAnimation(showSuccessAnimation),
          ],
        );
      },
    );
  }
}

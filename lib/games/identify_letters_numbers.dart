import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/level_manager.dart';
import '../widgets/games_animations.dart';
import '../models/user_model.dart';
import '../widgets/game_item.dart';
import '../widgets/games_design.dart';
import 'package:audioplayers/audioplayers.dart';

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

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    isFirstCycle = widget.user.schoolLevel == '1º Ciclo';
    levelManager = LevelManager(
      user: widget.user,
      gameName: 'Detetive de letras e números',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _audioPlayer.stop();
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

    final rawChar = characters[_random.nextInt(characters.length)];
    targetCharacter =
        _isLetter(rawChar)
            ? (_random.nextBool()
                ? rawChar.toUpperCase()
                : rawChar.toLowerCase())
            : rawChar;

    final uniqueOptions = <String>{};
    while (uniqueOptions.length < wrongCount) {
      final c = characters[_random.nextInt(characters.length)];
      final option =
          _isLetter(c)
              ? (_random.nextBool() ? c.toUpperCase() : c.toLowerCase())
              : c;
      if (option.toLowerCase() != targetCharacter.toLowerCase() &&
          !uniqueOptions.any((e) => e.toLowerCase() == option.toLowerCase())) {
        uniqueOptions.add(option);
      }
    }

    final correctOptions = List.generate(correctCount, (_) {
      return _random.nextBool()
          ? targetCharacter.toUpperCase()
          : targetCharacter.toLowerCase();
    });

    final allOptions = [...uniqueOptions, ...correctOptions]..shuffle();

    // Novo cálculo para centralizar os balões
    final cols = (allOptions.length / 3).ceil();
    final spacingX = 1.0 / (cols + 1);
    final spacingY = 0.3; // Ajuste do espaçamento vertical

    final placedItems = <GameItem>[];
    for (int i = 0; i < allOptions.length; i++) {
      final col = i % cols;
      final row = i ~/ cols;
      final dx = spacingX * (col + 1);
      final dy = 0.10 + spacingY * row; // Ajuste para melhorar a centralização

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

    final totalMillis = levelTime.inMilliseconds;
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
      final bool firstTryCorrect = currentTry == correctCount;
      levelManager.registerRoundForLevel(
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
        Future.delayed(const Duration(seconds: 1), () {
          if (!mounted) return;
          setState(() => showSuccessAnimation = false);
          levelManager.registerRoundForLevel(
            context: context,
            correct: firstTryCorrect,
            applySettings: applyLevelSettings,
            onFinished: generateNewChallenge,
          );
        });
      }
    } else {
      GameAnimations.playWrongSound();
      setState(() {
        selectedItem.isTapped = true;
        selectedItem.isCorrect = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget topTextWidget = Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child:
          isFirstCycle && _isLetter(targetCharacter)
              ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Encontra a letra: ',
                    style: getInstructionFont(isFirstCycle: isFirstCycle),
                  ),
                  CharacterFontVariants(character: targetCharacter),
                ],
              )
              : Text(
                _isNumber(targetCharacter)
                    ? 'Encontra o número: $targetCharacter'
                    : 'Encontra a letra: ${targetCharacter.toUpperCase()}, ${targetCharacter.toLowerCase()}',
                style: getInstructionFont(isFirstCycle: isFirstCycle),
                textAlign: TextAlign.center,
              ),
    );

    return GamesDesign(
      user: widget.user,
      topTextWidget: topTextWidget,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: GameAnimations.buildTopInfo(
              progressValue: progressValue,
              level: levelManager.level,
              currentRound: levelManager.totalRoundsCount + 1,
              totalRounds: levelManager.evaluationRounds,
            ),
          ),
          ...gamesItems.map((item) {
            return Align(
              alignment: Alignment(item.dx * 2 - 1, item.dy * 2 - 1),
              child:
                  item.isTapped
                      ? Icon(
                        item.isCorrect ? Icons.check : Icons.close,
                        color: item.isCorrect ? Colors.green : Colors.red,
                        size: 32.sp,
                      )
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
              child: GameAnimations.coffetiesTimed(),
            ),
        ],
      ),
    );
  }
}

TextStyle getInstructionFont({required bool isFirstCycle}) {
  return TextStyle(
    fontSize: 22.sp,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    fontFamily: isFirstCycle ? 'ComicNeue' : null,
  );
}

class CharacterFontVariants extends StatelessWidget {
  final String character;

  const CharacterFontVariants({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          character.toUpperCase(),
          style: TextStyle(fontSize: 32.sp, fontFamily: 'Slabo'),
        ),
        SizedBox(width: 8.w),
        Text(
          character.toUpperCase(),
          style: TextStyle(fontSize: 32.sp, fontFamily: 'Cursive'),
        ),
        SizedBox(width: 16.w),
        Text(
          character.toLowerCase(),
          style: TextStyle(fontSize: 32.sp, fontFamily: 'Slabo'),
        ),
        SizedBox(width: 8.w),
        Text(
          character.toLowerCase(),
          style: TextStyle(fontSize: 32.sp, fontFamily: 'Cursive'),
        ),
      ],
    );
  }
}

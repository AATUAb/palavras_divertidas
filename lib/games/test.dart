import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/level_manager.dart';
import '../widgets/games_animations.dart';
import '../models/user_model.dart';
import '../widgets/game_item.dart';
import '../widgets/games_super_widget.dart';
// ConquestBook import is removed as the logic is now handled here
import '../services/hive_service.dart';
import 'package:logger/logger.dart';
import 'package:lottie/lottie.dart'; // Import Lottie

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
  bool _conquestAchievedThisRound = false; // Flag for conquest in the current round

  final logger = Logger(); // Logger instance

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
  _conquestAchievedThisRound = false; // Reset flag at the start of check

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
      GameAnimations.coffetiesTimed(); // Success animation

      // Short delay for success animation visibility
      await Future.delayed(const Duration(seconds: 1));
      setState(() => showSuccessAnimation = false);

      // --- Conquest Logic ---
      final userKey = HiveService.getUserKey(widget.user.key);
      if (userKey != -1) { // Check if user key is valid
        if (firstTryCorrect) {
          await HiveService.incrementFirstTrySuccesses(userKey);
          final updatedUser = HiveService.getUser(userKey);
          if (updatedUser != null && updatedUser.firstTrySuccesses >= 5) {
            logger.i("Conquest achieved (first try)! User: $userKey");
            _conquestAchievedThisRound = true;
            await HiveService.incrementConquests(userKey);
            await HiveService.resetFirstTrySuccesses(userKey);
          }
        } else {
          await HiveService.incrementOtherSuccesses(userKey);
          final updatedUser = HiveService.getUser(userKey);
          if (updatedUser != null && updatedUser.otherSuccesses >= 10) {
            logger.i("Conquest achieved (other try)! User: $userKey");
            _conquestAchievedThisRound = true;
            await HiveService.incrementConquests(userKey);
            await HiveService.resetOtherSuccesses(userKey);
          }
        }
      } else {
         logger.e("Could not find user key for conquest logic. User ID: ${widget.user.key}");
      }
      // --- End Conquest Logic ---


      // Register level progression
      levelManager.registerRoundForLevel(
        context: context,
        correct: firstTryCorrect,
        applySettings: () => applyLevelSettings(levelManager),
        onFinished: () { // Changed to synchronous if no async ops needed before check
          if (_conquestAchievedThisRound) {
            logger.i("Showing conquest animation for user $userKey");
            setState(() => showConquestAnimation = true);
            GameAnimations.playConquestSound(); // Play conquest sound

            // Delay for animation, then generate next challenge
            Future.delayed(const Duration(seconds: 3), () { // Increased delay for visibility
              setState(() => showConquestAnimation = false);
              generateNewChallenge(levelManager);
            });
          } else {
            // No conquest, generate next challenge immediately
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
            // Conditionally display success animation
            if (showSuccessAnimation) buildSuccessAnimation(true),
            // Conditionally display conquest animation
            if (showConquestAnimation)
              Center(
                child: Lottie.asset(
                  'assets/animations/conquest.json', // Path to your conquest animation
                  width: 200.r,
                  height: 200.r,
                  fit: BoxFit.contain,
                ),
              ),
          ],
        );
      },
    );
  }
}

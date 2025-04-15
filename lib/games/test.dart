import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/user_model.dart';
import '../widgets/game_item.dart';
import '../widgets/conquest_manager.dart';
import 'game_super_widget.dart';

class TestGame extends StatefulWidget {
  final UserModel user;
  const TestGame({super.key, required this.user});

  @override
  State<TestGame> createState() => _TestGameState();
}

class _TestGameState extends State<TestGame> {
  final GlobalKey<GamesSuperWidgetState> _gamesSuperKey = GlobalKey();

  late ConquestManager conquestManager;
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
    conquestManager = ConquestManager();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await applyLevelSettings();
      generateNewChallenge();
    });
  }

  @override
  void dispose() {
    print("🗑 TestGame dispose chamado");
    cancelTimers();
    super.dispose();
  }

  Future<void> applyLevelSettings() async {
    await Future.delayed(Duration.zero);

    final superState = _gamesSuperKey.currentState;
    if (superState == null) {
      print("⚠️ superState nulo em applyLevelSettings");
      return;
    }

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

      print("⚙️ [TestGame] applyLevelSettings chamado para o nível $currentLevel");
    });
  }

  void cancelTimers() {
    roundTimer?.cancel();
    progressTimer?.cancel();
    print("🛑 Temporizadores cancelados Jogo");
  }

  void generateNewChallenge() {
    if (!mounted) return;
    cancelTimers();

    setState(() {
      gamesItems.clear();
      foundCorrect = 0;
      currentTry = 0;
      progressValue = 1.0;
    });

    print("--- Novo desafio gerado ---");

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
      final superState = _gamesSuperKey.currentState;
      superState?.showTimeout(
        applySettings: applyLevelSettings,
        generateNewChallenge: () {
          if (mounted) generateNewChallenge();
        },
      );
    });
  }

  void handleTap(GameItem item) {
    if (item.isTapped) return;

    final superState = _gamesSuperKey.currentState;
    print("🔍 superState: $superState");
    if (superState == null) return;

    print("🖱 Toque registado em: ${item.content}");

    setState(() {
      currentTry++;
      item.isTapped = true;
    });

    print("📤 A chamar checkAnswer do superState...");

    superState.checkAnswer(
      selectedItem: item,
      target: targetCharacter,
      correctCount: correctCount,
      currentTry: currentTry,
      foundCorrect: foundCorrect,
      applySettings: () async {
        await applyLevelSettings();
      },
      generateNewChallenge: () {
        if (!mounted) return;
        generateNewChallenge();
      },
      conquestManager: conquestManager,
      updateFoundCorrect: (int value) {
        if (!mounted) return;
        print("✅ Atualizar foundCorrect: $value");
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
      topTextContent: () => Padding(
        padding: EdgeInsets.only(top: 16.h, bottom: 6.h),
        child: isFirstCycle && _isLetter(targetCharacter)
            ? Column(
                children: [
                  Text('Encontra a letra', style: getInstructionFont(isFirstCycle: isFirstCycle)),
                  CharacterFontVariants(character: targetCharacter),
                ],
              )
            : Text(
                _isNumber(targetCharacter)
                    ? "Encontra o número $targetCharacter"
                    : "Encontra a letra ${targetCharacter.toUpperCase()}, ${targetCharacter.toLowerCase()}",
                style: getInstructionFont(isFirstCycle: isFirstCycle),
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

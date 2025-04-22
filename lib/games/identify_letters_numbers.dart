// lib/games/identify_letters_numbers.dart

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:audioplayers/audioplayers.dart';

import '../models/user_model.dart';
import '../models/character_model.dart';
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
  final Random _random = Random();

  /* ───────────── helpers estáticos ───────────── */
  bool get isFirstCycle => widget.user.schoolLevel == '1º Ciclo';
  bool _isLetter(String c) => RegExp(r'[a-zA-Z]').hasMatch(c);
  bool _isNumber(String c) => RegExp(r'[0-9]').hasMatch(c);
  String _randFont() => _random.nextBool() ? 'Slabo' : 'Cursive';
  Color _randColor() =>
      [
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
      ][_random.nextInt(10)];

  /* ───────────── estado dinâmico ───────────── */
  late final AudioPlayer _introPlayer;
  late final AudioPlayer _letterPlayer;
  List<CharacterModel> _characters = [];
  bool isRoundActive = true;
  int correctCount = 4;
  int wrongCount = 5;
  Duration levelTime = const Duration(seconds: 10);
  int currentTry = 0;
  int foundCorrect = 0;
  String targetCharacter = '';
  List<GameItem> gamesItems = [];
  Timer? roundTimer, progressTimer;
  double progressValue = 1.0;

  /* ───────────── lifecycle ───────────── */
  @override
  void initState() {
    super.initState();

    _introPlayer = AudioPlayer();
    _letterPlayer = AudioPlayer();

    // 1️⃣ Toca apenas o áudio de introdução
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _introPlayer.play(
        AssetSource('sounds/detetive_letras_numeros.mp3'),
        volume: 0.6,
      );
    });

    // 2️⃣ Quando o áudio de introdução terminar, só aí carrega e inicia o jogo
    _introPlayer.onPlayerComplete.listen((_) async {
      // Carrega caracteres já seedados
      final box = Hive.box<CharacterModel>('characters');
      _characters = box.values.toList();

      // Aplica configurações de nível
      await _applyLevelSettings();

      // Gerar o primeiro desafio (e disparar o timer)
      _generateNewChallenge();
    });
  }

  @override
  void dispose() {
    _introPlayer.dispose();
    _letterPlayer.dispose();
    _cancelTimers();
    super.dispose();
  }

  /* ───────────── configuração de nível ───────────── */
  Future<void> _applyLevelSettings() async {
    final lvl = _gamesSuperKey.currentState?.levelManager.level ?? 1;
    switch (lvl) {
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
    setState(() {});
  }

  /* ───────────── timers helpers ───────────── */
  void _cancelTimers() {
    roundTimer?.cancel();
    progressTimer?.cancel();
  }

  /* ───────────── ciclo principal ───────────── */
  void _generateNewChallenge() {
    if (!mounted || _characters.isEmpty) return;
    _cancelTimers();

    setState(() {
      isRoundActive = true;
      gamesItems.clear();
      foundCorrect = 0;
      currentTry = 0;
      progressValue = 1.0;
    });

    final ch = _characters[_random.nextInt(_characters.length)].character;
    targetCharacter =
        _isLetter(ch)
            ? (_random.nextBool() ? ch.toUpperCase() : ch.toLowerCase())
            : ch;

    final uniqueOptions = <String>{};
    while (uniqueOptions.length < wrongCount) {
      var opt = _characters[_random.nextInt(_characters.length)].character;
      opt =
          _isLetter(opt)
              ? (_random.nextBool() ? opt.toUpperCase() : opt.toLowerCase())
              : opt;
      if (opt.toLowerCase() != targetCharacter.toLowerCase())
        uniqueOptions.add(opt);
    }

    final correctOptions = List.generate(
      correctCount,
      (_) =>
          _random.nextBool()
              ? targetCharacter.toUpperCase()
              : targetCharacter.toLowerCase(),
    );

    final all = [...uniqueOptions, ...correctOptions]..shuffle();
    final cols = (all.length / 3).ceil();
    final sx = 1.0 / (cols + 1), sy = 0.18;

    gamesItems = List.generate(all.length, (i) {
      final col = i % cols, row = i ~/ cols;
      return GameItem(
        id: i.toString(),
        type: GameItemType.character,
        content: all[i],
        dx: sx * (col + 1),
        dy: 0.45 + sy * row,
        fontFamily: isFirstCycle ? _randFont() : null,
        backgroundColor: _randColor(),
        isCorrect: all[i].toLowerCase() == targetCharacter.toLowerCase(),
      );
    });
    setState(() {});

    progressTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted) return;
      setState(() {
        progressValue -= 0.01;
      });
      if (progressValue <= 0) progressTimer?.cancel();
    });

    roundTimer = Timer(levelTime, () {
      if (!mounted) return;
      setState(() => isRoundActive = false);
      _gamesSuperKey.currentState?.showTimeout(
        applySettings: _applyLevelSettings,
        generateNewChallenge: _generateNewChallenge,
      );
    });
  }

  /* ───────────── interação ───────────── */
  void _handleTap(GameItem item) {
    if (!isRoundActive || item.isTapped) return;
    final state = _gamesSuperKey.currentState;
    if (state == null) return;

    setState(() {
      currentTry++;
      item.isTapped = true;
    });

    state.checkAnswer(
      selectedItem: item,
      target: targetCharacter,
      correctCount: correctCount,
      currentTry: currentTry,
      foundCorrect: foundCorrect,
      applySettings: _applyLevelSettings,
      generateNewChallenge: _generateNewChallenge,
      updateFoundCorrect: (v) => setState(() => foundCorrect = v),
      cancelTimers: _cancelTimers,
    );
  }

  /* ───────────── UI ───────────── */
  @override
  Widget build(BuildContext context) => GamesSuperWidget(
    key: _gamesSuperKey,
    user: widget.user,
    gameName: 'Detetive de letras e números',
    progressValue: progressValue,
    level: (_) => _gamesSuperKey.currentState?.levelManager.level ?? 1,
    currentRound: (_) => 1,
    totalRounds: (_) => 3,
    isFirstCycle: isFirstCycle,
    topTextContent: _buildTopText,
    builder: _buildBoard,
  );

  Widget _buildTopText() => Padding(
    padding: EdgeInsets.only(top: 16.h, bottom: 6.h),
    child:
        isFirstCycle && _isLetter(targetCharacter)
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
                  ? 'Encontra o número $targetCharacter'
                  : 'Encontra a letra ${targetCharacter.toUpperCase()}, '
                      '${targetCharacter.toLowerCase()}',
              textAlign: TextAlign.center,
            ),
  );

  Widget _buildBoard(BuildContext _, __, ___) => Stack(
    children:
        gamesItems.map((item) {
          return Align(
            alignment: Alignment(item.dx * 2 - 1, item.dy * 2 - 1),
            child: GestureDetector(
              onTap: () => _handleTap(item),
              child:
                  item.isTapped
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
                            BoxShadow(
                              color: Colors.black26,
                              offset: const Offset(2, 2),
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
        }).toList(),
  );
}

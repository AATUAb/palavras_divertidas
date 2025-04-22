// Estrutura do jogo "Identifica letras e números"
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
import '../widgets/game_sequence_manager.dart';

class IdentifyLettersNumbers extends StatefulWidget {
  final UserModel user;
  const IdentifyLettersNumbers({super.key, required this.user});

  @override
  State<IdentifyLettersNumbers> createState() => _IdentifyLettersNumbersState();
}

class _IdentifyLettersNumbersState extends State<IdentifyLettersNumbers> {
  final _gamesSuperKey = GlobalKey<GamesSuperWidgetState>();
  final _random = Random();

  late final AudioPlayer _introPlayer;
  late final AudioPlayer _letterPlayer;
  bool hasChallengeStarted = false;

  late CharacterSequenceManager _sequenceManager;
  List<CharacterModel> _characters = [];
  bool isRoundActive = true;
  int totalRounds = 3;
  int correctCount = 4;
  int wrongCount = 5;
  Duration levelTime = const Duration(seconds: 10);
  int currentTry = 0;
  int foundCorrect = 0;
  String targetCharacter = '';
  bool isRoundFinished = false;
  List<GameItem> gamesItems = [];
  Timer? roundTimer, progressTimer;
  double progressValue = 1.0;

  bool get isFirstCycle => widget.user.schoolLevel == '1º Ciclo';
  bool _isLetter(String c) => RegExp(r'[a-zA-Z]').hasMatch(c);
  bool _isNumber(String c) => RegExp(r'[0-9]').hasMatch(c);
  String _randFont() => _random.nextBool() ? 'Slabo' : 'Cursive';

  Color _randColor() =>
      [Colors.red, Colors.blue, Colors.green, Colors.purple, Colors.orange,
       Colors.pink, Colors.teal, Colors.indigo, Colors.deepPurple, Colors.cyan][
        _random.nextInt(10)
      ];

  @override
  void initState() {
    super.initState();
    _introPlayer = AudioPlayer();
    _letterPlayer = AudioPlayer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _introPlayer.play(
        AssetSource('sounds/identify_letters_numbers.mp3'),
        volume: 0.6,
      );

      _introPlayer.onPlayerComplete.listen((_) async {
        await _loadCharacters();
        await _applyLevelSettings();
        setState(() => hasChallengeStarted = true);
        _generateNewChallenge();
      });
    });
  }

  Future<void> _loadCharacters() async {
    final box = await Hive.openBox<CharacterModel>('characters');
    _characters = box.values.toList();
    final all = _characters.map((e) => e.character.toUpperCase()).toList();
    _sequenceManager = CharacterSequenceManager(all);
  }

  @override
  void dispose() {
    _introPlayer.dispose();
    _letterPlayer.dispose();
    _cancelTimers();
    super.dispose();
  }

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

  void _cancelTimers() {
    roundTimer?.cancel();
    progressTimer?.cancel();
  }

  Future<void> _reproduzirInstrucao() async {
    final file = 'sounds/characters_sounds/${targetCharacter.toUpperCase()}.mp3';
    try {
      await _letterPlayer.stop();
      await _letterPlayer.release();
      await _letterPlayer.play(AssetSource(file));
    } catch (e) {
      debugPrint('⚠️ Erro ao repetir som do carácter: $file');
    }
  }

  void _generateNewChallenge() async {
    if (!mounted || _sequenceManager.isFinished) {
      _showEndOfGameDialog();
      return;
    }

    _cancelTimers();
    setState(() {
      isRoundActive = true;
      gamesItems.clear();
      foundCorrect = 0;
      currentTry = 0;
      progressValue = 1.0;
    });

    final nextChars = _sequenceManager.takeNextForCustomChallenge(letters: 4, numbers: 1);
    if (nextChars.isEmpty) {
      _showEndOfGameDialog();
      return;
    }

    targetCharacter = nextChars.first;

    final bad = <String>{};
    while (bad.length < wrongCount) {
      final c = _characters[_random.nextInt(_characters.length)].character;
      final opt = _random.nextBool() ? c.toUpperCase() : c.toLowerCase();
      if (opt.toLowerCase() != targetCharacter.toLowerCase()) {
        bad.add(opt);
      }
    }

    final good = List.generate(correctCount, (_) {
      return _random.nextBool()
          ? targetCharacter.toUpperCase()
          : targetCharacter.toLowerCase();
    });
    final all = [...bad, ...good]..shuffle();

    final cols = (all.length / 3).ceil(), sx = 1 / (cols + 1), sy = 0.18;
    gamesItems = List.generate(all.length, (i) {
      final col = i % cols, row = i ~/ cols;
      return GameItem(
        id: '$i',
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

    await _reproduzirInstrucao();

    progressTimer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      if (!mounted) return t.cancel();
      setState(() {
        progressValue -= 0.01;
        if (progressValue <= 0) t.cancel();
      });
    });

    roundTimer = Timer(levelTime, () {
      if (!mounted) return;
      setState(() => isRoundActive = false);
      _sequenceManager.registerFailure(targetCharacter);
      _gamesSuperKey.currentState?.showTimeout(
        applySettings: _applyLevelSettings,
        generateNewChallenge: _generateNewChallenge,
      );
    });
  }

  void _showEndOfGameDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fim do jogo'),
        content: const Text('Chegaste ao fim do jogo! Queres jogar novamente?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _sequenceManager.reset();
              _generateNewChallenge();
            },
            child: const Text('Sim'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Não'),
          ),
        ],
      ),
    );
  }

  void _handleTap(GameItem item) {
    if (!isRoundActive || item.isTapped) return;
    final s = _gamesSuperKey.currentState;
    if (s == null) return;

    setState(() {
      currentTry++;
      item.isTapped = true;
    });

    s.checkAnswer(
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

  @override
  Widget build(BuildContext context) {
    return GamesSuperWidget(
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
      onRepeatInstruction: _reproduzirInstrucao,
    );
  }

  Widget _buildTopText() => hasChallengeStarted
      ? Padding(
          padding: EdgeInsets.only(top: 20.h, left: 16.w, right: 16.w),
          child: _buildChallengeText(),
        )
      : Padding(
          padding: EdgeInsets.only(top: 24.h, left: 16.w, right: 16.w),
          child: Text(
            'És um detetive de letras e números! Encontra todas as letras e números.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        );

  Widget _buildChallengeText() {
    if (isFirstCycle && _isLetter(targetCharacter)) {
      return Text.rich(
        TextSpan(
          children: [
            const TextSpan(text: 'Encontra as letras '),
            TextSpan(
              text: '${targetCharacter.toUpperCase()}, ${targetCharacter.toLowerCase()}',
              style: TextStyle(fontFamily: 'Slabo', fontSize: 22.sp),
            ),
            const TextSpan(text: ', '),
            TextSpan(
              text: '${targetCharacter.toUpperCase()}, ${targetCharacter.toLowerCase()}',
              style: TextStyle(fontFamily: 'Cursive', fontSize: 23.sp),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      );
    } else {
      return Text(
        _isNumber(targetCharacter)
            ? 'Encontra os números $targetCharacter'
            : 'Encontra as letras ${targetCharacter.toUpperCase()}, ${targetCharacter.toLowerCase()}',
        textAlign: TextAlign.center,
      );
    }
  }

  Widget _buildBoard(BuildContext _, __, ___) => Stack(
    children: [
      if (!hasChallengeStarted)
        Positioned(
          top: 60.h, 
          left: 0,
          right: 0,
          child: Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 250.w,
              height: 180.h,
              child: Image.asset(
                'assets/images/identify_letters_numbers.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ...gamesItems.map((item) {
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
                        ),
                      ),
                    ),
          ),
        );
      }).toList(),
    ],
  );
}
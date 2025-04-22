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

// Classe do jogo "Identifica letras e números"
class IdentifyLettersNumbers extends StatefulWidget {
  final UserModel user;
  const IdentifyLettersNumbers({super.key, required this.user});

  // Define o nome do jogo
  @override
  State<IdentifyLettersNumbers> createState() => _IdentifyLettersNumbersState();
}

// Classe que controla o estado do jogo
class _IdentifyLettersNumbersState extends State<IdentifyLettersNumbers> {
  final _gamesSuperKey = GlobalKey<GamesSuperWidgetState>();
  final _random = Random();
  late final AudioPlayer _letterPlayer;
  bool hasChallengeStarted = false;
  late int correctCount;
  late int wrongCount;
  late Duration levelTime;
  late int currentTry;
  late int foundCorrect;

  // Lista de caracteres disponíveis para o jogo, que são carregados do Hive
  List<CharacterModel> _characters = [];
  // Lista de caracteres já utilizados no jogo, para evitar repetições
  List<String> _usedCharacters = [];

  bool isRoundActive = true;     // Indica se a ronda atual está ativa
  String targetCharacter = '';  // Carácter alvo a encontrar
  bool isRoundFinished = false;  // Indica se a ronda atual terminou
  List<GameItem> gamesItems = [];  // Lista de itens do jogo (letras, números a usar na grelha de jogo)
  Timer? roundTimer, progressTimer;  // Timers para controlar o tempo da ronda e o progresso
  double progressValue = 1.0;  // Valor do progresso da ronda, de 0 (tempo esgotado) a 1 (tempo total)

  bool get isFirstCycle => widget.user.schoolLevel == '1º Ciclo';  // Verifica se o utilizador está no 1º ciclo de ensino
  bool _isLetter(String c) => RegExp(r'[a-zA-Z]').hasMatch(c);     // Verifica se o carácter é uma letra
  bool _isNumber(String c) => RegExp(r'[0-9]').hasMatch(c);        // Verifica se o carácter é um número
  String _randFont() => _random.nextBool() ? 'Slabo' : 'Cursive';  // Seleciona aleatoriamente uma fonte entre Slabo e Cursive

  // Cores a aplicar aleatoriamente aos itens do jogo
  Color _randColor() =>
      [Colors.red, Colors.blue, Colors.green, Colors.purple, Colors.orange,
       Colors.pink, Colors.teal, Colors.indigo, Colors.deepPurple, Colors.cyan][
        _random.nextInt(10)
      ];

  // Inicializa o estado do jogo
  @override
  void initState() {
    super.initState();
    _letterPlayer = AudioPlayer();
  }

  // Carrega os caracteres do Hive, que são utilizados no jogo
  Future<void> _loadCharacters() async {
    final box = await Hive.openBox<CharacterModel>('characters');
    _characters = box.values.toList();
  }

  // Libera os recursos utilizados pelo áudio e cancela os timers ao sair do jogo
  @override
  void dispose() {
    _letterPlayer.dispose();
    _cancelTimers();
    super.dispose();
  }

  // Aplica as definições de nível do jogo, como o número de tentativas corretas e erradas, e o tempo da ronda
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

  // Cancela os timers de ronda e progresso
  void _cancelTimers() {
    roundTimer?.cancel();
    progressTimer?.cancel();
  }

  // Reproduz o som da instrução de desafio, que indica qual o carácter a encontrar
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

  // Gera um novo desafio, escolhe um  carácter alvo e cria as opções de resposta
  // Se não houver mais caracteres disponíveis, termina o jogo e pergunta se o utilizador quer jogar novamente
  Future<void> _generateNewChallenge() async {
    final allChars = _characters.map((e) => e.character.toUpperCase()).toList();
    final availableChars = allChars.where((c) => !_usedCharacters.contains(c)).toList();

    if (availableChars.isEmpty) {
      _showEndOfGameDialog();
      return;
    }

    final target = availableChars[_random.nextInt(availableChars.length)];
    _usedCharacters.add(target);

    _cancelTimers();
    setState(() {
      isRoundActive = true;
      gamesItems.clear();
      foundCorrect = 0;
      currentTry = 0;
      progressValue = 1.0;
      targetCharacter = target;
    });

    final bad = <String>{};
    while (bad.length < wrongCount) {
      final c = _characters[_random.nextInt(_characters.length)].character;
      final opt = _random.nextBool() ? c.toUpperCase() : c.toLowerCase();
      if (opt.toLowerCase() != target.toLowerCase()) {
        bad.add(opt);
      }
    }

    final good = List.generate(correctCount, (_) {
      return _random.nextBool()
          ? target.toUpperCase()
          : target.toLowerCase();
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
        isCorrect: all[i].toLowerCase() == target.toLowerCase(),
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
        content: const Text('Queres jogar novamente?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() => _usedCharacters.clear());
              _generateNewChallenge();
            },
            child: const Text('Sim'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).maybePop();
            },
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
      target: targetCharacter.toLowerCase(),
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
      introImagePath: 'assets/images/identify_letters_numbers.png',
      introAudioPath: 'sounds/identify_letters_numbers.mp3',
      onIntroFinished: () async {
        await _loadCharacters();
        await _applyLevelSettings();
        if (mounted) {
          setState(() => hasChallengeStarted = true);
          _generateNewChallenge();
        }
      },
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

  /// Constrói o tabuleiro do jogo
  Widget _buildBoard(BuildContext _, __, ___) => Stack(
    children: [
      ...gamesItems.map((item) {
        return Align(
          alignment: Alignment(item.dx * 2 - 1, item.dy * 2 - 1),
          child: GestureDetector(
            onTap: () => _handleTap(item),
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

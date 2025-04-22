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

// Classe principal do jogo "Identifica letras e números"
class IdentifyLettersNumbers extends StatefulWidget {
  final UserModel user;
  const IdentifyLettersNumbers({super.key, required this.user});

  // Método para criar o estado do jogo
  @override
  State<IdentifyLettersNumbers> createState() => _IdentifyLettersNumbersState();
}

// Classe que faz a gestão do estado do jogo
class _IdentifyLettersNumbersState extends State<IdentifyLettersNumbers> {
  final _gamesSuperKey = GlobalKey<GamesSuperWidgetState>();
  final _random = Random();

  late final AudioPlayer _introPlayer;
  late final AudioPlayer _letterPlayer;
  bool hasChallengeStarted = false;

  List<CharacterModel> _characters = [];  // Lista de caracteres
  bool isRoundActive = true;              // Indica se o desafio está ativo
  int totalRounds = 3;                   // Número total de rondas      
  int correctCount = 4;                 // Número de respostas corretas
  int wrongCount = 5;                  // Número de respostas erradas
  Duration levelTime = const Duration(seconds: 10);      // Tempo de cada ronda
  int currentTry = 0;                  // Tentativas atuais do utilizador
  int foundCorrect = 0;                // Número de respostas corretas encontradas
  String targetCharacter = '';          // Carácter alvo a ser encontrado
  bool isRoundFinished = false;         // Indica se a ronda terminou     
  List<GameItem> gamesItems = [];        // Lista de itens do jogo
  Timer? roundTimer, progressTimer;                               // Temporizadores para a ronda e progresso
  double progressValue = 1.0;                                    // Valor do progresso da ronda 

  bool get isFirstCycle => widget.user.schoolLevel == '1º Ciclo';
  bool _isLetter(String c) => RegExp(r'[a-zA-Z]').hasMatch(c);
  bool _isNumber(String c) => RegExp(r'[0-9]').hasMatch(c);
  String _randFont() => _random.nextBool() ? 'Slabo' : 'Cursive';

  // Cores para os circulos que contêm as letras e números
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

  // Método que inicializa o estado do jogo
  @override
  void initState() {
    super.initState();
    _introPlayer = AudioPlayer();
    _letterPlayer = AudioPlayer();

    // 
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

  // Método que carrega os caracteres da base de dados Hive
  Future<void> _loadCharacters() async {
    final box = await Hive.openBox<CharacterModel>('characters');
    _characters = box.values.toList();
  }

  // Método que limpa os recursos utilizados pelo jogo e cancela os temporizadores
  @override
  void dispose() {
    _introPlayer.dispose();
    _letterPlayer.dispose();
    _cancelTimers();
    super.dispose();
  }

  // Método que aplica as definições de nível a este jogo especifico
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

  // Método que cancela os temporizadores do jogo
  void _cancelTimers() {
    roundTimer?.cancel();
    progressTimer?.cancel();
  }

  // Método que toca o som da instrução atual
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

  // Método que gera um novo desafio
  void _generateNewChallenge() async {
    if (!mounted || _characters.isEmpty) return;
    _cancelTimers();

    setState(() {
      isRoundActive = true;
      gamesItems.clear();
      foundCorrect = 0;
      currentTry = 0;
      progressValue = 1.0;
    });

    final raw = _characters[_random.nextInt(_characters.length)].character;
    targetCharacter =
        _isLetter(raw)
            ? (_random.nextBool() ? raw.toUpperCase() : raw.toLowerCase())
            : raw;

    final bad = <String>{};
    while (bad.length < wrongCount) {
      final c = _characters[_random.nextInt(_characters.length)].character;
      final opt =
          _isLetter(c)
              ? (_random.nextBool() ? c.toUpperCase() : c.toLowerCase())
              : c;
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
      _gamesSuperKey.currentState?.showTimeout(
        applySettings: _applyLevelSettings,
        generateNewChallenge: _generateNewChallenge,
      );
    });
  }

  // Método que lida com o toque do utilizador nos itens do jogo
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

  // Método que toca o som de feedback quando o utilizador acerta ou erra
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

  // Método que constrói o texto do topo do jogo quando o desafio ainda não começou
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

  // Método que constrói o texto de cada desafio
  Widget _buildChallengeText() {
    if (isFirstCycle && _isLetter(targetCharacter)) {
      return Text.rich(
        TextSpan(
          children: [
            const TextSpan(text: 'Encontra a letra '),
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
            ? 'Encontra o número $targetCharacter'
            : 'Encontra a letra ${targetCharacter.toUpperCase()}, ${targetCharacter.toLowerCase()}',
        textAlign: TextAlign.center,
      );
    }
  }

  // Método que constrói a grelha de jogo
  Widget _buildBoard(BuildContext _, __, ___) => Stack(
    children: [
      // Imagem de introdução, antes do desafio começar
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
      // Itens do jogo, quando o desafio começa
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
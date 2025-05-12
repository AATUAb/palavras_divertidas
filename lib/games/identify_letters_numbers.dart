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

// Classe principal do jogo, que recebe o utilizador como argumento
class IdentifyLettersNumbers extends StatefulWidget {
  final UserModel user;
  const IdentifyLettersNumbers({super.key, required this.user});

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

  List<CharacterModel> _characters = [];
  List<String> _usedCharacters = [];
  String targetCharacter = '';

  bool isRoundActive = true;
  bool isRoundFinished = false;
  List<GameItem> gamesItems = [];
  Timer? roundTimer, progressTimer;
  late DateTime _startTime;
  double progress = 0.0;
  double progressValue = 1.0;

  bool get isFirstCycle => widget.user.schoolLevel == '1º Ciclo';
  bool _isLetter(String c) => RegExp(r'[a-zA-Z]').hasMatch(c);
  bool _isNumber(String c) => RegExp(r'[0-9]').hasMatch(c);
  String _randFont() => _random.nextBool() ? 'Slabo' : 'Cursive';

  Color _randColor() =>
      [Colors.red, Colors.blue, Colors.green, Colors.purple, Colors.orange, Colors.pink, Colors.teal, Colors.indigo, Colors.deepPurple, Colors.cyan][_random.nextInt(10)];

  // Inicializa o estado do jogo
  @override
  void initState() {
    super.initState();
    _letterPlayer = AudioPlayer();
  }

  // Carrega as palavras do banco de dados Hive
  Future<void> _loadCharacters() async {
    final box = await Hive.openBox<CharacterModel>('characters');
    _characters = box.values.toList();
  }

  // Fecha o player de áudio e cancela os temporizadores
  @override
  void dispose() {
    _letterPlayer.dispose();
    _cancelTimers();
    super.dispose();
  }

    // Aplica as definições de nível com base no nível atual do jogador
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

    // Cancela os temporizadores ativos
  void _cancelTimers() {
    roundTimer?.cancel();
    progressTimer?.cancel();
  }

  // Reproduz a instrução de áudio para o jogador
  Future<void> _reproduzirInstrucao() async {
    final file = 'sounds/words_characters/${targetCharacter.toUpperCase()}.ogg';
    await _letterPlayer.stop();
    await _letterPlayer.release();
    await _letterPlayer.play(AssetSource(file));
  }

  // Função que controla o comportamento do jogo quando o jogador termina o jogo e que reinicar o mesmo jogo
  void _restartGame() async {
    _gamesSuperKey.currentState?.levelManager.level = 1;
    setState(() {
      _usedCharacters.clear();
      hasChallengeStarted = true;
      progressValue = 1.0;
    });
    await _applyLevelSettings();
    _generateNewChallenge();
  }

  // Verifica se o caractere já foi utilizado na ronda atual, para controlar a repetição
  bool retryIsUsed(String value) => _usedCharacters.contains(value);

  // Gera um novo desafio, com base nas definições de nível e no estado atual do jogo
 Future<void> _generateNewChallenge() async {
    _gamesSuperKey.currentState?.registerCompletedRound(targetCharacter);
    final retry = _gamesSuperKey.currentState?.peekNextRetryTarget();
    final allChars = _characters.map((e) => e.character.toUpperCase()).toList();
    final availableChars = allChars.where((c) => !_usedCharacters.contains(c)).toList();
    if (availableChars.isEmpty && retry == null) {
      _gamesSuperKey.currentState?.showEndOfGameDialog(onRestart: _restartGame);
      return;
    }
    
    // Seleciona o caracter-alvo aleatoriamente ou da fila de repetição
    final target = retry ?? availableChars[_random.nextInt(availableChars.length)];
    if (!retryIsUsed(target)) _usedCharacters.add(target);
    _gamesSuperKey.currentState?.removeFromRetryQueue(target);

    // Se a palavra volta a ser apresentado, remove-o da fila de repetição
  // e adiciona-o à lista de palavras já utilizados
    _cancelTimers();
    setState(() {
      isRoundActive = true;
      gamesItems.clear();
      foundCorrect = 0;
      currentTry = 0;
      progressValue = 1.0;
      targetCharacter = target;
    });

    // Geração das opções de resposta
    final bad = <String>{};
    while (bad.length < wrongCount) {
      final c = _characters[_random.nextInt(_characters.length)].character;
      final opt = _random.nextBool() ? c.toUpperCase() : c.toLowerCase();
      if (opt.toLowerCase() != target.toLowerCase()) bad.add(opt);
    }

    final good = List.generate(correctCount, (_) => _random.nextBool() ? target.toUpperCase() : target.toLowerCase());
    final all = [...bad, ...good]..shuffle();
    final cols = (all.length / 3).ceil(), sx = 1 / (cols + 1), sy = 0.18;

    gamesItems = List.generate(all.length, (i) {
      final col = i % cols, row = i ~/ cols;
      final content = all[i];
      final isCorrect = content.toLowerCase() == target.toLowerCase();
      return GameItem(
        id: '$i',
        type: GameItemType.character,
        content: content,
        dx: sx * (col + 1),
        dy: 0.45 + sy * row,
        fontFamily: isFirstCycle ? _randFont() : null,
        backgroundColor: _randColor(),
        isCorrect: isCorrect,
      );
    });

    final referenceItem = gamesItems.firstWhere(
      (item) => item.isCorrect,
      orElse: () => GameItem(
        id: 'preview',
        type: GameItemType.character,
        content: target,
        dx: 0,
        dy: 0,
        backgroundColor: Colors.transparent,
      ),
    );

    // Solicita ao super widget a reprodução do som do desafio
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 50));
      await _gamesSuperKey.currentState?.playNewChallengeSound(referenceItem);
    });

    // Inicia temporizadores
    _startTime = DateTime.now();
    progressTimer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      if (!mounted) return t.cancel();

  final elapsed = DateTime.now().difference(_startTime);
  final fraction = elapsed.inMilliseconds / levelTime.inMilliseconds;

  setState(() {
    progressValue = 1.0 - fraction;
    if (progressValue <= 0) t.cancel();
  });
});


    roundTimer = Timer(levelTime, () {
      if (!mounted) return;
      setState(() => isRoundActive = false);
      _cancelTimers();
      _gamesSuperKey.currentState?.registerFailedRound(targetCharacter);
      _gamesSuperKey.currentState?.showTimeout(
        applySettings: _applyLevelSettings,
        generateNewChallenge: _generateNewChallenge,
      );
    });
  }


   // Lida com o toque do jogador num item do jogo
  void _handleTap(GameItem item) async {
    if (!isRoundActive || item.isTapped) return;
    final s = _gamesSuperKey.currentState;
    if (s == null) return;

    setState(() {
      currentTry++;
      item.isTapped = true;
    });

    // Marca uma ronda como terminada e cancela os temporizadores
    void _markRoundAsFinished() {
      setState(() => isRoundActive = false);
      _cancelTimers();
    }

    // Delega validação ao super widget, mas com callback local
    s.checkAnswerMultiple(
      selectedItem: item,
      target: targetCharacter,
      retryId: item.id,
      correctCount: correctCount,
      currentTry: currentTry,
      foundCorrect: foundCorrect,
      applySettings: _applyLevelSettings,
      generateNewChallenge: _generateNewChallenge,
      updateFoundCorrect: (v) => setState(() => foundCorrect = v),
      cancelTimers: _cancelTimers,
       markRoundFinished: _markRoundAsFinished,
    );
  }

  // Constrói o widget principal do jogo
  @override
  Widget build(BuildContext context) {
    return GamesSuperWidget(
      key: _gamesSuperKey,
      user: widget.user,
      gameName: 'Identificar de letras e números',
      progressValue: progressValue,
      level: (_) => _gamesSuperKey.currentState?.levelManager.level ?? 1,
      currentRound: (_) => 1,
      totalRounds: (_) => 3,
      isFirstCycle: isFirstCycle,
      topTextContent: _buildTopText,
      builder: _buildBoard,
      onRepeatInstruction: _reproduzirInstrucao,
      introImagePath: 'assets/images/games/identify_letters_numbers.webp',
      introAudioPath: 'sounds/games/identify_letters_numbers.ogg',
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

      // Constrói o texto superior do jogo, que é apresenado quando o jogo arranca
  Widget _buildTopText() {
    final font = getFontFamily(isFirstCycle ? FontStrategy.slabo : FontStrategy.none);
    return Padding(
      padding: EdgeInsets.only(top: 19.h, left: 16.w, right: 16.w),
      child: hasChallengeStarted ? _buildChallengeText() : Text(
        'Vamos encontrar todas as letras e números',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: font,
          fontSize: 25.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

      // Constrói o texto do desafio, que apresenta o palavra alvo a encontrar
  Widget _buildChallengeText() {
    final font = getFontFamily(isFirstCycle ? FontStrategy.slabo : FontStrategy.none);
    if (isFirstCycle && _isLetter(targetCharacter)) {
      return Text.rich(
        TextSpan(children: [
          const TextSpan(text: 'Encontra as letras '),
          TextSpan(
            text: '${targetCharacter.toUpperCase()}, ${targetCharacter.toLowerCase()}',
            style: TextStyle(fontFamily: font, fontSize: 22.sp),
          ),
          const TextSpan(text: ', '),
          TextSpan(
            text: '${targetCharacter.toUpperCase()}, ${targetCharacter.toLowerCase()}',
            style: TextStyle(fontFamily: font, fontSize: 23.sp),
          ),
        ]),
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

    // Constrói o tabuleiro do jogo
  Widget _buildBoard(BuildContext _, __, ___) {
  return SizedBox.expand( // ou um Container com height
    child: Stack(
      children: gamesItems.map((item) {
        final safeDx = item.dx.clamp(0.05, 0.95);
        final safeDy = item.dy.clamp(0.05, 0.95);
        return Align(
          alignment: Alignment(safeDx * 2 - 1, safeDy * 2 - 1),
          child: GestureDetector(
            onTap: () => _handleTap(item),
            child: item.isTapped
                ? (item.isCorrect
                    ? _gamesSuperKey.currentState!.correctIcon
                    : _gamesSuperKey.currentState!.wrongIcon)
                : Container(
                    width: 60.w,
                    height: 60.w,
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
    ),
  );
}
}

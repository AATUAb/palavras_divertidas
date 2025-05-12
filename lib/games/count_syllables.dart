// Estrutura do jogo "Contar Sílabas"
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/user_model.dart';
import '../models/word_model.dart';
import '../widgets/game_item.dart';
import '../widgets/game_super_widget.dart';
import '../widgets/game_component.dart';

// Classe principal do jogo, que recebe o utilizador como argumento
class CountSyllablesGame extends StatefulWidget {
  final UserModel user;
  const CountSyllablesGame({super.key, required this.user});

  @override
  State<CountSyllablesGame> createState() => _CountSyllablesGame();
}

// Classe que controla o estado do jogo
class _CountSyllablesGame extends State<CountSyllablesGame> {
  final _gamesSuperKey = GlobalKey<GamesSuperWidgetState>();
  final _random = Random();
  late final AudioPlayer _wordPlayer;
  bool hasChallengeStarted = false;
  //late int currentLevel;
  late Duration levelTime;
  late int currentTry;
  late int foundCorrect;

  List<WordModel> _allWords = [];
  List<WordModel> _levelWords = [];
  List<String> _usedWords = [];
  late WordModel targetWord;
  bool showSyllables = false;

  bool isRoundActive = true;
  bool isRoundFinished = false;
  List<GameItem> gamesItems = [];
  Timer? roundTimer, progressTimer;
  late DateTime _startTime;
  double progress = 0.0;
  double progressValue = 1.0;

  bool get isFirstCycle => widget.user.schoolLevel == '1º Ciclo';

  String? _fontForGameItem({bool isTargetWord = false}) {
    if (isFirstCycle) {
      return isTargetWord ? 'Cursive' : null;
    }
    return null;
  }

  // Inicializa o estado do jogo
  @override
  void initState() {
    super.initState();
    _wordPlayer = AudioPlayer();
  }

  // Carrega as palavras do banco de dados Hive
  Future<void> _loadWords() async {
  final box = await Hive.openBox<WordModel>('words');
  _allWords = box.values.toList();
}

  // Fecha o player de áudio e cancela os temporizadores
  @override
  void dispose() {
    _wordPlayer.dispose();
    _cancelTimers();
    super.dispose();
  }

  // Aplica as definições de nível com base no nível atual do jogador
  Future<void> _applyLevelSettings() async {
    final lvl = _gamesSuperKey.currentState?.levelManager.level ?? 1;
    late String levelDifficulty;
    switch (lvl) {
      case 1:
        levelTime = const Duration(seconds: 15);
        levelDifficulty ='baixa';
        break;
      case 2:
        levelTime = const Duration(seconds: 20);
        levelDifficulty = 'media';
        break;
      case 3:
        levelTime = const Duration(seconds: 25);
        levelDifficulty = 'dificil';
        break;
    }
    _levelWords = _allWords
      .where((w) =>
          (w.difficulty ?? '').trim().toLowerCase() == levelDifficulty &&
          (w.audioPath ?? '').trim().isNotEmpty &&
          (w.imagePath ?? '').trim().isNotEmpty)
      .toList();

  if (_levelWords.isEmpty) {
    debugPrint('⚠️ Sem palavras disponíveis para o nível "$levelDifficulty".');
    return;
  }
}

  // Cancela os temporizadores ativos
  void _cancelTimers() {
    roundTimer?.cancel();
    progressTimer?.cancel();
  }

  // Reproduz a instrução de áudio para o jogador
  Future<void> _reproduzirInstrucao() async {
    final file = 'sounds/words_characters/${targetWord.audioFileName ?? targetWord.text}.ogg';
    try {
      await _wordPlayer.stop();
      await _wordPlayer.release();
      await _wordPlayer.play(AssetSource(file));
    } catch (e) {
      debugPrint('❌ Erro ao reproduzir som: $file — $e');
    }
  }

  // Função que controla o comportamento do jogo quando o jogador termina o jogo e que reinicar o mesmo jogo
  void _restartGame() async {
  _gamesSuperKey.currentState?.levelManager.level = 1;
  setState(() {
    _usedWords.clear();
    hasChallengeStarted = true;
    progressValue = 1.0;
  });
  await _applyLevelSettings();
  _generateNewChallenge();
}

  // Verifica se a palavra já foi utilizada na ronda atual, para controlar a repetição
  bool retryIsUsed(String value) => _usedWords.contains(value);

  // Gera um novo desafio, com base nas definições de nível e no estado atual do jogo
  Future<void> _generateNewChallenge() async {
    final retry = _gamesSuperKey.currentState?.peekNextRetryTarget();
    if (retry != null) debugPrint('🔁 Apresentado item da retry queue: $retry');

      // Lista de palabvras disponíveis para o nível atual
    final availableWords = _levelWords.where((w) =>
        !_usedWords.contains(w.text) &&
        w.audioPath.trim().isNotEmpty &&
        w.imagePath.trim().isNotEmpty).toList();

    if (availableWords.isEmpty && retry == null) {
      _gamesSuperKey.currentState?.showEndOfGameDialog(
        onRestart: _restartGame,
      );
      return;
    }

    // Seleciona a palavra-alvo aleatoriamente ou da fila de repetição
  final targetText = retry ?? availableWords[_random.nextInt(availableWords.length)].text;
targetWord = availableWords.firstWhere(
  (w) => w.text == targetText,
  orElse: () => availableWords[_random.nextInt(availableWords.length)],
);
  _gamesSuperKey.currentState?.removeFromRetryQueue(targetWord.text);
    
    // Se a palavra volta a ser apresentado, remove-o da fila de repetição
  // e adiciona-o à lista de palavras já utilizados
    _cancelTimers();
    setState(() {
      isRoundActive = true;
      gamesItems.clear();
      foundCorrect = 0;
      currentTry = 0;
      progressValue = 1.0;
  });

    // Geração das opções de resposta
    final correct = targetWord.syllableCount;
    final options = correct == 1
        ? ['1', '2', '3']
        : [correct - 1, correct, correct + 1]
            .map((e) => e.toString())
            .toList()
          ..shuffle();

    // Gera GameItems com as respostas
    final generatedItems = List<GameItem>.generate(options.length, (i) {
      return GameItem(
        id: '$i',
        type: GameItemType.number,
        content: options[i],
        dx: 0,
        dy: 0,
        fontFamily: '',
        backgroundColor: Colors.transparent,
        isCorrect: options[i] == correct.toString(),
      );
    });

    setState(() {
      gamesItems = generatedItems; 
      isRoundActive = true;
      currentTry = 0;
      foundCorrect = 0;
      progressValue = 1.0;
    });

    // Identifica o item correto para tocar o som
    final referenceItem = GameItem(
      id: 'preview',
      type: GameItemType.text,
      content: targetWord.audioFileName ?? targetWord.text,
      dx: 0,
      dy: 0,
      backgroundColor: Colors.transparent,
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
      _gamesSuperKey.currentState?.registerFailedRound(targetWord.text);
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
    await s.checkAnswerSingle(
      selectedItem: item,
      target: targetWord.syllableCount.toString(),
      retryId: targetWord.text,
      currentTry: currentTry,
      applySettings: _applyLevelSettings,
      generateNewChallenge: _generateNewChallenge,
      cancelTimers: _cancelTimers,
      showExtraFeedback: () async {
        setState(() {
          isRoundActive = false;
          showSyllables = true;
        });

        await Future.delayed(const Duration(seconds: 2));
        setState(() => showSyllables = false);
      },
    );

    setState(() => currentTry++);
  }


  // Constrói o widget principal do jogo
  @override
  Widget build(BuildContext context) {
    return GamesSuperWidget(
      key: _gamesSuperKey,
      user: widget.user,
      gameName: 'Contar sílabas',
      progressValue: progressValue,
      level: (_) => _gamesSuperKey.currentState?.levelManager.level ?? 1,
      currentRound: (_) => 1,
      totalRounds: (_) => 3,
      isFirstCycle: isFirstCycle,
      topTextContent: _buildTopText,
      builder: _buildBoard,
      onRepeatInstruction: _reproduzirInstrucao,
      introImagePath: 'assets/images/games/count_syllables.webp',
      introAudioPath: 'sounds/games/count_syllables.ogg',
      onIntroFinished: () async {
        await _loadWords();
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
      child: hasChallengeStarted
          ? _buildChallengeText()
          : Text(
              'Vamos contar as sílabas das palavras.',
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
    return Text(
      'Quantas sílabas tem a palavra ${targetWord.text}?',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: font,
        fontSize: 25.sp,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  // Constrói o tabuleiro do jogo, que contém a imagem, palavra e opções de resposta
Widget _buildBoard(BuildContext context, _, __) {
  if (!hasChallengeStarted || _levelWords.isEmpty) {
    return const SizedBox();
  }

  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 20.w),
    child: Column(
      children: [
        SizedBox(height: 85.h),

        // Palavra + imagem com possível divisão silábica sobreposta
        Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                WordHighlightBox(word: targetWord.text, user: widget.user),
                SizedBox(width: 50.w),
                ImageCardBox(imagePath: targetWord.imagePath),
              ],
            ),
            if (showSyllables)
              Positioned(
                top: 0,
                child: WordHighlightBox(
                  word: targetWord.syllables.join(' - '),
                  user: widget.user,
                ),
              ),
          ],
        ),

        const Spacer(),

        // Botões de resposta
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: gamesItems.map((item) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: GestureDetector(
                onTap: () => _handleTap(item),
                child: item.isTapped
                    ? (item.isCorrect
                        ? _gamesSuperKey.currentState!.correctIcon
                        : _gamesSuperKey.currentState!.wrongIcon)
                    : FlexibleAnswerButton(
                        label: item.content,
                        onTap: () => _handleTap(item),
                        user: widget.user,
                      ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 30.h),
      ],
    ),
  );
}
}

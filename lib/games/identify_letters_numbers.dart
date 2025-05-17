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
import '../widgets/game_component.dart';

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

  // Inicializa o estado do jogo
  @override
  void initState() {
    super.initState();
    _letterPlayer = AudioPlayer();
  }

  // Carrega as palavras do banco de dados Hive
  Future<void> _loadCharacters() async {
    final box = await Hive.openBox<CharacterModel>('characters');
      _characters = box.values
      .where((c) => c.character.trim().isNotEmpty)
      .toList();
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
  late GameItem referenceItem;
  Future<void> _reproduzirInstrucao() async {
    await _gamesSuperKey.currentState?.playNewChallengeSound(referenceItem);
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
  List<String> _generateWrongOptions({
  required int count,
  required List<CharacterModel> pool,
  required String target,
}) {
  final bad = <String>{};
  final rand = Random();

  while (bad.length < count) {
    final c = pool[rand.nextInt(pool.length)].character;
    final opt = rand.nextBool() ? c.toUpperCase() : c.toLowerCase();
    if (opt.toLowerCase() != target.toLowerCase()) {
      bad.add(opt);
    }
  }

  return bad.toList();
}

// Gera as opções corretas, com base no caractere alvo
List<String> _generateCorrectOptions({
  required int count,
  required String target,
}) {
  final rand = Random();
  return List.generate(
    count,
    (_) => rand.nextBool() ? target.toUpperCase() : target.toLowerCase(),
  );
}

  // Constrói um novo item de jogo, com base no caractere e na posição
  GameItem buildGameItem({
    required int index,
    required String content,
    required String target,
    required double dx,
    required double dy,
    required bool isFirstCycle,
    required String? fontFamily,
    required Color backgroundColor,
  }) {
    final isCorrect = content.toLowerCase() == target.toLowerCase();

    return GameItem(
      id: '$index',
      type: GameItemType.character,
      content: content,
      dx: dx,
      dy: dy,
      fontFamily: isFirstCycle ? fontFamily : null,
      backgroundColor: backgroundColor,
      isCorrect: isCorrect,
    );
  }

    // Cores a aplicar aos itens do jogo
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

  // Gera um novo desafio, com base nas definições de nível e no estado atual do jogo
  Future<void> _generateNewChallenge() async {
    // Verifica se há retry a usar
    final retry = _gamesSuperKey.currentState?.peekNextRetryTarget();

    final availableCharacters = _characters
        .map((e) => e.character)
        .where((c) => !_usedCharacters.contains(c))
        .toList();

    if (_gamesSuperKey.currentState?.isEndOfGame(availableItems: availableCharacters) ?? false) {
      _gamesSuperKey.currentState?.showEndOfGameDialog(onRestart: _restartGame);
      return;
    }

    final selected = retry != null
        ? _gamesSuperKey.currentState!.safeRetry<String>(
            list: _characters.map((e) => e.character).toList(),
            retryId: retry,
            matcher: (c) => c == retry,
            fallback: () => availableCharacters[_random.nextInt(availableCharacters.length)],
          )
        : availableCharacters[_random.nextInt(availableCharacters.length)];

    setState(() {
      targetCharacter = selected;
      _usedCharacters.add(selected);
    });

    _gamesSuperKey.currentState?.removeFromRetryQueue(selected);
    _gamesSuperKey.currentState?.registerCompletedRound(selected);

    // Se a palavra volta a ser apresentado, remove-o da fila de repetição
    // e adiciona-o à lista de palavras já utilizados
    _cancelTimers();
    setState(() {
      isRoundActive = true;
      gamesItems.clear();
      foundCorrect = 0;
      currentTry = 0;
      progressValue = 1.0;
      targetCharacter = targetCharacter;
        });

  // Gera lista de opções corretas e erradas e miustura
  final bad  = _generateWrongOptions(count: wrongCount, pool: _characters, target: targetCharacter);
  final good = _generateCorrectOptions(count: correctCount, target: targetCharacter);
  final all  = [...bad, ...good]..shuffle();

  final cols = (all.length / 3).ceil();
  final sx = 1 / (cols + 1);
  final sy = 0.18;

  gamesItems = List.generate(all.length, (i) {
    final col = i % cols;
    final row = i ~/ cols;
    return buildGameItem(
      index: i,
      content: all[i],
      target: targetCharacter,
      dx: sx * (col + 1),
      dy: 0.45 + sy * row,
      isFirstCycle: isFirstCycle,
      fontFamily: _randFont(),
      backgroundColor: _randColor(),
    );
  });

  referenceItem = gamesItems.firstWhere(
    (item) => item.isCorrect,
    orElse: () => GameItem(
      id: 'preview',
      type: GameItemType.character,
      content: targetCharacter,
      dx: 0,
      dy: 0,
      backgroundColor: Colors.transparent,
    ),
  );

  // Reproduz o som do caractere alvo
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await Future.delayed(const Duration(milliseconds: 50));
    if (!mounted) return;
    await _gamesSuperKey.currentState?.playNewChallengeSound(referenceItem);
        });

  // Sincroniza temporizadores com o tempo de nível
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
      retryId: targetCharacter,
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
      gameName: 'Identificar letras e números',
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

  // Constrói o texto superior que é apresenado quando o jogo arranca
  Widget _buildTopText() {
    final isPreschool = widget.user.schoolLevel == 'Pré-Escolar';

    // Mensagem inicial antes de carregar
    if (!hasChallengeStarted || targetCharacter.isEmpty) {
      return _buildSimpleText('Vamos encontrar todas as letras e números');
    }

    // Pré-escolar: apenas letras simples, sem estilos diferentes
    if (isPreschool) {
      final label = _isNumber(targetCharacter)
          ? 'Encontra os números ${targetCharacter.toUpperCase()}'
          : 'Encontra as letras ${targetCharacter.toUpperCase()}, ${targetCharacter.toLowerCase()}';
      return _buildSimpleText(label);
    }

    // 1º ciclo com letras → mostra as 4 variações (Slabo e Cursive)
    if (isFirstCycle && _isLetter(targetCharacter)) {
      return Text.rich(
        TextSpan(
          children: [
            const TextSpan(text: 'Encontra as letras '),
            for (final entry in [
              TextSpan(text: targetCharacter.toUpperCase(), style: _slaboStyle()),
              const TextSpan(text: ', '),
              TextSpan(text: targetCharacter.toLowerCase(), style: _slaboStyle()),
              const TextSpan(text: ', '),
              TextSpan(text: targetCharacter.toUpperCase(), style: _cursiveStyle()),
              const TextSpan(text: ', '),
              TextSpan(text: targetCharacter.toLowerCase(), style: _cursiveStyle()),
            ])
              entry,
          ],
        ),
        textAlign: TextAlign.center,
      );
    }

    // Caso geral
    final label = _isNumber(targetCharacter)
        ? 'Encontra os números $targetCharacter'
        : 'Encontra as letras ${targetCharacter.toUpperCase()}, ${targetCharacter.toLowerCase()}';
    return _buildSimpleText(label);
  }

  // Helpers
  Text _buildSimpleText(String text) => Text(
    text,
    textAlign: TextAlign.center,
    style: TextStyle(
      fontSize: 22.sp,
      fontWeight: FontWeight.bold,
      fontFamily: getFontFamily(FontStrategy.none),
    ),
  );

  TextStyle _slaboStyle() => TextStyle(fontFamily: 'Slabo', fontSize: 22.sp);
  TextStyle _cursiveStyle() => TextStyle(fontFamily: 'Cursive', fontSize: 25.sp);



  // Constrói o tabuleiro do jogo, com base CharacterCircleBox do game_component.dart 
  Widget _buildBoard(BuildContext _, __, ___) {
    return SizedBox.expand(
      child: Stack(
        children:
            gamesItems.map((item) {
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
                    : CharacterCircleBox(
                        character: item.content,
                        color: item.backgroundColor,
                        user: widget.user,
                        fontFamily: item.fontFamily,
                      ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
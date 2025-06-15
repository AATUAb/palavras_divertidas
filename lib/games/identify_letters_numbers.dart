// Jogo "Identificar letras e números":
// O jogador ouve uma letra ou número e tem de clicar sobre vários circulos com essa letra ou número.
// A quantidade de elementos corretos e errados e tempo variam com o nível.
// Cada resposta correta mostra um ícone de correto e som correspondente. Ao terminar a jogada e seleciionar todos os elementos, há uma animação de coffeties.

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
  bool hasChallengeStarted = false;
  late int correctCount;
  late int wrongCount;
  late Duration levelTime;
  late int currentTry;
  late int foundCorrect;

  List<CharacterModel> _characters = [];
  final List<String> _usedCharacters = [];
  String targetCharacter = '';

  bool isRoundActive = true;
  bool isRoundFinished = false;
  List<GameItem> gamesItems = [];
  bool _isDisposed = false;
  bool _isTutorialActive = false;

  bool get isFirstCycle => widget.user.schoolLevel == '1º Ciclo';
  bool _isLetter(String c) => RegExp(r'[a-zA-Z]').hasMatch(c);
  bool _isNumber(String c) => RegExp(r'[0-9]').hasMatch(c);
  String _randFont() => _random.nextBool() ? 'Slabo' : 'Cursive';

  // Inicializa o estado do jogo
  @override
  void initState() {
    super.initState();
  }

  // Fecha o player de áudio e cancela os temporizadores
  @override
  void dispose() {
    _isDisposed = true;
    _cancelTimers();
    super.dispose();
  }

  // Carrega as palavras do banco de dados Hive
  Future<void> _loadCharacters() async {
    final box = await Hive.openBox<CharacterModel>('characters');
    _characters =
        box.values.where((c) => c.character.trim().isNotEmpty).toList();
  }

  // Aplica as definições de nível com base no nível atual do jogador
  Future<void> _applyLevelSettings() async {
    final lvl = _gamesSuperKey.currentState?.levelManager.level ?? 1;
    switch (lvl) {
      case 1:
        correctCount = 4;
        wrongCount = 8;
        levelTime = const Duration(seconds: 120);
        break;
      case 2:
        correctCount = 5;
        wrongCount = 10;
        levelTime = const Duration(seconds: 120);
        break;
      case 3:
        correctCount = 6;
        wrongCount = 12;
        levelTime = const Duration(seconds: 120);
        break;
    }
    if (!mounted || _isDisposed) return;
    setState(() {});
  }

  // Cancela os temporizadores ativos
  void _cancelTimers() {
    _gamesSuperKey.currentState?.cancelProgressTimer();
  }

  // Reproduz a instrução de áudio para o jogador
  late GameItem referenceItem;
  Future<void> _playInstruction() async {
    if (!mounted || _isDisposed) return;
    await _gamesSuperKey.currentState?.playNewChallengeSound(referenceItem);
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
     if (_gamesSuperKey.currentState?.isTutorialVisible ?? false) return;
    _gamesSuperKey.currentState?.playChallengeHighlight();

    if (!mounted || _isDisposed) return;

    final retryId = _gamesSuperKey.currentState?.peekNextRetryTarget();

    targetCharacter =
        retryId != null
            ? _gamesSuperKey.currentState!.safeRetry<String>(
              list: _characters.map((e) => e.character).toList(),
              retryId: retryId,
              matcher: (c) => c.toLowerCase() == retryId.toLowerCase(),
              fallback:
                  () => _gamesSuperKey.currentState!.safeSelectItem(
                    availableItems:
                        _characters
                            .map((e) => e.character)
                            .where((c) => !_usedCharacters.contains(c))
                            .toList(),
                  ),
            )
            : _gamesSuperKey.currentState!.safeSelectItem(
              availableItems:
                  _characters
                      .map((e) => e.character)
                      .where((c) => !_usedCharacters.contains(c))
                      .toList(),
            );

    if (!_usedCharacters.contains(targetCharacter)) {
      _usedCharacters.add(targetCharacter);
    }


    final available =
        _characters
            .map((e) => e.character)
            .where((c) => !_usedCharacters.contains(c))
            .toList();
    final hasRetry = _gamesSuperKey.currentState?.peekNextRetryTarget() != null;

    if (available.isEmpty && !hasRetry) {
      _gamesSuperKey.currentState?.showEndOfGameDialog(
        onRestart: () async {
          await _gamesSuperKey.currentState?.restartGame();
          await _applyLevelSettings();
          if (mounted) _generateNewChallenge();
        },
      );
      return;
    }

    // Reproduz som após pequena espera
    _cancelTimers();
    setState(() {
      isRoundActive = true;
      gamesItems.clear();
      foundCorrect = 0;
      currentTry = 0;
    });

    // Gera lista de opções corretas e erradas e miustura
    final bad = _generateWrongOptions(
      count: wrongCount,
      pool: _characters,
      target: targetCharacter,
    );
    final good = _generateCorrectOptions(
      count: correctCount,
      target: targetCharacter,
    );
    final all = [...bad, ...good]..shuffle();

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
      orElse:
          () => GameItem(
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
      if (!mounted || _isDisposed) return;
      await _gamesSuperKey.currentState?.playNewChallengeSound(referenceItem);
    });

    // Sincroniza temporizadores com o tempo de nível
   _gamesSuperKey.currentState?.startProgressTimer(
      levelTime: levelTime,
      onTimeout: () {
        if (!mounted || _isDisposed) return;
        setState(() => isRoundActive = false);
        _gamesSuperKey.currentState?.registerFailedRound(targetCharacter);
        _gamesSuperKey.currentState?.showTimeout(
          applySettings: _applyLevelSettings,
          generateNewChallenge: _generateNewChallenge,
        );
      },
    );
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

    if (item.isCorrect) {
      _gamesSuperKey.currentState?.registerResponseTimeForCurrentRound(
        user: widget.user,
        gameName: 'Identificar letras e números',
      );
    }

    // Marca uma ronda como terminada e cancela os temporizadores
    void markRoundAsFinished() {
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
      markRoundFinished: markRoundAsFinished,
    );
  }

void _showTutorial() {
  final state = _gamesSuperKey.currentState;

  final safeRetryId = hasChallengeStarted ? targetCharacter : null;

  state?.showTutorialDialog(
    retryId: safeRetryId,
    onTutorialClosed: () {
      _generateNewChallenge();
    },
  );
}

  // Constrói o widget principal do jogo
  @override
  Widget build(BuildContext context) {
    return GamesSuperWidget(
      key: _gamesSuperKey,
      user: widget.user,
      gameName: 'Identificar letras e números',
      level: (_) => _gamesSuperKey.currentState?.levelManager.level ?? 1,
      currentRound: (_) => 1,
      totalRounds: (_) => 3,
      isFirstCycle: isFirstCycle,
      topTextContent: _buildTopText,
      builder: _buildBoard,
      onRepeatInstruction: _playInstruction,
      introImagePath: 'assets/images/games/identify_letters_numbers.webp',
      introAudioPath: 'identify_letters_numbers.ogg',
      onIntroFinished: () async {
        await _loadCharacters();
        await _applyLevelSettings();
        if (!mounted || _isDisposed) return;
        setState(() => hasChallengeStarted = true);
        if (!mounted || _isDisposed) return;
        _generateNewChallenge();
      },
        onShowTutorial: () {
        _showTutorial();
   }
    );
  }

  // Constrói o texto rico com o conteúdo fornecido
  Widget _buildRichText(TextSpan textSpan) => Padding(
    padding: EdgeInsets.only(top: 20.h, left: 40.w, right: 40.w),
    child: Text.rich(
      textSpan,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 22.sp,
        fontWeight: FontWeight.bold,
        fontFamily: getFontFamily(FontStrategy.none),
      ),
    ),
  );

  // Define o estilo de texto para a fonte ComicNeue
  TextStyle slaboStyle() => TextStyle(
    fontFamily: 'Slabo',
    fontSize: 22.sp,
    fontWeight: FontWeight.bold,
   );

  // Define o estilo de texto para a fonte Cursive
  TextStyle cursiveStyle() => TextStyle(
    fontFamily: 'Cursive',
    fontSize: 25.sp,
    fontWeight: FontWeight.bold,
  );

  // Constrói o texto superior do jogo, com base no nível e no caractere alvo
  Widget _buildTopText() {
    final isPreschool = widget.user.schoolLevel == 'Pré-Escolar';

    // Mensagem inicial antes de carregar
    if (!hasChallengeStarted || targetCharacter.isEmpty) {
      return _buildRichText(
        TextSpan(
          text: 'Vamos encontrar todas as letras e números',
        ),
      );
    }

  // Caso 1: Pré-escolar → se for pré, sai já daqui
    if (isPreschool) {
      final label = _isNumber(targetCharacter)
          ? 'Encontra os números '
          : 'Encontra as letras ';
      final spans = <TextSpan>[
        TextSpan(
          text: targetCharacter.toUpperCase(),
          style: TextStyle(
            fontFamily: 'ComicNeue',
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ];

      if (!_isNumber(targetCharacter)) {
        spans.add(const TextSpan(text: ', '));
        spans.add(
          TextSpan(
            text: targetCharacter.toLowerCase(),
            style: TextStyle(
              fontFamily: 'ComicNeue',
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }

      return _buildRichText(
        TextSpan(
          children: [
            TextSpan(text: label),
            ...spans,
          ],
        ),
      );
    }

  // Caso 2: 1º ciclo → números → mostrar só uma vez!
    if (isFirstCycle && _isNumber(targetCharacter)) {
      return _buildRichText(
        TextSpan(
          children: [
            const TextSpan(text: 'Encontra os números '),
            TextSpan(
              text: targetCharacter,
              style: TextStyle(
                fontFamily: 'Slabo', // ou a fonte que usas para números
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    // Caso 3: 1º ciclo → letras → as 4 variantes
    if (isFirstCycle && _isLetter(targetCharacter)) {
    return _buildRichText(
    TextSpan(
      children: [
        const TextSpan(text: 'Encontra as letras '),
        TextSpan(
          text: targetCharacter.toUpperCase(),
          style: slaboStyle(),
        ),
        const TextSpan(text: ', '),
        TextSpan(
          text: targetCharacter.toLowerCase(),
          style: slaboStyle(),
        ),
        const TextSpan(text: ', '),
        TextSpan(
          text: targetCharacter.toUpperCase(),
          style: cursiveStyle(),
        ),
        const TextSpan(text: ', '),
        TextSpan(
          text: targetCharacter.toLowerCase(),
          style: cursiveStyle(),
        ),
      ],
    ),
  );
}
  // Fallback — segurança extra
  return _buildRichText(
    TextSpan(
      text: 'Vamos encontrar todas as letras e números',
      style: TextStyle(
        fontFamily: isPreschool ? 'ComicNeue' : 'Slabo',
        fontSize: 22.sp,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

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
                  child:
                      item.isTapped
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

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

class _IdentifyLettersNumbersState extends State<IdentifyLettersNumbers> {
  final _gamesSuperKey = GlobalKey<GamesSuperWidgetState>();     // Chave global para o widget de jogo
  final _random = Random();                                     // Gerador de letras e números aleatórios         
  late final AudioPlayer _letterPlayer;                         // Player de áudio para reproduzir sons de letras e números
  bool hasChallengeStarted = false;                             // Indica se o desafio começou
  late int correctCount;                                        // Número de letras/números corretos a encontrar
  late int wrongCount;                                         // Número de letras/números errados a encontrar
  late Duration levelTime;                                     // Tempo total para completar o nível
  late int currentTry;                                         // Tentativas atuais do jogador                            
  late int foundCorrect;                                      // Número de letras/números encontrados corretamente

  List<CharacterModel> _characters = [];                       // Lista de caracteres disponíveis
  List<String> _usedCharacters = [];                          // Lista de caracteres já utilizados
 
  bool isRoundActive = true;                                 // Indica se a ronda está ativa
  String targetCharacter = '';                               // Caractere alvo a encontrar   
  bool isRoundFinished = false;                              // Indica se a ronda está terminada
  List<GameItem> gamesItems = [];                            // Lista de itens do jogo (letras/números)                   
  Timer? roundTimer, progressTimer;                           // Temporizadores para controlar o tempo da ronda e o progresso
  double progress = 0.0;                                      // Progresso atual do jogador 
  double progressValue = 1.0;

  bool get isFirstCycle => widget.user.schoolLevel == '1º Ciclo';       // Verifica se o utilizador está no 1º ciclo
  bool _isLetter(String c) => RegExp(r'[a-zA-Z]').hasMatch(c);          // Verifica se o caractere é uma letra
  bool _isNumber(String c) => RegExp(r'[0-9]').hasMatch(c);             // Verifica se o caractere é um número
  String _randFont() => _random.nextBool() ? 'Slabo' : 'Cursive';       // Seleciona aleatoriamente uma fonte entre 'Slabo' e 'Cursive'
 
  // Seleciona uma cor entre uma lista de cores pré-definidas para as bolhas das letras/números
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

  // Inicializa o estado do jogo
  @override
  void initState() {
    super.initState();
    _letterPlayer = AudioPlayer();
  }

  // Carrega os caracteres disponíveis a partir do Hive
  Future<void> _loadCharacters() async {
    final box = await Hive.openBox<CharacterModel>('characters');
    _characters = box.values.toList();
  }

  //  Fecha o player de áudio e cancela os temporizadores
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
    final file =
        'sounds/words_characters/${targetCharacter.toUpperCase()}.ogg';
    await _letterPlayer.stop();
    await _letterPlayer.release();
    await _letterPlayer.play(AssetSource(file));
  }

  // Verifica se o caractere já foi utilizado na ronda atual, para controlar a repetição
  bool retryIsUsed(String value) => _usedCharacters.contains(value);

  Future<void> _generateNewChallenge() async {
  _gamesSuperKey.currentState?.registerCompletedRound();
  final retry = _gamesSuperKey.currentState?.peekNextRetryTarget();
  if (retry != null) debugPrint('🔁 Apresentado item da retry queue: $retry');

  final allChars = _characters.map((e) => e.character.toUpperCase()).toList();
  final availableChars =
      allChars.where((c) => !_usedCharacters.contains(c)).toList();

  if (availableChars.isEmpty && retry == null) {
    _gamesSuperKey.currentState?.showEndOfGameDialog(
      onRestart: () {
        setState(() => _usedCharacters.clear());
        _generateNewChallenge();
      },
    );
    return;
  }

  final target =
      retry ?? availableChars[_random.nextInt(availableChars.length)];
  if (!retryIsUsed(target)) _usedCharacters.add(target);

  _gamesSuperKey.currentState?.removeFromRetryQueue(target);

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
    if (opt.toLowerCase() != target.toLowerCase()) bad.add(opt);
  }

  final good = List.generate(
    correctCount,
    (_) => _random.nextBool() ? target.toUpperCase() : target.toLowerCase(),
  );

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

  // 🆕 Identifica um dos itens corretos para tocar o som
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

  // 🆕 Solicita ao super widget a reprodução do som do desafio
  await _gamesSuperKey.currentState?.playNewChallengeSound(referenceItem);

  // Inicia temporizadores
  setState(() {});
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

    final isCorrect =
        item.content.toLowerCase() == targetCharacter.toLowerCase();
    item.isCorrect = isCorrect;

    if (!isCorrect) {
      s.registerFailedRound(targetCharacter);
    }

    // Verifica se o jogador encontrou o caractere correto
    // Faz callback para o método checkAnswer do GamesSuperWidget
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

  // Constrói o widget principal do jogo
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
    return Padding(
      padding: EdgeInsets.only(top: 19.h, left: 16.w, right: 16.w),
      child:
          hasChallengeStarted
              ? _buildChallengeText()
              : Text(
                'Vamos encontrar todas as letras e números!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
    );
  }

  // Constrói o texto do desafio, que apresenta o caractere alvo a encontrar
  Widget _buildChallengeText() {
    if (isFirstCycle && _isLetter(targetCharacter)) {
      return Text.rich(
        TextSpan(
          children: [
            const TextSpan(text: 'Encontra as letras '),
            TextSpan(
              text:
                  '${targetCharacter.toUpperCase()}, ${targetCharacter.toLowerCase()}',
              style: TextStyle(fontFamily: 'Slabo', fontSize: 22.sp),
            ),
            const TextSpan(text: ', '),
            TextSpan(
              text:
                  '${targetCharacter.toUpperCase()}, ${targetCharacter.toLowerCase()}',
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

  // Constrói o tabuleiro do jogo, que contém os itens (letras/números) a encontrar
  Widget _buildBoard(BuildContext _, __, ___) => Stack(
    children: [
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
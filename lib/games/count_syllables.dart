// Estrutura do jogo "Identifica letras e números"
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

// Classe principal do jogo, que recebe o utilizador como argumento
class CountSyllablesGame  extends StatefulWidget {
  final UserModel user;
  const CountSyllablesGame ({super.key, required this.user});

  @override
  State<CountSyllablesGame > createState() => _CountSyllablesGame ();
}

class _CountSyllablesGame  extends State<CountSyllablesGame > {
  final _gamesSuperKey = GlobalKey<GamesSuperWidgetState>();     // Chave global para o widget de jogo
  final _random = Random();                                     // Gerador de letras e números aleatórios         
  late final AudioPlayer _wordPlayer;                         // Player de áudio para reproduzir sons de palavras
  bool hasChallengeStarted = false;                             // Indica se o desafio começou
  late int currentLevel;                                        //? Nível atual do jogador
  late Duration levelTime;                                     // Tempo total para completar o nível
  late int currentTry;                                         // Tentativas atuais do jogador                            
  late int foundCorrect;                                      // Número de letras/números encontrados corretamente

  List<WordModel> _words = [];                                  // Lista de palavras disponíveis
  List<String> _usedWords = [];                                 // Lista de palavras já utilizadas
  late WordModel targetWord;                                    // Palavra alvo a encontrar 
 
  bool isRoundActive = true;                                 // Indica se a ronda está ativa
  bool isRoundFinished = false;                              // Indica se a ronda está terminada
  List<GameItem> gamesItems = [];                            // Lista de itens do jogo (letras/números)                   
  Timer? roundTimer, progressTimer;                           // Temporizadores para controlar o tempo da ronda e o progresso
  double progress = 0.0;                                      // Progresso atual do jogador 
  double progressValue = 1.0;

  bool get isFirstCycle => widget.user.schoolLevel == '1º Ciclo';       // Verifica se o utilizador está no 1º ciclo

  // Verifica se o utilizador é de 1º ciclo para aplicar a fonte correta
  String? _fontForGameItem({bool isTargetWord = false}) {
  if (isFirstCycle) {
    return isTargetWord ? 'Cursive' : null; // Palavra principal = Cursive
  }
  return null;
}

  // Inicializa o estado do jogo
  @override
  void initState() {
    super.initState();
     _wordPlayer = AudioPlayer();
  }

  // Carrega as palavras disponíveis a partir do Hive
  Future<void> _loadWords() async {
    final box = await Hive.openBox<WordModel>('words');
    _words = box.values.toList();
  }

  //  Fecha o player de áudio e cancela os temporizadores
  @override
  void dispose() {
    _wordPlayer.dispose();
    _cancelTimers();
    super.dispose();
  }

  // Aplica as definições de nível com base no nível atual do jogador
  Future<void> _applyLevelSettings() async {
  final lvl = _gamesSuperKey.currentState?.levelManager.level ?? 1;

  switch (lvl) {
    case 1:
      levelTime = const Duration(seconds: 15);
      break;
    case 2:
      levelTime = const Duration(seconds: 20);
      break;
    case 3:
      levelTime = const Duration(seconds: 25);
      break;
  }

  final levelDifficulty = switch (lvl) {
    1 => 'baixa',
    2 => 'media',
    3 => 'elevada',
    _ => 'baixa',
  };

  // Filtra palavras pela dificuldade atual
  final filteredWords = _words
      .where((w) => w.difficulty.trim().toLowerCase() == levelDifficulty)
      .toList();

  if (filteredWords.isEmpty) {
    debugPrint('⚠️ Nenhuma palavra encontrada com dificuldade: $levelDifficulty');
  }

  setState(() {
    currentLevel = lvl;
    _words = filteredWords;
  });
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
  // Reinicia o nível manualmente
  _gamesSuperKey.currentState?.levelManager.level = 1;

  // Reinicia o progresso interno
  setState(() {
    _usedWords.clear();
    hasChallengeStarted = true;
    progressValue = 1.0;
  });

  // Reaplica definições e inicia primeiro desafio
  await _applyLevelSettings();
  _generateNewChallenge();
}
  
  // Verifica se a palavra já foi utilizada na ronda atual, para controlar a repetição
  bool retryIsUsed(String value) => _usedWords.contains(value);



Future<void> _generateNewChallenge() async {
  _gamesSuperKey.currentState?.registerCompletedRound();
  final retry = _gamesSuperKey.currentState?.peekNextRetryTarget();
  if (retry != null) debugPrint('🔁 Apresentado item da retry queue: $retry');

  final availableWords = _words.where((w) =>
    !_usedWords.contains(w.text) &&
    w.audioPath.trim().isNotEmpty &&
    w.imagePath.trim().isNotEmpty
  ).toList();

  if (availableWords.isEmpty && retry == null) {
    _gamesSuperKey.currentState?.showEndOfGameDialog(
      onRestart: _restartGame
      );
    return;
  }

  // Seleciona a palavra-alvo
  targetWord = retry != null
    ? availableWords.firstWhere((w) => w.text == retry, orElse: () => availableWords[_random.nextInt(availableWords.length)])
    : availableWords[_random.nextInt(availableWords.length)];

  if (!_usedWords.contains(targetWord.text)) {
    _usedWords.add(targetWord.text);
  }

  _gamesSuperKey.currentState?.removeFromRetryQueue(targetWord.text);

  _cancelTimers();
  setState(() {
    isRoundActive = true;
    //hasChallengeStarted = true;
    gamesItems.clear();
    currentTry = 0;
    foundCorrect = 0;
    progressValue = 1.0;
  });

  // Geração das opções de sílabas
  final correct = targetWord.syllableCount;
  List<int> options;
  if (correct == 1) {
    options = [1, 2, 3];
  } else {
    options = {correct, correct - 1, correct + 1}.toList()..shuffle();
  }

  // Gera GameItems com as opções de multipla
  final cols = 3;
  final sx = 1 / (cols + 1);
  final dy = 0.7;

    gamesItems = List.generate(options.length, (i) {
    final col = i;
    return GameItem(
      id: '\$i',
      type: GameItemType.number,
      content: options[i].toString(),
      dx: sx * (col + 1),
      dy: dy,
      fontFamily: _fontForGameItem(),
      backgroundColor: Colors.teal,
      isCorrect: options[i] == correct,
    );
  });

   // Identifica um dos itens corretos para tocar o som
  final referenceItem = GameItem(
  id: 'preview',
  type: GameItemType.text,
  content: (targetWord.audioFileName ?? targetWord.text),
  dx: 0,
  dy: 0,
  backgroundColor: Colors.transparent,
);

WidgetsBinding.instance.addPostFrameCallback((_) async {
  await Future.delayed(const Duration(milliseconds: 100));
  await _gamesSuperKey.currentState?.playNewChallengeSound(referenceItem);
});

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

  final selected = int.tryParse(item.content);
  final isCorrect = selected == targetWord.syllableCount;
  item.isCorrect = isCorrect;

  if (!isCorrect) {
    s.registerFailedRound(targetWord.text);
  }

  // marca o item para mostrar o ícone correto/errado
  setState(() {
    item.showCheck = true;
  });



    // Verifica se o jogador encontrou o caractere correto
    // Faz callback para o método checkAnswer do GamesSuperWidget
    s.checkAnswer(
    selectedItem: item,
    target: targetWord.text,
    correctCount: 1,
    currentTry: currentTry,
    foundCorrect: isCorrect ? 1 : 0,
    applySettings: _applyLevelSettings,
    generateNewChallenge: _generateNewChallenge,
    updateFoundCorrect: (_) {},
    cancelTimers: _cancelTimers,
  );
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
      }
    );
  }

 Widget _buildTopText() {
  final font = getFontFamily(isFirstCycle ? FontStrategy.slabo : FontStrategy.none);
    return Padding(
      padding: EdgeInsets.only(top: 19.h, left: 16.w, right: 16.w),
      child:
          hasChallengeStarted
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

// Constrói o texto do desafio, que apresenta o caractere alvo a encontrar
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

  // Constrói o tabuleiro do jogo, que contém os itens (letras/números) a encontrar
 Widget _buildBoard(BuildContext _, __, ___) {
  if (!hasChallengeStarted || _words.isEmpty) {
    return const SizedBox();
  }

  final font = getFontFamily(isFirstCycle ? FontStrategy.slabo : FontStrategy.none);

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      SizedBox(height: 12.h),
      Text(
        targetWord.text,
        style: TextStyle(fontSize: 26.sp, fontFamily: font),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: 20.h),
      Image.asset(
        targetWord.imagePath,
        width: 160.w,
        height: 160.h,
        fit: BoxFit.contain,
      ),
      SizedBox(height: 32.h),
      _buildAnswerButtons(),
    ],
  );
}

Widget _buildWordImage() {
  return Image.asset(
    targetWord.imagePath,
    width: 160.w,
    height: 160.h,
    fit: BoxFit.contain,
  );
}

Future<void> _playWordSound(String word) async {
  final path = 'sounds/words_characters/${word.toLowerCase()}.ogg';
  await _wordPlayer.stop();
  await _wordPlayer.release();
  await _wordPlayer.play(AssetSource(path));
}

Widget _buildAnswerButtons() {
  final options = [1, 2, 3]; // fixa 3 opções, como pediste

  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: options.map((value) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: ElevatedButton(
          onPressed: () => _handleAnswer(value),
          child: Text(
            '$value',
            style: TextStyle(fontSize: 22.sp),
          ),
        ),
      );
    }).toList(),
  );
}


void _handleAnswer(int selected) async {
  final correct = selected == targetWord.syllableCount;

  await _gamesSuperKey.currentState?.playAnswerFeedback(isCorrect: correct);

  await _gamesSuperKey.currentState?.levelManager.registerRoundForLevel(correct: correct);

  await _gamesSuperKey.currentState?.conquestManager.registerRoundForConquest(
    context: context,
    firstTry: correct,
    userKey: _gamesSuperKey.currentState!.widget.user.key!,
    applySettings: () async {}, // opcional, pode ser omitido se não usado
  );

  //Future.delayed(Duration(seconds: 1), _generateNewChallenge);
  _generateNewChallenge(); // Chama a função para gerar um novo desafio
}
}
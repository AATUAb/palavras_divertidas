// Estrutura para o jogo "Detetive de Letras e Números", que desafia os jogadores a identificar letras e números em um conjunto de opções.

import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/level_manager.dart';
import '../widgets/games_animations.dart';
import '../widgets/games_design.dart';
import '../models/user_model.dart';

// classe para o jogo "Detetive de Letras e Números"
class IdentifyLettersNumbersGame extends StatefulWidget {
  final UserModel user;

  const IdentifyLettersNumbersGame({super.key, required this.user});

  @override
  IdentifyLettersNumbersGameState createState() => IdentifyLettersNumbersGameState();
}

// classse para o estado do jogo "Detetive de Letras e Números"
class IdentifyLettersNumbersGameState extends State<IdentifyLettersNumbersGame> {
  late LevelManager levelManager;
  bool isFirstCycle = false;
  bool showSuccessAnimation = false;

// lista de caracteres que podem ser usados no jogo
  final List<String> characters = [
    ...'ABCDEFGHIJLMNOPQRSTUVXZ'.split(''),
    ...'abcdefghijlmnopqrstuvxz'.split(''),
    ...'0123456789'.split(''),
  ];

// verifica se o caractere é uma letra ou um número e escolhe uma fonte aleatória para 1º ciclo
  bool _isLetter(String char) => RegExp(r'[a-zA-Z]').hasMatch(char);
  bool _isNumber(String char) => RegExp(r'[0-9]').hasMatch(char);
  String _chooseRandomFont() => _random.nextBool() ? 'Slabo' : 'Cursive';
  
// aplica aleatoriedade na escolha dos caracteres errados
  final Random _random = Random();
  int correctCount = 4;
  int wrongCount = 5;
  Duration levelTime = const Duration(seconds: 10);

  /// variáveis para controlar o progresso do jogo
  int currentTry = 0;
  int foundCorrect = 0;

  // variáveis para controlar o tempo do jogo
  String targetCharacter = '';
  List<LetterItem> letterItems = [];

  Timer? roundTimer;
  Timer? progressTimer;
  double progressValue = 1.0;

  // cores aleatórias a aplicar nos circulos que incluem as letras
  Color _generateStrongColor() {
    final colors = [
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
    ];
    return colors[_random.nextInt(colors.length)];
  }


  // inicializa o estado do jogo
  @override
  void initState() {
    super.initState();
    isFirstCycle = widget.user.level == '1º Ciclo';
    levelManager = LevelManager(user: widget.user);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      applyLevelSettings();
      generateNewChallenge();
    });
  }

   // limpa os temporizadores quando o widget é removido da árvore de widgets
  @override
  void dispose() {
    roundTimer?.cancel();
    progressTimer?.cancel();
    super.dispose();
  }

// aplica as configurações do nível atual:
// - O número de caracteres corretos aumenta com o nível para aumentar o desafio
// - O número de distrações (errados) também sobe para tornar mais difícil
// - O tempo total é ajustado para dar margem proporcional ao desafio
  void applyLevelSettings() {
    switch (levelManager.level) {
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
  }

// gera um novo desafio:
// 1. escolhe aleatoriamente um carácter alvo
// 2. cria opções erradas, garantindo unicidade e diferença do alvo
// 3. adiciona o número adequado de opções corretas (maiúsculas/minúsculas)
// 4. posiciona os itens no ecrã com espaçamento uniforme e sem sobreposição
  void generateNewChallenge() {
    setState(() {
      letterItems.clear();
    });
    foundCorrect = 0;
    roundTimer?.cancel();
    progressTimer?.cancel();
    currentTry = 0;
    progressValue = 1.0;

    final String rawChar = characters[_random.nextInt(characters.length)];
    targetCharacter = _isLetter(rawChar)
        ? (_random.nextBool() ? rawChar.toUpperCase() : rawChar.toLowerCase())
        : rawChar;

    Set<String> uniqueOptions = {};
    while (uniqueOptions.length < wrongCount) {
      String c = characters[_random.nextInt(characters.length)];
      String option = _isLetter(c)
          ? (_random.nextBool() ? c.toUpperCase() : c.toLowerCase())
          : c;
      if (option.toLowerCase() != targetCharacter.toLowerCase() &&
          !uniqueOptions.any((e) => e.toLowerCase() == option.toLowerCase())) {
        uniqueOptions.add(option);
      }
    }

    List<String> correctOptions = List.generate(correctCount, (_) {
      return _random.nextBool()
          ? targetCharacter.toUpperCase()
          : targetCharacter.toLowerCase();
    });

    final allOptions = [...uniqueOptions, ...correctOptions]..shuffle();

    final cols = (allOptions.length / 3).ceil();
    final spacingX = 1.0 / (cols + 1);
    final spacingY = 0.18;

    List<LetterItem> placedItems = [];

    // coloca os itens no ecrã, com espaçamento entre eles e evita sobreposição
    for (int i = 0; i < allOptions.length; i++) {
      final col = i % cols;
      final row = i ~/ cols;
      final dx = spacingX * (col + 1);
      final dy = 0.45 + spacingY * row;

      placedItems.add(
        LetterItem(
          character: allOptions[i],
          dx: dx,
          dy: dy,
          fontFamily: isFirstCycle ? _chooseRandomFont() : null,
          backgroundColor: _generateStrongColor(),
        ),
      );
    }

    // adiciona o item correto à lista de itens colocados
    setState(() {
      letterItems = placedItems;
    });

    final int totalMillis = levelTime.inMilliseconds;
    const tick = Duration(milliseconds: 100);
    int elapsed = 0;

    progressTimer = Timer.periodic(tick, (timer) {
      if (showSuccessAnimation) return;
      setState(() {
        elapsed += tick.inMilliseconds;
        progressValue = 1.0 - (elapsed / totalMillis);
      });
      if (elapsed >= totalMillis) {
        timer.cancel();
      }
    });

    // inicia o temporizador da rodada
    roundTimer = Timer(levelTime, () {
      if (showSuccessAnimation) return;
      GameAnimations.showTimeoutSnackbar(context);
      final bool firstTryCorrect = currentTry == correctCount;

      levelManager.registerRoundWithOptionalFeedback(
        context: context,
        correct: firstTryCorrect,
        applySettings: applyLevelSettings,
        onFinished: generateNewChallenge,
      );
    });
  }

  // verifica se a resposta do jogador está correta, dá os sons e animações correspondentes e atualiza o estado do jogo
  void checkAnswer(LetterItem selectedItem) {
    currentTry++;

    if (selectedItem.character.toLowerCase() == targetCharacter.toLowerCase()) {
      // se a resposta estiver correta, atualiza o estado, toca o som e mostra ícone de certo
      foundCorrect++;
      setState(() {
        selectedItem.isCorrect = true;
        selectedItem.showCheck = true;
        selectedItem.isTapped = true;
      });

      GameAnimations.playCorrectSound();

      if (foundCorrect >= correctCount) {
        roundTimer?.cancel();
        progressTimer?.cancel();
        final bool firstTryCorrect = currentTry == correctCount;

        setState(() {
          showSuccessAnimation = true;
        });

        // ao terminar a rodada com sucesso, apresenta uma animação de sucesso
        GameAnimations.successCoffetiesTimed();

        Future.delayed(const Duration(seconds: 1), () {
          if (!mounted) return;

          setState(() {
            showSuccessAnimation = false;
          });

          levelManager.registerRoundWithOptionalFeedback(
            context: context,
            correct: firstTryCorrect,
            applySettings: applyLevelSettings,
            onFinished: generateNewChallenge,
          );
        });
      }
    } else {
      // se a resposta estiver errada, atualiza o estado, toca o som de errado
      GameAnimations.playWrongSound();
    }
  }

  // constrói a interface do jogo, incluindo o layout e os elementos visuais
  @override
  Widget build(BuildContext context) {
    final Widget topTextWidget = Padding(
      padding: EdgeInsets.only(top: 10.h, bottom: 6.h),
      child: isFirstCycle && _isLetter(targetCharacter)
          ? Column(
              children: [
                Text(
                  'Encontra a letra',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    decoration: TextDecoration.none,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // se 1º ciclo, mostra a letra em duas fontes diferentes, caso contrário usa a fonte por defeito da app
                    Text(targetCharacter.toUpperCase(), style: TextStyle(fontSize: 24.sp, fontFamily: 'Slabo', decoration: TextDecoration.none)),
                    SizedBox(width: 8.w),
                    Text(targetCharacter.toUpperCase(), style: TextStyle(fontSize: 24.sp, fontFamily: 'Cursive', decoration: TextDecoration.none)),
                    SizedBox(width: 16.w),
                    Text(targetCharacter.toLowerCase(), style: TextStyle(fontSize: 24.sp, fontFamily: 'Slabo', decoration: TextDecoration.none)),
                    SizedBox(width: 8.w),
                    Text(targetCharacter.toLowerCase(), style: TextStyle(fontSize: 24.sp, fontFamily: 'Cursive', decoration: TextDecoration.none)),
                  ],
                ),
              ],
            )
          : Text(
              _isNumber(targetCharacter)
                  ? 'Encontra o número $targetCharacter'
                  : 'Encontra a letra ${targetCharacter.toUpperCase()}, ${targetCharacter.toLowerCase()}',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w600,
                color: Colors.blue[800],
                fontFamily: isFirstCycle ? 'Slabo' : null,
                decoration: TextDecoration.none,
              ),
              textAlign: TextAlign.center,
            ),
    );

    // desenha a interface do jogo, com base no widget games_design.dart
    return GamesDesign(
      user: widget.user,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: GameAnimations.buildTopInfo(
              progressValue: progressValue,
              level: levelManager.level,
              currentRound: levelManager.totalRoundsCount + 1,
              totalRounds: levelManager.evaluationRounds,
              topTextWidget: topTextWidget,
            ),
          ),
          ...letterItems.map((item) {
            return Align(
              alignment: Alignment(item.dx * 2 - 1, item.dy * 2 - 1),
              child: item.isTapped
                  ? const Icon(Icons.check, color: Colors.green, size: 30)
                  : GestureDetector(
                      onTap: () => checkAnswer(item),
                      child: Container(
                        width: 60.r,
                        height: 60.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: item.backgroundColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(2, 2),
                              blurRadius: 4.r,
                            )
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          item.character,
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
          if (showSuccessAnimation)
            IgnorePointer(
              ignoring: true,
              child: GameAnimations.successCoffetiesTimed(),
            ),
        ],
      ),
    );
  }
}

// classe para representar cada letra e numero no ecrã
// contém infiormações sobre a posição, estilo, cor de fundo e estado de cada caractere
class LetterItem {
  final String character;
  final double dx;
  final double dy;
  final String? fontFamily;
  final Color backgroundColor;
  bool isCorrect;
  bool isTapped = false;
  bool showCheck = false;

  // construtor da classe LetterItem
  LetterItem({
    required this.character,
    required this.dx,
    required this.dy,
    required this.backgroundColor,
    this.fontFamily,
    this.isCorrect = false,
  });
}

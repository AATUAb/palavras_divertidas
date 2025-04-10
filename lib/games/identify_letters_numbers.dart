// Estrutura para o jogo "Detetive de Letras e Números", que desafia os jogadores a identificar letras e números em um conjunto de opções.
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/level_manager.dart';
import '../widgets/games_animations.dart';
import '../models/user_model.dart';
import '../widgets/game_item.dart';
import '../widgets/games_design.dart';
import 'package:audioplayers/audioplayers.dart';

// Helper function to get the instruction font style
TextStyle getInstructionFont({required bool isFirstCycle}) {
  return TextStyle(
    fontSize: 22.sp,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    fontFamily: isFirstCycle ? 'ComicNeue' : null,
  );
}

// Widget to display character variants (uppercase and lowercase)
class CharacterFontVariants extends StatelessWidget {
  final String character;
  
  const CharacterFontVariants({Key? key, required this.character}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          character.toUpperCase(),
          style: TextStyle(fontSize: 32.sp, fontFamily: 'Slabo'),
        ),
        SizedBox(width: 8.w),
        Text(
          character.toUpperCase(),
          style: TextStyle(fontSize: 32.sp, fontFamily: 'Cursive'),
        ),
        SizedBox(width: 16.w),
        Text(
          character.toLowerCase(),
          style: TextStyle(fontSize: 32.sp, fontFamily: 'Slabo'),
        ),
        SizedBox(width: 8.w),
        Text(
          character.toLowerCase(),
          style: TextStyle(fontSize: 32.sp, fontFamily: 'Cursive'),
        ),
      ],
    );
  }
}


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
  List<GameItem> gamesItems = [];

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

  // AudioPlayer to control music
  final AudioPlayer _audioPlayer = AudioPlayer();

  // inicializa o estado do jogo
  @override
  void initState() {
    super.initState();
    isFirstCycle = widget.user.schoolLevel  == '1º Ciclo';
    levelManager = LevelManager(user: widget.user);

    // Pause any background music when entering the game
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Stop any playing music
      _audioPlayer.stop();
      
      // Initialize the game
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
      gamesItems.clear();
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

    List<GameItem> placedItems = [];

    // coloca os itens no ecrã, com espaçamento entre eles e evita sobreposição
    for (int i = 0; i < allOptions.length; i++) {
      final col = i % cols;
      final row = i ~/ cols;
      final dx = spacingX * (col + 1);
      final dy = 0.45 + spacingY * row;

      placedItems.add(
        GameItem(
          id: i.toString(),
          type: GameItemType.character,
          content: allOptions[i],
          dx: dx,
          dy: dy,
          fontFamily: isFirstCycle ? _chooseRandomFont() : null,
          backgroundColor: _generateStrongColor(),
          isCorrect: allOptions[i].toLowerCase() == targetCharacter.toLowerCase(),
        ));
      }

    // adiciona o item correto à lista de itens colocados
    setState(() {
      gamesItems = placedItems;
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

        levelManager.registerRoundForLevel(
        context: context,
        correct: firstTryCorrect,
        applySettings: applyLevelSettings,
        onFinished: generateNewChallenge,
      );
    });
  }

  // verifica se a resposta do jogador está correta, dá os sons e animações correspondentes
  // atualiza o estado visual do item tocado e gere o progresso da ronda e do nível
  void checkAnswer(GameItem selectedItem) {
  currentTry++;

  // Verifica se o conteúdo do item selecionado corresponde ao carácter alvo
  if (selectedItem.content.toLowerCase() == targetCharacter.toLowerCase()) {
    foundCorrect++;  // no caso de respostas correcata, incrementa o contador de acertos
    GameAnimations.playCorrectSound(); // Toca o som de resposta correta

     // Marca o item como 'tocado' e correto para apresentar o ícone no ecrã
    setState(() {
      selectedItem.isTapped = true;
      selectedItem.isCorrect = true;
    });

    // Se o número de acertos já for suficiente para concluir a ronda:
    if (foundCorrect >= correctCount) {
      roundTimer?.cancel();
      progressTimer?.cancel();
      final bool firstTryCorrect = currentTry == correctCount;     // Verifica se o jogador acertou tudo à primeira tentativa

      // Ativa o estado de animação de sucesso (confetis)
      setState(() {
        showSuccessAnimation = true;
      });

      GameAnimations.coffetiesTimed();   // Mostra a animação de sucesso temporariamente

      // Espera 1 segundo para terminar a animação antes de avançar para a próxima ronda
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
         // Esconde a animação de sucesso e avança para a próxima ronda
        setState(() => showSuccessAnimation = false);
        levelManager.registerRoundForLevel(
          context: context,
          correct: firstTryCorrect,
          applySettings: applyLevelSettings,
          onFinished: generateNewChallenge,
        );
      });
    }
  } else {
    // Caso a resposta esteja errada, toca o som de erro e marca o item como 'tocado' e incorreto, para mostrar ícone
    GameAnimations.playWrongSound();
    setState(() {
      selectedItem.isTapped = true;
      selectedItem.isCorrect = false;
    });
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
                style: getInstructionFont(isFirstCycle: isFirstCycle),
              ),
              CharacterFontVariants(character: targetCharacter),
            ],
          )
        : Text(
            _isNumber(targetCharacter)
                ? 'Encontra o número $targetCharacter'
                : 'Encontra a letra ${targetCharacter.toUpperCase()}, ${targetCharacter.toLowerCase()}',
            style: getInstructionFont(isFirstCycle: isFirstCycle),
            textAlign: TextAlign.center,
          ),
  );

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
        ...gamesItems.map((item) {
          return Align(
            alignment: Alignment(item.dx * 2 - 1, item.dy * 2 - 1),
            child: item.isTapped
                ? Icon(
                    item.isCorrect ? Icons.check : Icons.close,
                    color: item.isCorrect ? Colors.green : Colors.red,
                    size: 32.sp,
                  )
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
            child: GameAnimations.coffetiesTimed(),
          ),
      ],
    ),
  );
}
}

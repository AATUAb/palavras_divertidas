//Estrutura principal do jogo "Detetive de letras e números". Jogo 1

import 'package:flutter/material.dart';
import 'dart:math';
import '../themes/text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';

// Widget principal com estado que representa o jogo
class IdentifyLettersNumbersGame extends StatefulWidget {
  const IdentifyLettersNumbersGame({super.key});

  @override
  _IdentifyLettersNumbersGameState createState() => _IdentifyLettersNumbersGameState();
}

class _IdentifyLettersNumbersGameState extends State<IdentifyLettersNumbersGame> {
  // Lista de letras e números usados no jogo
  final List<String> characters = [
    ...'ABCDEFGHIJLMNOPQRSTUVXZ'.split(''),
    ...'abcdefghijlmnopqrstuvxz'.split(''),
    ...'0123456789'.split(''),
  ];

  final Random _random = Random(); // Gerador de números aleatórios
  final double spacing = 10; // Espaçamento mínimo entre caracteres na tela

  int level = 1; // Nível atual do jogo
  int correctCount = 4; // Quantidade de caracteres corretos a exibir
  int wrongCount = 5; // Quantidade de caracteres errados a exibir
  Duration levelTime = const Duration(seconds: 10); // Tempo por rodada

  int totalRounds = 0; // Rodadas jogadas
  int firstTryCorrect = 0; // Acertos na primeira tentativaS
  int currentTry = 0; // Tentativas na rodada atual

  String targetCharacter = ''; // Caractere que o jogador deve encontrar
  List<_LetterItem> letterItems = []; // Lista de itens posicionados na tela
  Timer? roundTimer; // Timer da rodada

  // Inicializa o jogo após o build da interface
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      applyLevelSettings(); // Aplica as configurações do nível
      generateNewChallenge(); // Gera o primeiro desafio
    });
  }

  // Define os parâmetros do jogo conforme o nível atual
  void applyLevelSettings() {
    switch (level) {
      case 1:
        correctCount = 4;
        wrongCount = 5;
        levelTime = const Duration(seconds: 10);
        break;
      case 2:
        correctCount = 5;
        wrongCount = 8;
        levelTime = const Duration(seconds: 15);
        break;
      case 3:
        correctCount = 6;
        wrongCount = 12;
        levelTime = const Duration(seconds: 20);
        break;
      default:
        correctCount = 4;
        wrongCount = 5;
        levelTime = const Duration(seconds: 10);
    }
  }

  // Gera um novo desafio com novos caracteres e posições
  void generateNewChallenge() {
    double collisionRadius = 80.r; // Raio mínimo de exclusão (em pixels)
    roundTimer?.cancel(); // Cancela o timer anterior
    currentTry = 0;

    // Escolhe um caractere aleatório e define se será maiúsculo ou minúsculo
    final String rawChar = characters[_random.nextInt(characters.length)];
    targetCharacter = _isLetter(rawChar)
        ? (_random.nextBool() ? rawChar.toUpperCase() : rawChar.toLowerCase())
        : rawChar;

    // Gera opções incorretas únicas que não são iguais ao alvo
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

    // Cria uma lista com as opções corretas e mistura com as erradas
    List<String> correctOptions = List.generate(correctCount, (_) => targetCharacter);
    final allOptions = [...uniqueOptions, ...correctOptions]..shuffle();

    // Define limites de posicionamento na tela
    final double minX = 0.05;
    final double maxX = 0.95;
    final double minY = 0.20;
    final double maxY = 0.85;

    // Posiciona cada caractere na tela garantindo que não se sobreponham
    final List<_LetterItem> placedItems = [];
    final List<Offset> usedPositions = [];

    for (String char in allOptions) {
      double dx, dy;
      Offset pos;
      int attempts = 0;

      do {
        dx = _random.nextDouble() * (maxX - minX) + minX;
        dy = _random.nextDouble() * (maxY - minY) + minY;
        pos = Offset(dx, dy);
        attempts++;
        if (attempts > 100) break;
      } while (_overlaps(pos, usedPositions, collisionRadius));


      usedPositions.add(pos);
      placedItems.add(_LetterItem(character: char, dx: dx, dy: dy));
    }

    // Atualiza o estado com os novos itens
    setState(() {
      letterItems = placedItems;
    });

    // Inicia o timer da rodada
    roundTimer = Timer(levelTime, () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tempo esgotado! ⏰',
            style: AppTextStyles.body.copyWith(fontSize: 16.sp, color: Colors.white),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      _finishRound(firstTry: false);
    });
  }

  // Finaliza a rodada, atualiza estatísticas e define o novo nível, se necessário
  void _finishRound({required bool firstTry}) {
    roundTimer?.cancel();
    totalRounds++;
    if (firstTry) firstTryCorrect++;

    // Avalia o desempenho e ajusta o nível
    if (totalRounds >= 4) {
      double accuracy = firstTryCorrect / totalRounds;
      if (accuracy >= 0.8 && level < 3) level++;
      if (accuracy < 0.5 && level > 1) level--;
      totalRounds = 0;
      firstTryCorrect = 0;
      applyLevelSettings();
    }

    generateNewChallenge(); // Gera novo desafio
  }

  // Verifica se duas posições estão muito próximas
  bool _overlaps(Offset pos, List<Offset> others, double radius) {
  for (final other in others) {
    final dx = (pos.dx - other.dx) * MediaQuery.of(context).size.width;
    final dy = (pos.dy - other.dy) * MediaQuery.of(context).size.height;
    if (sqrt(dx * dx + dy * dy) < radius) return true;
  }
  return false;
  }


  // Verifica se o caractere é uma letra
  bool _isLetter(String char) => RegExp(r'[a-zA-Z]').hasMatch(char);

  // Verifica se o caractere é um número
  bool _isNumber(String char) => RegExp(r'[0-9]').hasMatch(char);

  // Função chamada ao clicar em um caractere, verifica se é o correto
  void checkAnswer(String selected) {
    roundTimer?.cancel();
    currentTry++;
    if (selected == targetCharacter) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Correto! 🎉',
            style: AppTextStyles.body.copyWith(fontSize: 16.sp, color: Colors.white),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
      _finishRound(firstTry: currentTry == 1);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tenta novamente! ❌',
            style: AppTextStyles.body.copyWith(fontSize: 16.sp, color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  // Cancela o timer ao destruir o widget
  @override
  void dispose() {
    roundTimer?.cancel();
    super.dispose();
  }

// Monta a interface do jogo com os caracteres espalhados na tela
  @override
  Widget build(BuildContext context) {
    final String topText = _isNumber(targetCharacter)
        ? 'Encontra o número $targetCharacter'
        : 'Encontra a letra ${targetCharacter.toUpperCase()}, ${targetCharacter.toLowerCase()}';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detetive de letras e números',
          style: AppTextStyles.body.copyWith(fontSize: 18.sp, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Text(
                  topText,
                  style: AppTextStyles.title.copyWith(fontSize: 26.sp),
                ),
              ),
            ),
            // Exibe os botões dos caracteres em posições aleatórias
            ...letterItems.map((item) {
              return Align(
                alignment: Alignment(item.dx * 2 - 1, item.dy * 2 - 1),
                child: TextButton(
                  onPressed: () => checkAnswer(item.character),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    item.character,
                    style: AppTextStyles.bodyBold.copyWith(fontSize: 30.sp),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

// Classe auxiliar que representa um caractere com posição na tela
class _LetterItem {
  final String character;
  final double dx;
  final double dy;

  _LetterItem({required this.character, required this.dx, required this.dy});
}

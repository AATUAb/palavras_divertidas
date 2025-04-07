// estrutura de um item do jogo, pode ser um caractér, palavra, imagem ou som
// pode ser aplicado em todos os jogos, ainda que o conteúdo dos jogos seja diferente

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math';

// tipos de item de jogo
enum GameItemType {
  text, // letras, palavras, frases
  image, // imagem
  audio, // som
  character, // letras ou numeros isolados
}

// tipos de fonte possíveis para os itens de jogo
enum FontStrategy {
  none, // usa a fonte por defeito da app
  slabo, // força a fonte Slabo
  cursive, // força a fonte Cursive
  random, // aleatoriamente entre Slabo e Cursive
}

// função utilitária para obter o nome da fonte com base na estratégia
String? getFontFamily(FontStrategy strategy) {
  final _random = Random();
  switch (strategy) {
    case FontStrategy.none:
      return null;
    case FontStrategy.slabo:
      return 'Slabo';
    case FontStrategy.cursive:
      return 'Cursive';
    case FontStrategy.random:
      return _random.nextBool() ? 'Slabo' : 'Cursive';
  }
}

// classe para representar um item de jogo
class GameItem {
  final String id;
  final GameItemType type;
  final String content;
  final double dx;
  final double dy;
  final String? fontFamily;
  final Color backgroundColor;
  bool isCorrect;
  bool isTapped;
  bool showCheck = false;

  GameItem({
    required this.id,
    required this.type,
    required this.content,
    required this.dx,
    required this.dy,
    required this.backgroundColor,
    this.fontFamily,
    this.isCorrect = false,
    this.isTapped = false,
  });

  // métodos para desenhar um tipo de item e permitir a sua visualização no ecrã
  Widget buildWidget() {
    switch (type) {
      case GameItemType.character:
      case GameItemType.text:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: fontFamily,
              decoration: TextDecoration.none,
            ),
          ),
        );
      case GameItemType.image:
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: backgroundColor,
          ),
          padding: const EdgeInsets.all(8),
          child: Image.asset(
            content,
            height: 80,
            width: 80,
            fit: BoxFit.contain,
          ),
        );
      case GameItemType.audio:
        return Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: const Icon(Icons.volume_up, color: Colors.white, size: 36),
        );
    }
  }
}

// estilo das instruções do topo adaptado ao nível de escolaridade
TextStyle getInstructionFont({required bool isFirstCycle}) {
  return TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    decoration: TextDecoration.none,
    fontFamily: isFirstCycle ? 'Slabo' : null,
  );
}

// classe para apresentar variantes de fonte para letras no 1º ciclo
class CharacterFontVariants extends StatelessWidget {
  final String character;

  const CharacterFontVariants({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          character.toUpperCase(),
          style: TextStyle(
            fontSize: 24.sp,
            fontFamily: 'Slabo',
            decoration: TextDecoration.none,
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          character.toUpperCase(),
          style: TextStyle(
            fontSize: 24.sp,
            fontFamily: 'Cursive',
            decoration: TextDecoration.none,
          ),
        ),
        SizedBox(width: 16.w),
        Text(
          character.toLowerCase(),
          style: TextStyle(
            fontSize: 24.sp,
            fontFamily: 'Slabo',
            decoration: TextDecoration.none,
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          character.toLowerCase(),
          style: TextStyle(
            fontSize: 24.sp,
            fontFamily: 'Cursive',
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}

// estrutura de um item do jogo, pode ser um caractér, palavra, imagem ou som
// pode ser aplicado em todos os jogos, ainda que o conteúdo dos jogos seja diferente

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// tipos de item de jogo
enum GameItemType {
  text, // letras, palavras, frases
  image, // imagem
  audio, // som
  character, // letras ou numeros isolados
}

// tipos de fonte possiveis para os itens de jogo
enum FontStrategy {
  none, // usa a fonte por defeito da app
  slabo, // força a fonte Slabo
  cursive, // força a fonte Cursive
  random, // aleatoriamente entre Slabo e Cursive
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
  bool isTapped = false;
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
}

/* /// apresenta a fonte Slabo ou Cursive, com 50% de probabilidade de cada uma
  final Random _random = Random();
  String? getFontFamily(FontStrategy strategy) {
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
  }*/

/// Para situações em que usa sempre usa sempre a fonte Slabo no 1º ciclo, e null no pré-escolar, como as intsruções
TextStyle getInstructionFont({required bool isFirstCycle}) {
  return TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    decoration: TextDecoration.none,
    fontFamily: isFirstCycle ? 'Slabo' : null,
  );
}

// classe para permitir fontes aleatórias entre Slabo e Cursive para o 1º ciclo
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

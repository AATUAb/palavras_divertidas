import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math';

// Tipos de item de jogo
enum GameItemType {
  text,        // letras, palavras ou frases
  image,       // imagens
  audio,       // sons
  character,   // letras ou números isolados
  number,      // números isolados
}

// Estratégias de fonte a aplicar ao conteúdo textual
enum FontStrategy {
  none,     // fonte padrão da app
  slabo,    // força fonte Slabo
  cursive,  // força fonte Cursive
  random,   // aleatória entre Slabo e Cursive
}

// Devolve o nome da fonte com base na estratégia definida
String? getFontFamily(FontStrategy strategy) {
  final _random = Random();
  switch (strategy) {
    case FontStrategy.none:
      return null;
    case FontStrategy.slabo:
      return 'Slabo';
    case FontStrategy.cursive:
      return 'Cursive-Regular';
    case FontStrategy.random:
      return _random.nextBool() ? 'Slabo' : 'Cursive';
  }
}

// Estrutura de um item do jogo (letra, imagem, som, etc.)
class GameItem {
  final String id;
  final GameItemType type;
  final String content;
  final double dx;
  final double dy;
  final String? fontFamily;
  final double? fontSize;
  final Color backgroundColor;
  final bool playCaseSuffix;
  bool isCorrect;
  bool isTapped;
  bool showCheck = false;


  GameItem({
    required this.id,
    required this.type,
    required this.content,
    required this.dx,
    required this.dy,
    this.fontFamily,
    this.fontSize,
    required this.backgroundColor,
    this.playCaseSuffix = false,
    this.isCorrect = false,
    this.isTapped = false,
  });

  /// Retorna true se o item for um carácter isolado (letra ou número)
  bool get isCharacter =>
      type == GameItemType.character || (type == GameItemType.text && content.length == 1);

  /// Retorna true se o item for uma palavra simples (sem espaços, mais de 1 letra)
  bool get isWord =>

      type == GameItemType.text &&
      content.trim().length > 1 &&
      !content.contains(' ');

  /// Constrói o widget visual do item com base no seu tipo
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
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: fontFamily,
              fontSize: fontSize ?? 22.sp,
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

        case GameItemType.number:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: fontFamily,
              decoration: TextDecoration.none,
            ),
          ),
        );
    }
  }
}

// Widget para mostrar variantes de fontes (Slabo e Cursive) para uma letra
class CharacterFontVariants extends StatelessWidget {
  final String character;

  const CharacterFontVariants({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _styledChar(character.toUpperCase(), 'Slabo'),
        SizedBox(width: 8.w),
        _styledChar(character.toUpperCase(), 'Cursive'),
        SizedBox(width: 16.w),
        _styledChar(character.toLowerCase(), 'Slabo'),
        SizedBox(width: 8.w),
        _styledChar(character.toLowerCase(), 'Cursive'),
      ],
    );
  }

  Widget _styledChar(String char, String font) {
    return Text(
      char,
      style: TextStyle(
        fontSize: 24.sp,
        fontFamily: font,
        decoration: TextDecoration.none,
      ),
    );
  }
}

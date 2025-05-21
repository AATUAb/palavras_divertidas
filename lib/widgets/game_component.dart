import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'game_item.dart';
import '../models/user_model.dart';

/// Mostra uma palavra em destaque dentro de uma caixa verde arredondada.
class WordHighlightBox extends StatelessWidget {
  final String word;
  final UserModel user;

  const WordHighlightBox({
    super.key,
    required this.word,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final isFirstCycle = user.schoolLevel == '1º Ciclo';
    final fontSize = isFirstCycle ? 26.sp : 22.sp;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4.r,
            offset: Offset(2, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        word,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: isFirstCycle ? 'Cursive' : null,
        ),
      ),
    );
  }
}


/// Mostra uma imagem dentro de um cartão verde-claro com sombra.
class ImageCardBox extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;

  const ImageCardBox({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final double scaledWidth = (width ?? 150).w;
    final double scaledHeight = (height ?? 80).h;
    return Container(
      width: scaledWidth,
      height: scaledHeight,
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6.r,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

/// Componente visual genérico que pode ser usado quando o jogo quiser mostrar uma palavra e uma imagem lado a lado.
/// Este componente não impõe alinhamentos, espaçamentos ou posições. O layout final é da responsabilidade do jogo.
class WordAndImageRow extends StatelessWidget {
  final Widget wordBox;
  final Widget imageBox;

  const WordAndImageRow({
    super.key,
    required this.wordBox,
    required this.imageBox,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        wordBox,
        imageBox,
      ],
    );
  }
}

/// Botão adaptável para múltiplas escolhas com texto flexível.
class FlexibleAnswerButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final UserModel user;

  const FlexibleAnswerButton({
    super.key,
    required this.user,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isFirstCycle = user.schoolLevel == '1º Ciclo';
    final fontSize = isFirstCycle ? 26.sp : 22.sp;

    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 70.w, maxWidth: 130.w),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        ),
        onPressed: onTap,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              fontFamily: isFirstCycle ? 'Cursive' : null,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

/// Linha de botões de resposta adaptável
class AnswerButtonsRow extends StatelessWidget {
  final List<GameItem> items;
  final void Function(GameItem) onTap;
  final UserModel user;

  const AnswerButtonsRow({
    super.key,
    required this.items,
    required this.onTap,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12.w,
      runSpacing: 10.h,
      children: items.map((item) {
        return FlexibleAnswerButton(
          label: item.content,
          onTap: () => onTap(item),
          user: user,
        );
      }).toList(),
    );
  }
}

// Circulo com um caractere no interior
class CharacterCircleBox extends StatelessWidget {
  final String character;
  final Color color;
  final UserModel user;
  final String? fontFamily;

  const CharacterCircleBox({
    super.key,
    required this.character,
    required this.color,
    required this.user,
    required this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60.w,
      height: 60.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
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
        character,
        style: TextStyle(
          fontSize: 26.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: fontFamily,
        ),
      ),
    );
  }
}
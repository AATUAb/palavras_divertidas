import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../themes/colors.dart';
import '../screens/game_menu.dart';
import '../widgets/menu_design.dart';

class GameDesign extends StatefulWidget {
  final Widget child;
  final dynamic user;
  final Widget? topTextWidget;
  final double? progressValue;
  final int level;
  final bool allowImmediateExit;
  final VoidCallback? onShowTutorial;

  const GameDesign({
    super.key,
    required this.child,
    required this.user,
    this.topTextWidget,
    this.progressValue,
    required this.level,
    this.allowImmediateExit = false,
    this.onShowTutorial,
  });

  @override
  State<GameDesign> createState() => _GameDesignState();
}

class _GameDesignState extends State<GameDesign> {
  @override
  void initState() {
    super.initState();
     pauseMenuMusic();
  }

  @override
void dispose() {
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fundo branco
          Container(color: Colors.white),

          // 🌊 Faixa superior com instrução embutida
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: TopWave(child: widget.topTextWidget),
          ),

          // Conteúdo principal do jogo
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(top: 0.h), // ⬅️ altura inicial da grelha
              child: widget.child,
            ),
          ),

          // ❌ Botão fechar app
          Positioned(
            top: 10.h,
            right: 10.w,
            child: IconButton(
              icon: Icon(
                Icons.close_rounded,
                color: AppColors.red,
                size: 30.sp,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Fechar App',
              onPressed: () => SystemNavigator.pop(),
            ),
          ),

          // 🏠 Botão voltar ao menu
          Positioned(
            top: 10.h,
            left: 10.w,
            child: IconButton(
              icon: Icon(Icons.home, color: AppColors.orange, size: 30.sp),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Voltar ao Menu de Jogos',
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameMenu(user: widget.user),
                  ),
                );
              },
            ),
          ),

          // ★ Indicador de nível (estrelas)
          Positioned(
            top: 70.h,
            right: 10.w, // desloca um pouco à esquerda do botão fechar
            child: Row(
              children: List.generate(
                widget.level,
                (_) => Padding(
                  padding: EdgeInsets.only(left: 2.w),
                  child: Icon(Icons.star, size: 30.sp, color: AppColors.orange),
                ),
              ),
            ),
          ),

          // ℹ️ Botão de tutorial
Positioned(
  bottom: 10.h,
  left: 10.w,
  child: IconButton(
    icon: Icon(Icons.question_mark_outlined,
      color: AppColors.orange,
      size: 30.sp,
    ),
    tooltip: 'Tutorial',
    onPressed: () {
      if (widget.onShowTutorial != null) {
        widget.onShowTutorial!();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Tutorial em breve",
              style: TextStyle(fontSize: 14.sp, color: AppColors.white),
            ),
            backgroundColor: AppColors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    },
  ),
),

          // ⏳ Barra de tempo (se fornecida)
          if (widget.progressValue != null)
            Positioned(
              bottom: 20.h,
              right: 20.w,
              child: SizedBox(
                width: 100.w,
                height: 8.h,
                child: LinearProgressIndicator(
                  value: widget.progressValue,
                  backgroundColor: Colors.grey[300],
                  color: AppColors.orange,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Estilo comum para instruções no topo, ajustado ao nível de escolaridade
TextStyle getInstructionFont({required bool isFirstCycle}) {
  return TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    decoration: TextDecoration.none,
    fontFamily: isFirstCycle ? 'Slabo' : null,
  );
}

// Widget decorativo da parte superior com curva e conteúdo opcional
class TopWave extends StatelessWidget {
  final Widget? child;

  const TopWave({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100.h,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Curva verde
          Positioned.fill(child: CustomPaint(painter: CloudPainter())),

          // Instrução
          if (child != null)
            Padding(padding: EdgeInsets.only(top: 0.h), child: child),
        ],
      ),
    );
  }
}

// Curva do topo do ecrã com pintura personalizada
class CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.green;
    final path = Path();

    path.lineTo(0, size.height * 0.6);
    path.quadraticBezierTo(
      size.width * 0.1,
      size.height,
      size.width * 0.25,
      size.height * 0.7,
    );
    path.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.4,
      size.width * 0.5,
      size.height * 0.7,
    );
    path.quadraticBezierTo(
      size.width * 0.6,
      size.height,
      size.width * 0.75,
      size.height * 0.6,
    );
    path.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.3,
      size.width,
      size.height * 0.6,
    );
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

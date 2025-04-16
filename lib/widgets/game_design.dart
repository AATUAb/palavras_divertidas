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

  const GameDesign({
    super.key,
    required this.child,
    required this.user,
    this.topTextWidget,
    this.progressValue,
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
    resumeMenuMusic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fundo branco
          Container(color: Colors.white),

          // Topo com curva verde
          const Positioned(top: 0, left: 0, right: 0, child: _TopCurve()),

          if (widget.topTextWidget != null)
            Positioned(
              top: 0.h,
              left: 0,
              right: 0,
              child: Center(
                child: DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 1,
                  child: widget.topTextWidget!,
                ),
              ),
            ),

          // Conteúdo principal do jogo
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(top: 120.h),
              child: widget.child,
            ),
          ),

          // Botão home
          Positioned(
            top: 10.h,
            left: 10.w,
            child: IconButton(
              icon: Icon(Icons.home, size: 30.sp),
              tooltip: 'Voltar ao Menu de Jogos',
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GameMenu(user: widget.user),
                  ),
                );
              },
            ),
          ),

          // Botão fechar app
          Positioned(
            top: 10.h,
            right: 10.w,
            child: IconButton(
              icon: Icon(
                Icons.close_rounded,
                color: AppColors.red,
                size: 30.sp,
              ),
              tooltip: 'Fechar App',
              onPressed: () => SystemNavigator.pop(),
            ),
          ),

          // Botão tutorial
          Positioned(
            bottom: 10.h,
            left: 10.w,
            child: IconButton(
              icon: Icon(Icons.info_outline, size: 30.sp),
              tooltip: 'Tutorial',
              onPressed: () {
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
              },
            ),
          ),

          // Barra de progresso (se fornecida)
          if (widget.progressValue != null)
            Positioned(
              bottom: 20.h,
              right: 20.w,
              child: SizedBox(
                width: 100.w,
                height: 5.h,
                child: LinearProgressIndicator(
                  value: widget.progressValue,
                  backgroundColor: Colors.grey[300],
                  color: Colors.orange,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Estilo para instruções (usado nos jogos)
TextStyle getInstructionFont({required bool isFirstCycle}) {
  return TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    decoration: TextDecoration.none,
    fontFamily: isFirstCycle ? 'Slabo' : null,
  );
}

// Curva verde decorativa do topo
class _TopCurve extends StatelessWidget {
  const _TopCurve();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110.h,
      width: double.infinity,
      child: CustomPaint(painter: _CloudPainter()),
    );
  }
}

class _CloudPainter extends CustomPainter {
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../themes/colors.dart';
import '../screens/game_menu.dart';
import '../widgets/menu_design.dart';

class GamesDesign extends StatefulWidget {
  final Widget child;
  final dynamic user;
  final Widget? topTextWidget; // ✅ Título ou instrução opcional no topo

  const GamesDesign({
    super.key,
    required this.child,
    required this.user,
    this.topTextWidget,
  });

  @override
  State<GamesDesign> createState() => _GamesDesignState();
}

class _GamesDesignState extends State<GamesDesign> {
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
          Container(color: Colors.white),
          const Positioned(top: 0, left: 0, right: 0, child: TopWave()),

          // 🧠 Instrução no topo (alinhada para todos os jogos)
          Positioned(
            top: 20.h,
            left: 0,
            right: 0,
            child: widget.topTextWidget ?? const SizedBox.shrink(),
          ),

          // Conteúdo principal
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                top: 90.h,
              ), // ⬅️ espaço reservado p/ instrução
              child: widget.child,
            ),
          ),

          // Fechar app
          Positioned(
            top: 10.h,
            right: 10.w,
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                decoration: const BoxDecoration(
                  border: Border.fromBorderSide(
                    BorderSide(color: Colors.black),
                  ),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppColors.red,
                    size: 20.sp,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Fechar App',
                  onPressed: () => SystemNavigator.pop(),
                ),
              ),
            ),
          ),

          // Botão Home
          Positioned(
            top: 10.h,
            left: 10.w,
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                decoration: const BoxDecoration(
                  border: Border.fromBorderSide(
                    BorderSide(color: Colors.black),
                  ),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.home, color: AppColors.black, size: 30.sp),
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
            ),
          ),

          // Botão de informação
          Positioned(
            bottom: 10.h,
            left: 10.w,
            child: IconButton(
              icon: Icon(Icons.info_outline, color: Colors.black, size: 28.sp),
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
        ],
      ),
    );
  }
}

class TopWave extends StatelessWidget {
  const TopWave({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90.h,
      width: double.infinity,
      child: CustomPaint(painter: CloudPainter()),
    );
  }
}

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

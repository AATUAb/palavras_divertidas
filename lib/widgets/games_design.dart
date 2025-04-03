import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../themes/colors.dart'; 
import '../screens/game_menu.dart';

class GamesDesign extends StatelessWidget {
  final Widget child;
  final dynamic user; 
  const GamesDesign({super.key, required this.child, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
        // Fundo branco da página
        Container(color: Colors.white),

        // Topo com formato "nuvem"
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: TopWave(),
        ),

        // Conteúdo principal (filho)
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.only(top: 3.h),
            child: child,
          ),
        ),

        // Botão de Fechar (Top-Right)
        Positioned(
          top: 10.h,
          right: 10.w,
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.close_rounded, color: AppColors.red, size: 20.sp),
                padding: EdgeInsets.zero, // Remove default padding
                constraints: const BoxConstraints(), // Remove default constraints
                tooltip: 'Fechar App', // Optional: Add tooltip
                onPressed: () {
                  SystemNavigator.pop(); // Fecha a aplicação
                },
              ),
            ),
          ),
        ),

        // Botão de Home, para regressão ao menu de jogos
        Positioned(
          top: 10.h,
          left: 10.w,
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.home, color: AppColors.black, size: 20.sp),
                padding: EdgeInsets.zero, // Remove default padding
                constraints: const BoxConstraints(), // Remove default constraints
                tooltip: 'Voltar ao Menu de Jogos', // Optional: Add tooltip
                onPressed: () {
                  // Redireciona para a página principal de jogos (GameMenu)
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameMenu(user: user), 
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        // Botão de Informação (Bottom-Left)
        Positioned(
          bottom: 10.h,
          left: 10.w,
          child: IconButton(
            icon: Icon(Icons.info_outline, color: Colors.black, size: 28.sp), // Use outline for distinction if needed
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Tutorial em breve",
                    style: TextStyle(fontSize: 14.sp, color: AppColors.white),
                  ),
                  backgroundColor: AppColors.green, // Use theme color
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

static Widget buildChallengeHeader({
  required String title,
  String? subtitle1,
  String? subtitle2,
}) {
  return Column(
    children: [
      Text(
        title,
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      if (subtitle1 != null && subtitle2 != null)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(subtitle1, style: TextStyle(fontSize: 24.sp, fontFamily: 'Slabo')),
            SizedBox(width: 8.w),
            Text(subtitle1, style: TextStyle(fontSize: 24.sp, fontFamily: 'Cursive')),
            SizedBox(width: 16.w),
            Text(subtitle2, style: TextStyle(fontSize: 24.sp, fontFamily: 'Slabo')),
            SizedBox(width: 8.w),
            Text(subtitle2, style: TextStyle(fontSize: 24.sp, fontFamily: 'Cursive')),
          ],
        ),
         ],
    );
  }
}

// desenhar  a nuvem com CustomPainter
class TopWave extends StatelessWidget {
  const TopWave({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90.h,
      width: double.infinity,
      child: CustomPaint(
        painter: CloudPainter(),
      ),
    );
  }
}
// Pintor da nuvem com bolhas arredondadas
class CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.green;

    final path = Path();
    path.lineTo(0, size.height * 0.6);

    // Ondulações estilo nuvem
    path.quadraticBezierTo(
      size.width * 0.1, size.height,
      size.width * 0.25, size.height * 0.7,
    );
    path.quadraticBezierTo(
      size.width * 0.4, size.height * 0.4,
      size.width * 0.5, size.height * 0.7,
    );
    path.quadraticBezierTo(
      size.width * 0.6, size.height,
      size.width * 0.75, size.height * 0.6,
    );
    path.quadraticBezierTo(
      size.width * 0.9, size.height * 0.3,
      size.width, size.height * 0.6,
    );

    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

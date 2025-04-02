import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MenuDesign extends StatelessWidget {
  final Widget child;

  const MenuDesign({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
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

        // Sol no canto superior esquerdo
        Positioned(
          top: -70.h,
          left: 12.w,
          child: Image.asset(
            'assets/images/sun.png',
            width: 300.w,
            height: 300.h,
              fit: BoxFit.contain,
          ),
        ),

        // "Mundo das Palavras" no canto superior direito
        Positioned(
          top: 15.h,
          right: 20.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Mundo das',
                style: TextStyle(
                  fontSize: 40.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                  shadows: const [
                    Shadow(offset: Offset(1, 1), blurRadius: 1),
                  ],
                ),
              ),
              Text(
                'Palavras',
                style: TextStyle(
                  fontSize: 40.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                  shadows: const [
                    Shadow(offset: Offset(1, 1), blurRadius: 1),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Conteúdo principal (filho)
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.only(top: 40.h),
            child: child,
          ),
        ),
      ],
    );
  }
}

// Widget que desenha a nuvem com CustomPainter
class TopWave extends StatelessWidget {
  const TopWave({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110.h,
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

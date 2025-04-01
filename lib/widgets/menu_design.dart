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

        // Imagem no topo como fundo decorativo
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Image.asset(
            'assets/images/sun_cloud.png',
            fit: BoxFit.fitWidth,
            width: double.infinity,
          ),
        ),

        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.only(top: 40.h, bottom: 0.h),
            child: child,
          ),
        ),

        /*  // Rodapé com lápis (também sobreposto)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Image.asset(
              'assets/images/pencils.png',
              fit: BoxFit.fitWidth,
              width: double.infinity,
            ),
          ),
        ),*/
      ],
    );
  }
}

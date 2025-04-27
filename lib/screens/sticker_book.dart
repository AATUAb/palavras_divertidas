import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../themes/colors.dart';
import '../widgets/menu_design.dart';
import 'game_menu.dart';

class StickerBookScreen extends StatelessWidget {
  final dynamic user;
  const StickerBookScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MenuDesign(
        headerText: 'Conquistas',
        showHomeButton: true,
        onHomePressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => GameMenu(user: user)),
          );
        },
        child: Stack(
          children: [
            // Mapa de fundo, cheio, logo abaixo da ondulação
            Positioned.fill(
              top: 40.h,
              child: Image.asset('assets/images/earth.png', fit: BoxFit.cover),
            ),

            // Aqui poderás posicionar depois os teus stickers...
          ],
        ),
      ),
    );
  }
}

// lib/screens/sticker_book.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/menu_design.dart';
import 'game_menu.dart';

class StickerBookScreen extends StatefulWidget {
  final dynamic user;
  const StickerBookScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<StickerBookScreen> createState() => _StickerBookScreenState();
}

class _StickerBookScreenState extends State<StickerBookScreen> {
  // armazena o nº de conquistas localmente (demo)
  late int _localConquest;

  @override
  void initState() {
    super.initState();
    _localConquest = (widget.user.conquest as int?) ?? 0;
  }

  /// Destrava 1 conquista
  void _unlockOne() {
    setState(() {
      _localConquest++;
      widget.user.conquest = _localConquest;
      widget.user.save();
    });
  }

  /// Re-bloqueia todas as conquistas (modo dev)
  void _lockAll() {
    setState(() {
      _localConquest = 0;
      widget.user.conquest = 0;
      widget.user.save();
    });
  }

  @override
  Widget build(BuildContext context) {
    const double mapAspectRatio = 1.55;

    return Scaffold(
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'unlock',
            tooltip: 'Destravar um sticker',
            child: const Icon(Icons.lock_open),
            onPressed: _unlockOne,
          ),
          SizedBox(height: 5.h),
          FloatingActionButton(
            heroTag: 'lock',
            tooltip: 'Re-bloquear todos',
            child: const Icon(Icons.lock),
            onPressed: _lockAll,
          ),
        ],
      ),

      body: MenuDesign(
        headerText: 'Conquistas',
        showHomeButton: true,
        onHomePressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => GameMenu(user: widget.user)),
          );
        },
        // 1️⃣ Mapa de fundo, por baixo da curva verde
        background: Padding(
          padding: EdgeInsets.only(top: 90.h),
          child: Center(
            child: AspectRatio(
              aspectRatio: mapAspectRatio,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/earth.png',
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Sticker do macaco
                  Align(
                    alignment: const Alignment(-0.35, 0.5),
                    child: _buildSticker(
                      'assets/stickers/monkey.png',
                      unlocked: _localConquest >= 1,
                    ),
                  ),

                  // Sticker do elefante
                  Align(
                    alignment: const Alignment(0.38, 0.2),
                    child: _buildSticker(
                      'assets/stickers/elephant.png',
                      unlocked: _localConquest >= 1,
                    ),
                  ),

                  // Sticker do leão
                  Align(
                    alignment: const Alignment(0.05, 0.2),
                    child: _buildSticker(
                      'assets/stickers/lion.png',
                      unlocked: _localConquest >= 1,
                    ),
                  ),

                  // sticker do tubarão
                  Align(
                    alignment: const Alignment(0.3, 0.6),
                    child: _buildSticker(
                      'assets/stickers/shark.png',
                      unlocked: _localConquest >= 1,
                    ),
                  ),

                  // sticker do canguru
                  Align(
                    alignment: const Alignment(0.63, 0.7),
                    child: _buildSticker(
                      'assets/stickers/kangaroo.png',
                      unlocked: _localConquest >= 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        child: const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildSticker(String assetPath, {required bool unlocked}) {
    return ColorFiltered(
      colorFilter:
          unlocked
              ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
              : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
      child: Opacity(
        opacity: unlocked ? 1.0 : 0.5,
        child: Image.asset(
          assetPath,
          width: 25.w,
          height: 25.h,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

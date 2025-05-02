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
  late int _localConquest;

  @override
  void initState() {
    super.initState();
    _localConquest = (widget.user.conquest as int?) ?? 0;
  }

  void _unlockOne() {
    setState(() {
      _localConquest++;
      widget.user.conquest = _localConquest;
      widget.user.save();
    });
  }

  void _lockAll() {
    setState(() {
      _localConquest = 0;
      widget.user.conquest = 0;
      widget.user.save();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Apagar depois de implementar o desbloqueo das conquistas progressivas (manter durante desenvolvimento)
      /**/ floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'unlock',
            tooltip: 'Desbloquear',
            child: const Icon(Icons.lock_open),
            onPressed: _unlockOne,
          ),
          SizedBox(height: 20.h),
          FloatingActionButton(
            heroTag: 'lock',
            tooltip: 'Bloquear',
            child: const Icon(Icons.lock),
            onPressed: _lockAll,
          ),
          SizedBox(height: 90.h),
        ],
      ),
      /**/
      body: MenuDesign(
        //titleText: 'Mundo das Palavras',
        showMuteButton: true,
        showWhiteBackground: true,
        showSun: false,
        showHomeButton: true,
        showTopWave: false,
        onHomePressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => GameMenu(user: widget.user)),
          );
        },

        // 🌍 Imagem de fundo
        background: Positioned.fill(
          child: Image.asset(
            'assets/images/world.png',
            width: 960.w,
            height: 540.h,
          ),
        ),

        // stickers
        child: Stack(
          children: [
            // 🐒 Macaco
            Align(
              alignment: const Alignment(-0.35, 0.20),
              child: _buildSticker(
                'assets/stickers/monkey.png',
                unlocked: _localConquest >= 1,
              ),
            ),

            // 🐘 Elefante
            Align(
              alignment: const Alignment(0.35, -0.35),
              child: _buildSticker(
                'assets/stickers/elephant.png',
                unlocked: _localConquest >= 1,
              ),
            ),

            // 🦁 Leão
            Align(
              alignment: const Alignment(0.05, 0),
              child: _buildSticker(
                'assets/stickers/lion.png',
                unlocked: _localConquest >= 1,
              ),
            ),

            // 🦈 Tubarão
            Align(
              alignment: const Alignment(0.25, 0.3),
              child: _buildSticker(
                'assets/stickers/shark.png',
                unlocked: _localConquest >= 1,
              ),
            ),

            // 🦘 Canguru
            Align(
              alignment: const Alignment(0.55, 0.4),
              child: _buildSticker(
                'assets/stickers/kangaroo.png',
                unlocked: _localConquest >= 1,
              ),
            ),
          ],
        ),
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
          width: 45.w,
          height: 45.h,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

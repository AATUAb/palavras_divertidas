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
          SizedBox(height: 80.h),
        ],
      ),
      /**/
      body: MenuDesign(
        titleText: 'Mundo das Palavras',
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
            'assets/images/world.webp',
            width: 960.w,
            height: 540.h,
          ),
        ),

        // stickers
        child: Stack(
          children: [
            // 🐻‍❄️ Urso Polar
            Align(
              alignment: const Alignment(-0.25, -1),
              child: _buildSticker(
                'assets/images/words/urso_polar.webp',
                unlocked: _localConquest >= 1,
              ),
            ),

            // 🐊 Jacaré
            Align(
              alignment: const Alignment(-0.45, -0.4),
              child: _buildSticker(
                'assets/images/words/crocodilo.webp',
                unlocked: _localConquest >= 1,
              ),
            ),

            // 🦅 Águia
            Align(
              alignment: const Alignment(-0.52, -0.7),
              child: _buildSticker(
                'assets/images/words/aguia.webp',
                unlocked: _localConquest >= 1,
              ),
            ),

            // 🦬 Bisonte
            Align(
              alignment: const Alignment(-0.65, -0.9),
              child: _buildSticker(
                'assets/images/words/bisonte.webp',
                unlocked: _localConquest >= 1,
              ),
            ),

            // 🦎 Iguana
            Align(
              alignment: const Alignment(-0.55, -0.25),
              child: _buildSticker(
                'assets/images/words/iguana.webp',
                unlocked: _localConquest >= 1,
              ),
            ),

            // 🐒 Macaco
            Align(
              alignment: const Alignment(-0.40, 0.20),
              child: _buildSticker(
                'assets/images/words/macaco.webp',
                unlocked: _localConquest >= 1,
              ),
            ),

            // 🐦 Tucano
            Align(
              alignment: const Alignment(-0.35, 0.55),
              child: _buildSticker(
                'assets/images/words/tucano.webp',
                unlocked: _localConquest >= 1,
              ),
            ),

            // 🐬 Golfinho
            Align(
              alignment: const Alignment(-0.2, -0.4),
              child: _buildSticker(
                'assets/images/words/golfinho.webp',
                unlocked: _localConquest >= 1,
              ),
            ),

            // 🐰 Coelho
            Align(
              alignment: const Alignment(-0.03, -0.7),
              child: _buildSticker(
                'assets/images/words/coelho.webp',
                unlocked: _localConquest >= 1,
              ),
            ),

            // 🦊 raposa
            Align(
              alignment: const Alignment(0.1, -0.8),
              child: _buildSticker(
                'assets/images/words/raposa.webp',
                unlocked: _localConquest >= 1,
              ),
            ),

            // 🦌 Alce
            Align(
              alignment: const Alignment(0.30, -1.0),
              child: _buildSticker(
                'assets/images/words/rato.webp',
                unlocked: _localConquest >= 1,
              ),
            ),

            // 🐘 Elefante
            Align(
              alignment: const Alignment(0.40, -0.55),
              child: _buildSticker(
                'assets/images/words/elefante.webp',
                unlocked: _localConquest >= 1,
              ),
            ),

            // 🐍 Cobra
            Align(
              alignment: const Alignment(0.38, -0.2),
              child: _buildSticker(
                'assets/images/words/cobra.webp',
                unlocked: _localConquest >= 1,
              ),
            ),

            // 🐯 Tigre
            Align(
              alignment: const Alignment(0.25, -0.40),
              child: _buildSticker(
                'assets/images/words/tigre.webp',
                unlocked: _localConquest >= 1,
              ),
            ),

            // 🐼 Panda
            Align(
              alignment: const Alignment(0.55, -0.40),
              child: _buildSticker(
                'assets/images/words/panda.webp',
                unlocked: _localConquest >= 1,
              ),
            ),

            // 🐻 Urso
            Align(
              alignment: const Alignment(0.50, -0.85),
              child: _buildSticker(
                'assets/images/words/urso.webp',
                unlocked: _localConquest >= 1,
              ),
            ),

            // 🦁 Leão
            Align(
              alignment: const Alignment(-0.1, -0.1),
              child: _buildSticker(
                'assets/images/words/leao.webp',
                unlocked: _localConquest >= 1,
              ),
            ),

            // 🦒 Girafa
            Align(
              alignment: const Alignment(0.07, 0.5),
              child: _buildSticker(
                'assets/images/words/girafa.webp',
                unlocked: _localConquest >= 1,
              ),
            ),

            // 🐪 Camelo
            Align(
              alignment: const Alignment(0.05, -0.25),
              child: _buildSticker(
                'assets/images/words/camelo.webp',
                unlocked: _localConquest >= 1,
              ),
            ),

            // 🦛 Hipopótamo
            Align(
              alignment: const Alignment(0.15, 0),
              child: _buildSticker(
                'assets/images/words/hipopotamo.webp',
                unlocked: _localConquest >= 1,
              ),
            ),

            // 🦈 Tubarão
            Align(
              alignment: const Alignment(0.25, 0.5),
              child: _buildSticker(
                'assets/images/words/tubarao.webp',
                unlocked: _localConquest >= 1,
              ),
            ),

            // 🐋 Baleia
            Align(
              alignment: const Alignment(-0.75, 0.1),
              child: _buildSticker(
                'assets/images/words/baleia.webp',
                unlocked: _localConquest >= 1,
              ),
            ),

            // 🐋 Orca
            Align(
              alignment: const Alignment(0.4, 0.95),
              child: _buildSticker(
                'assets/images/words/orca.webp',
                unlocked: _localConquest >= 1,
              ),
            ),

            // 🐢 Tartaruga
            Align(
              alignment: const Alignment(-0.5, 0.6),
              child: _buildSticker(
                'assets/images/words/tartaruga.webp',
                unlocked: _localConquest >= 1,
              ),
            ),

            // 🦑 Polvo
            Align(
              alignment: const Alignment(-0.15, 0.4),
              child: _buildSticker(
                'assets/images/words/polvo.webp',
                unlocked: _localConquest >= 1,
              ),
            ),

            // 🦘 Canguru
            Align(
              alignment: const Alignment(0.70, 0.60),
              child: _buildSticker(
                'assets/images/words/canguru.webp',
                unlocked: _localConquest >= 1,
              ),
            ),

            // 🐨 Coala
            Align(
              alignment: const Alignment(0.58, 0.50),
              child: _buildSticker(
                'assets/images/words/kuala.webp',
                unlocked: _localConquest >= 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSticker(String assetPath, {required bool unlocked}) {
    return Opacity(
      opacity: unlocked ? 1.0 : 0.5, // só controla visibilidade
      child: ColorFiltered(
        colorFilter:
            unlocked
                ? const ColorFilter.mode(Colors.transparent, BlendMode.dst)
                : const ColorFilter.mode(Colors.black, BlendMode.srcIn),
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

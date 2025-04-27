import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/menu_design.dart';
import 'game_menu.dart';
import '../themes/colors.dart'; // para usar AppColors.green

class StickerBookScreen extends StatefulWidget {
  final dynamic user;
  const StickerBookScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<StickerBookScreen> createState() => _StickerBookScreenState();
}

class _StickerBookScreenState extends State<StickerBookScreen> {
  // armazena localmente o nº de conquistas para demo
  late int _localConquest;

  @override
  void initState() {
    super.initState();
    // inicia com o valor real do usuário
    _localConquest = (widget.user.conquest as int?) ?? 0;
  }

  void _unlockOne() {
    setState(() {
      _localConquest++;
      // atualiza o objeto real (e persiste, se for HiveObject)
      widget.user.conquest = _localConquest;
      widget.user.save();
    });
  }

  @override
  Widget build(BuildContext context) {
    // proporção largura/altura do mapa
    const double mapAspectRatio = 1.2;

    // decide se cada sticker está desbloqueado
    final bool monkeyUnlocked = _localConquest >= 2;
    final bool elephantUnlocked = _localConquest >= 3;

    return Scaffold(
      // ← botão para “destravar” uma conquista a cada toque
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.green,
        child: const Icon(Icons.lock_open),
        onPressed: _unlockOne,
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
        // 1️⃣ fundo do mapa, por baixo da curva
        background: Padding(
          padding: EdgeInsets.only(top: 90.h),
          child: Center(
            child: AspectRatio(
              aspectRatio: mapAspectRatio,
              child: Stack(
                children: [
                  // o próprio mapa
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/earth.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  // macaco no Brasil
                  Align(
                    alignment: const Alignment(-0.35, 0.4),
                    child: _buildSticker(
                      'assets/stickers/monkey.jpg',
                      unlocked: monkeyUnlocked,
                    ),
                  ),
                  // elefante na Índia
                  Align(
                    alignment: const Alignment(0.4, 0.2),
                    child: _buildSticker(
                      'assets/stickers/elephant.jpg',
                      unlocked: elephantUnlocked,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // não há conteúdo extra sobre o mapa + stickers
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
        opacity: unlocked ? 1.0 : 0.1,
        child: Image.asset(
          assetPath,
          width: 30.w,
          height: 30.h,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/menu_design.dart';
import '../widgets/game_animations.dart';
import 'game_menu.dart';

class StickerBookScreen extends StatefulWidget {
  final dynamic user;
  const StickerBookScreen({super.key, required this.user});

  @override
  State<StickerBookScreen> createState() => _StickerBookScreenState();
}

class _StickerBookScreenState extends State<StickerBookScreen> {
  late int _localConquest;

  /// Lista de stickers com caminho e alinhamento
  final List<Map<String, dynamic>> _stickers = [
    {
      'asset': 'assets/images/words/urso_polar.webp',
      'alignment': const Alignment(-0.3, -0.8),
    },
    {
      'asset': 'assets/images/words/crocodilo.webp',
      'alignment': const Alignment(-0.6, -0.20),
    },
    {
      'asset': 'assets/images/words/aguia.webp',
      'alignment': const Alignment(-0.65, -0.5),
    },
    {
      'asset': 'assets/images/words/bisonte.webp',
      'alignment': const Alignment(-0.8, -0.7),
    },
    {
      'asset': 'assets/images/words/iguana.webp',
      'alignment': const Alignment(-0.70, 0),
    },
    {
      'asset': 'assets/images/words/macaco.webp',
      'alignment': const Alignment(-0.43, 0.30),
    },
    {
      'asset': 'assets/images/words/tucano.webp',
      'alignment': const Alignment(-0.50, 0.55),
    },
    {
      'asset': 'assets/images/words/golfinho.webp',
      'alignment': const Alignment(-0.3, -0.2),
    },
    {
      'asset': 'assets/images/words/coelho.webp',
      'alignment': const Alignment(-0.04, -0.4),
    },
    {
      'asset': 'assets/images/words/raposa.webp',
      'alignment': const Alignment(0.1, -0.55),
    },
    {
      'asset': 'assets/images/words/alce.webp',
      'alignment': const Alignment(0.35, -0.65),
    },
    {
      'asset': 'assets/images/words/elefante.webp',
      'alignment': const Alignment(0.50, -0.40),
    },
    {
      'asset': 'assets/images/words/cobra.webp',
      'alignment': const Alignment(0.45, 0),
    },
    {
      'asset': 'assets/images/words/tigre.webp',
      'alignment': const Alignment(0.27, -0.20),
    },
    {
      'asset': 'assets/images/words/panda.webp',
      'alignment': const Alignment(0.67, -0.15),
    },
    {
      'asset': 'assets/images/words/urso.webp',
      'alignment': const Alignment(0.65, -0.70),
    },
    {
      'asset': 'assets/images/words/leao.webp',
      'alignment': const Alignment(-0.1, 0.1),
    },
    {
      'asset': 'assets/images/words/girafa.webp',
      'alignment': const Alignment(0.08, 0.55),
    },
    {
      'asset': 'assets/images/words/camelo.webp',
      'alignment': const Alignment(0.08, -0.15),
    },
    {
      'asset': 'assets/images/words/hipopotamo.webp',
      'alignment': const Alignment(0.2, 0.2),
    },
    {
      'asset': 'assets/images/words/tubarao.webp',
      'alignment': const Alignment(0.45, 0.5),
    },
    {
      'asset': 'assets/images/words/baleia.webp',
      'alignment': const Alignment(-0.9, 0.3),
    },
    {
      'asset': 'assets/images/words/orca.webp',
      'alignment': const Alignment(0.2, 0.95),
    },
    {
      'asset': 'assets/images/words/tartaruga.webp',
      'alignment': const Alignment(-0.65, 0.75),
    },
    {
      'asset': 'assets/images/words/polvo.webp',
      'alignment': const Alignment(-0.15, 0.65),
    },
    {
      'asset': 'assets/images/words/canguru.webp',
      'alignment': const Alignment(0.87, 0.68),
    },
    {
      'asset': 'assets/images/words/kuala.webp',
      'alignment': const Alignment(0.72, 0.60),
    },
  ];

  @override
  void initState() {
    super.initState();
    // Inicializa a conquista local a partir do usuário
    _localConquest = (widget.user.conquest as int?) ?? 0;

    // Marca todas as conquistas como vistas ao entrar na caderneta
    widget.user.lastSeenConquests = widget.user.conquest;
    widget.user.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MenuDesign(
        titleText: 'Palavras Divertidas',
        showMuteButton: true,
        showWhiteBackground: true,
        showSun: false,
        showHomeButton: true,
        showTopWave: true,
        onHomePressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => GameMenu(user: widget.user)),
          );
        },

         showTutorial: true,
          onTutorialPressed: () async {
            isMenuMusicAllowed = false;
            await pauseMenuMusicForTutorials(); 
            WidgetsBinding.instance.addPostFrameCallback((_) {
              GameAnimations.showTutorialVideo(
                context: context,
                fileName: 'sticker_book',
                onFinished: () {
                },
              );
            });
          },

        child: Column(
          children: [
            // Espaço para evitar sobreposição do título (ajuste se necessário)
            SizedBox(
              height: (ScreenUtil().screenHeight * 0.03).clamp(16.h, 40.h),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: AspectRatio(
                  aspectRatio:
                      16 / 9, // ou ajusta se tiveres o valor real do mapa
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final double stickerSize = constraints.maxWidth * 0.06;

                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            'assets/images/world.webp',
                            fit: BoxFit.contain,
                          ),
                          ..._stickers.asMap().entries.map((entry) {
                            final bool unlocked =
                                _localConquest >= entry.key + 1;
                            return Align(
                              alignment: entry.value['alignment'] as Alignment,
                              child: Opacity(
                                opacity: unlocked ? 1.0 : 0.5,
                                child: ColorFiltered(
                                  colorFilter:
                                      unlocked
                                          ? const ColorFilter.mode(
                                            Colors.transparent,
                                            BlendMode.dst,
                                          )
                                          : const ColorFilter.mode(
                                            Colors.black,
                                            BlendMode.srcIn,
                                          ),
                                  child: Image.asset(
                                    entry.value['asset'] as String,
                                    width: stickerSize,
                                    height: stickerSize,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

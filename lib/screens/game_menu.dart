// lib/screens/game_menu.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/user_model.dart';
import '../themes/colors.dart';
import '../widgets/menu_design.dart';
import '../games/identify_letters_numbers.dart';
import '../games/writing_game.dart';
import '../games/count_syllables.dart';
import '../games/listen_look.dart';
import '../games/identify_words.dart';
import '../games/lost_syllable.dart';
import '../widgets/conquest_manager.dart';
import '../widgets/sound_manager.dart';
import '../widgets/game_animations.dart';
import 'home_page.dart';
import 'sticker_book.dart';
import 'user_stats.dart';
import 'letters_selection.dart';

class GameCardData {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color backgroundColor;
  final bool showNewFlag;

  GameCardData({
    required this.title,
    required this.icon,
    required this.onTap,
    required this.backgroundColor,
    this.showNewFlag = false,
  });
}

class GameMenu extends StatefulWidget {
  final UserModel user;
  const GameMenu({super.key, required this.user});

  @override
  State<GameMenu> createState() => _GameMenuState();
}

class _GameMenuState extends State<GameMenu> {
  late ConquestManager conquestManager;

@override
void initState() {
  super.initState();
  conquestManager = ConquestManager();
  
  // Não toca música já — só se não houver conquistas.
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await _checkNewConquests();
    
    // Só retoma música se não fomos para outro ecrã
    if (mounted) {
      await resumeMenuMusic();
    }
  });
}

  // Verifica se há conquistas novas. Se sim mostra um diálogo com a conquista
  Future<void> _checkNewConquests() async {
    final newUnlocks = widget.user.conquest - widget.user.lastSeenConquests;
    if (newUnlocks > 0) {
      isMenuMusicAllowed = false;
      await pauseMenuMusicForConquest();

      final soundFile =
          newUnlocks == 1 ? 'one_conquest.ogg' : 'more_conquests.ogg';
      await SoundManager.playAnimationSound(soundFile);

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (_) => AlertDialog(
              backgroundColor: const Color(0xffe8f4fe),
              title: Text(
                'Parabéns! 🎉',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),

              content: Text(
                'Tens $newUnlocks conquista${newUnlocks > 1 ? 's' : ''} nova${newUnlocks > 1 ? 's' : ''}!\n'
                'Entra na caderneta para a${newUnlocks > 1 ? 's' : ''} encontrar${newUnlocks > 1 ? 'es' : ''}.',
              ),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Botão Cancelar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextButton.icon(
                        onPressed: () async {
                          await SoundManager.stop();
                          widget.user.lastSeenConquests = widget.user.conquest;
                          await widget.user.save();
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.cancel, color: Colors.white),
                        label: const Text(
                          'Cancelar',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),

                    // Espaço entre os botões
                    const SizedBox(width: 15),

                    // Botão Ver Caderneta
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextButton.icon(
                        onPressed: () async {
                          await SoundManager.stop();
                          widget.user.lastSeenConquests = widget.user.conquest;
                          await widget.user.save();
                          Navigator.of(context).pop();
                          await Future.delayed(const Duration(milliseconds: 100));
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => StickerBookScreen(user: widget.user),
                            ),
                          );
                        },
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: const Text(
                          'Ver Caderneta',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        } 
        isMenuMusicAllowed = true;
        await resumeMenuMusic();
      }

  void handleLetterDependentGame({
    required BuildContext context,
    required UserModel user,
    required Widget Function() gameBuilder,
  }) async {
    Future<bool> hasSufficientLetters(UserModel u) async {
      final known = expandKnownLetters(u.knownLetters);
      final onlyVowels =
          known.toSet().difference({'a', 'e', 'i', 'o', 'u'}).isEmpty;
      return known.isNotEmpty && !onlyVowels;
    }

    if (!await hasSufficientLetters(user)) {
      isMenuMusicAllowed = false;
      await pauseMenuMusic();
      try {
        SoundManager.playGeneralSound('update_letters.ogg');
      } catch (e) {
        debugPrint('⚠️ Erro ao tocar som: $e');
      }

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (_) => AlertDialog(
              backgroundColor: const Color(0xffe8f4fe),
              title: Text(
                'Ainda sem palavras!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                'Atualiza as letras aprendidas para poderes jogar.',
                style: TextStyle(color: Colors.blue.shade700),
              ),
                actionsPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Botão "Cancelar" à ESQUERDA
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.grey,
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          isMenuMusicAllowed = true;
                          resumeMenuMusic();
                        },
                        icon: Icon(Icons.cancel, size: 20, color: Colors.white),
                        label: Text(
                          "Cancelar",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),

                      // Botão "Letras Novas?" à DIREITA
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green,
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await showLettersDialog(
                            context: context,
                            user: user,
                            initialSelection: user.knownLetters,
                            onSaved: (selected) async {
                              user.knownLetters = selected;
                              await user.save();
                            },
                          );

                          if (!await hasSufficientLetters(user)) {
                            isMenuMusicAllowed = true;
                            await resumeMenuMusic();
                            return;
                          }

                          await Future.delayed(const Duration(milliseconds: 100));
                          if (context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => gameBuilder()),
                            );
                          }
                        },
                        child: Text(
                          "Letras Novas?",
                          style: TextStyle(fontSize: 15.sp),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
              return;
            }
            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => gameBuilder()),
              );
              isMenuMusicAllowed = true;
              await resumeMenuMusic();
            }
          }

  // Jogos principais disponíveis para todos os ciclos
  @override
  Widget build(BuildContext context) {
    final List<GameCardData> jogosBase = [
      GameCardData(
        title: "Identificar letras e números",
        icon: Icons.search,
        onTap: _identifyLettersNumbers,
        backgroundColor: AppColors.green,
      ),
      GameCardData(
        title: "Escrever",
        icon: Icons.edit,
        onTap: () => _writeGame(),
        backgroundColor: AppColors.orange,
      ),
      GameCardData(
        title: "Contar sílabas",
        icon: Icons.format_list_numbered,
        onTap: _countSyllablesGame,
        backgroundColor: AppColors.yellow,
      ),
      GameCardData(
        title: "Ouvir e procurar imagens",
        icon: Icons.hearing,
        onTap: _listenLook,
        backgroundColor: AppColors.green,
      ),
    ];

    final List<GameCardData> jogosExtras = [
      GameCardData(
        title: "Ouvir e procurar palavras",
        icon: Icons.edit_note,
        onTap:
            () => handleLetterDependentGame(
              context: context,
              user: widget.user,
              gameBuilder: () => IdentifyWordGame(user: widget.user),
            ),
        backgroundColor: AppColors.orange,
        showNewFlag: true,
      ),
      GameCardData(
        title: "Sílaba perdida",
        icon: Icons.more_horiz,
        onTap:
            () => handleLetterDependentGame(
              context: context,
              user: widget.user,
              gameBuilder: () => LostSyllableGame(user: widget.user),
            ),
        backgroundColor: AppColors.yellow,
        showNewFlag: true,
      ),
    ];
    final jogosDisponiveis =
        widget.user.schoolLevel == "1º Ciclo"
            ? [...jogosBase, ...jogosExtras]
            : jogosBase;

    return Scaffold(
      body: MenuDesign(
        titleText: "Palavras Divertidas",
        headerText: "Olá ${widget.user.name}, escolhe o teu jogo",
        pauseIntroMusic: true,
        showHomeButton: true,
        onHelpPressed: () async {
        isMenuMusicAllowed = false;
        await pauseMenuMusic();

      final ciclo = widget.user.schoolLevel;
      final videoName = (ciclo == '1º Ciclo') ? 'game_menu_first' : 'game_menu_pre';

      WidgetsBinding.instance.addPostFrameCallback((_) {
                  GameAnimations.showTutorialVideo(
                    context: context,
          gameName: videoName,
          onFinished: () async {
            debugPrint("🎬 Tutorial $videoName terminado.");
            isMenuMusicAllowed = true;
            await resumeMenuMusic();
          },
        );
      });
    },

        onHomePressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const MyHomePage(title: 'Palavras Divertidas'),
            ),
          );
        },
        topLeftWidget: Padding(
          padding: EdgeInsets.only(top: 170.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.emoji_events, size: 25.sp),
                tooltip: 'Conquistas',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StickerBookScreen(user: widget.user),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.bar_chart, size: 25.sp),
                tooltip: 'Estatísticas',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserStats(user: widget.user),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Column(
              children: [
                SizedBox(height: 100.h),
                Expanded(
                  child: Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 15.w,
                      runSpacing: 12.h,
                      children:
                          jogosDisponiveis.map((jogo) {
                            return Builder(
                              builder: (localContext) {
                                return GestureDetector(
                                  onTap: () {
                                    jogo.onTap();
                                  },
                                  child: SizedBox(
                                    width: 100.w,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            Container(
                                              width: 70.r,
                                              height: 70.r,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: jogo.backgroundColor,
                                              ),
                                              child: Icon(
                                                jogo.icon,
                                                size: 30.sp,
                                                color: Colors.black,
                                              ),
                                            ),
                                            if (jogo.showNewFlag)
                                              Positioned(
                                                top: -6.h,
                                                right: -6.w,
                                                child: GestureDetector(
                                                  onTap: () async {
                                                    await pauseMenuMusic();
                                                    await showLettersDialog(
                                                      context: localContext,
                                                      user: widget.user,
                                                      initialSelection:
                                                          widget
                                                              .user
                                                              .knownLetters,
                                                      onSaved: (
                                                        List<String>
                                                        selectedLetters,
                                                      ) async {
                                                        widget
                                                                .user
                                                                .knownLetters =
                                                            selectedLetters;
                                                        await widget.user.save();
                                                      },
                                                    );
                                                    await resumeMenuMusic(); 
                                                  },
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 6.w,
                                                          vertical: 2.h,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.green,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12.r,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      'Letras novas?',
                                                      style: TextStyle(
                                                        fontSize: 8.sp,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          jogo.title,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Abre o jogo de identificação de letras e números
  void _identifyLettersNumbers() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => IdentifyLettersNumbers(user: widget.user),
      ),
    );
  }

  // Abre o jogo de escrita
  void _writeGame() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => WriteGame(user: widget.user)),
    );
  }

  // Abre o jogo de contar sílabas
  void _countSyllablesGame() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => CountSyllablesGame(user: widget.user)),
    );
  }

  // Abre o jogo de ouvir e procurar imagens
  void _listenLook() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ListenLookGame(user: widget.user)),
    );
  }
}

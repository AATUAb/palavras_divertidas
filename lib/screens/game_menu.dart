// lib/screens/game_menu.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:audioplayers/audioplayers.dart';

import '../models/user_model.dart';
import '../themes/colors.dart';
import '../widgets/menu_design.dart';
import '../games/identify_letters_numbers.dart';
import '../games/writing_game.dart';
import '../games/count_syllables.dart';
import '../games/listen_look.dart';
import '../widgets/conquest_manager.dart';
import 'home_page.dart';
import 'sticker_book.dart';
import 'user_stats.dart';

class GameCardData {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color backgroundColor;

  GameCardData({
    required this.title,
    required this.icon,
    required this.onTap,
    required this.backgroundColor,
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
  final AudioPlayer _conquestPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    conquestManager = ConquestManager();
    resumeMenuMusic();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkNewConquests());
  }

  // Verifica se há conquistas novas. Se sim mostra um diálogo com a conquista
  Future<void> _checkNewConquests() async {
    final newUnlocks = widget.user.conquest - widget.user.lastSeenConquests;
    if (newUnlocks > 0) {
      await pauseMenuMusic();
      final soundFile = newUnlocks == 1
              ? 'sounds/animations/one_conquest.ogg'
              : 'sounds/animations/more_conquests.ogg';
      await _conquestPlayer.play(AssetSource(soundFile), volume: 1.0);
      await showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('Parabéns! 🎉'),
              content: Text(
                'Tens $newUnlocks conquista${newUnlocks > 1 ? 's' : ''} nova${newUnlocks > 1 ? 's' : ''}!\n'
                'Entra na caderneta para a${newUnlocks > 1 ? 's' : ''} encontrar${newUnlocks > 1 ? 'es' : ''}.',
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 12, bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextButton.icon(
                    onPressed: () async {
                      await pauseMenuMusic();
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
                      'Ok',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
      );
    }
    await resumeMenuMusic();
  }


  // Jogos principais disponíveis para todos os ciclos
  @override
  Widget build(BuildContext context) {
    final List<GameCardData> jogosBase = [
      GameCardData(
        title: "Detetive de letras e números",
        icon: Icons.search,
        onTap: _identifyLettersNumbers,
        backgroundColor: AppColors.green,
      ),
      GameCardData(
        title: "Escrever",
        icon: Icons.edit,
        onTap: _writingGame,
        backgroundColor: AppColors.orange,
      ),
      GameCardData(
        title: "Contar sílabas",
        icon: Icons.format_list_numbered,
        onTap: _countSyllablesGame,
        backgroundColor: AppColors.yellow,
      ),
      GameCardData(
        title: "Ouvir e procurar",
        icon: Icons.hearing,
        onTap: _listenLook,
        backgroundColor: AppColors.green,
      ),
    ];

    // Jogos extras disponíveis apenas para o 1º ciclo
    final List<GameCardData> jogosExtras = [
      GameCardData(
        title: "Detetive de palavras",
        icon: Icons.find_in_page,
        onTap: () => _navigateToGame("Detetive de palavras"),
        backgroundColor: AppColors.orange,
      ),
      GameCardData(
        title: "Sílabas perdidas",
        icon: Icons.extension,
        onTap: () => _navigateToGame("Sílabas perdidas"),
        backgroundColor: AppColors.yellow,
      ),
    ];

    final jogosDisponiveis =
        widget.user.schoolLevel == "1º Ciclo"
            ? [...jogosBase, ...jogosExtras]
            : jogosBase;

    // Menu principal de escolha de jogos
    return Scaffold(
      body: MenuDesign(
        titleText: "Mundo das Palavras",
        headerText: "Olá ${widget.user.name}, escolhe o teu jogo",
        pauseIntroMusic: true,
        showHomeButton: true,
        onHomePressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const MyHomePage(title: 'Mundo das Palavras'),
            ),
          );
        },
        // Barra lateral com ícones de conquistas e estatísticas
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
                            return GestureDetector(
                              onTap: jogo.onTap,
                              child: SizedBox(
                                width: 100.w,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
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
                                        color: Colors.white,
                                      ),
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
  void _writingGame() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => WritingGame(user: widget.user)),
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

  void _navigateToGame(String gameName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Jogo '$gameName' em desenvolvimento!",
          style: TextStyle(fontSize: 14.sp, color: AppColors.white),
        ),
        backgroundColor: AppColors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

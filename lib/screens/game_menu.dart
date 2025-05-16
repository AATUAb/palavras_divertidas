import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/user_model.dart';
import '../themes/colors.dart';
import '../widgets/menu_design.dart';
import '../games/identify_letters_numbers.dart';
import '../games/writing_game.dart';
import '../games/count_syllables.dart';
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

  @override
  void initState() {
    super.initState();
    conquestManager = ConquestManager();
    resumeMenuMusic(); // Garante que a música toca ao voltar ao menu
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkNewConquests());
  }

  Future<void> _checkNewConquests() async {
    final newUnlocks = widget.user.conquest - widget.user.lastSeenConquests;
    if (newUnlocks > 0) {
      await showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('Parabéns! 🎉'),
              content: Text(
                'Desbloqueaste $newUnlocks conquista${newUnlocks > 1 ? 's' : ''}!\n'
                'Vai até à caderneta para saber quais.',
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    widget.user.lastSeenConquests = widget.user.conquest;
                    await widget.user.save();
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }
  }

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
        onTap: () => _navigateToGame("Ouvir e procurar"),
        backgroundColor: AppColors.green,
      ),
    ];

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

    return Scaffold(
      body: MenuDesign(
        titleText: "Mundo das Palavras",
        headerText: "Olá ${widget.user.name}, escolhe o teu jogo",
        showHomeButton: true,
        onHomePressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const MyHomePage(title: 'Mundo das Palavras'),
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

  void _identifyLettersNumbers() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => IdentifyLettersNumbers(user: widget.user),
      ),
    );
  }

  void _writingGame() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => WritingGame(user: widget.user)),
    );
  }

  void _countSyllablesGame() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => CountSyllablesGame(user: widget.user)),
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

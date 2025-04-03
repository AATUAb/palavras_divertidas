import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/user_model.dart';
import '../themes/colors.dart';
import '../widgets/custom_drawer.dart' as custom;
import '../widgets/menu_design.dart';
import '../games/write_game.dart';
import '../games/identify_letters_numbers.dart';
import 'home_page.dart';
import 'dashboard.dart';
import 'sticker_book.dart';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final List<GameCardData> jogosBase = [
      GameCardData(
        title: "Detetive de letras e números",
        icon: Icons.search,
        onTap: _startIdentifyLettersNumbersGame,
        backgroundColor: AppColors.green,
      ),
      GameCardData(
        title: "Escrever",
        icon: Icons.edit,
        onTap: _startWriteGame,
        backgroundColor: AppColors.orange,
      ),
      GameCardData(
        title: "Contar sílabas",
        icon: Icons.format_list_numbered,
        onTap: () => _navigateToGame("Contar sílabas"),
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

    final List<GameCardData> jogosDisponiveis =
        widget.user.schoolLevel == "1º Ciclo"
            ? [...jogosBase, ...jogosExtras]
            : jogosBase;

    return Scaffold(
      key: _scaffoldKey,
      drawer: custom.CustomDrawer(
        userName: widget.user.name,
        userLevel: widget.user.schoolLevel,
        onManageUsers: () {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => const MyHomePage(title: 'Mundo das Palavras'),
            ),
          );
        },
        onAchievements: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => StickerBookScreen()),
          );
        },
        onDashboard: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DashboardScreen(user: widget.user),
            ),
          );
        },
      ),
      body: MenuDesign(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.menu,
                        color: AppColors.black,
                        size: 24.sp,
                      ),
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  "Olá, ${widget.user.name}!",
                  style: TextStyle(
                    fontSize: 25.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Escolhe o teu jogo",
                  style: TextStyle(
                    fontSize: 25.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkBlue,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.h),
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
                                width: 90.w,
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

  void _startIdentifyLettersNumbersGame() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IdentifyLettersNumbersGame(user: widget.user),
      ),
    );
  }

  void _startWriteGame() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WriteGameScreen(character: "A")),
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

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
import 'sticker_book.dart'; // Importando a tela de Caderneta de Cromos

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
        widget.user.level == "1º Ciclo"
            ? [...jogosBase, ...jogosExtras]
            : jogosBase;

    return Scaffold(
      drawer: custom.CustomDrawer(
        userName: widget.user.name,
        userLevel: widget.user.level,
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
            MaterialPageRoute(
              builder:
                  (_) =>
                      StickerBookScreen(), // Navegando para a Caderneta de Cromos
            ),
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final is1Ciclo = widget.user.level == "1º Ciclo";
              final isSmallHeight = constraints.maxHeight < 650;

              return Column(
                children: [
                  // Cabeçalho
                  Padding(
                    padding: EdgeInsets.only(top: 2.h, left: 12.w, right: 12.w),
                    child: SizedBox(
                      height: 30.h,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Positioned(
                                  top: 10.h,
                                  left: 10.w,
                                  child: Material(
                                    type: MaterialType.transparency,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.menu,
                                          color: Colors.black,
                                          size: 30.sp,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed:
                                            () =>
                                                Scaffold.of(
                                                  context,
                                                ).openDrawer(),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Título
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 8.h),
                        Text(
                          "Olá, ${widget.user.name}!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 25.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                        Text(
                          "Escolhe o teu jogo",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 25.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Grelha de jogos com uso total do espaço disponível
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: jogosDisponiveis.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: is1Ciclo ? 3 : 2,
                          crossAxisSpacing: 8.w,
                          mainAxisSpacing: 8.h,
                          childAspectRatio: isSmallHeight ? 2.4 : 2.1,
                        ),
                        itemBuilder: (context, index) {
                          final jogo = jogosDisponiveis[index];
                          return GestureDetector(
                            onTap: jogo.onTap,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  jogo.icon,
                                  size: 50.sp,
                                  color: jogo.backgroundColor,
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  jogo.title,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: jogo.backgroundColor,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
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

  void _startWriteGame() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WriteGameScreen(character: "A")),
    );
  }

  void _startIdentifyLettersNumbersGame() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                IdentifyLettersNumbersGame(key: widget.key, user: widget.user),
      ),
    );
  }
}

// Estrutura principal do menu dos jogos disponíveis

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/user_model.dart';
import '../themes/colors.dart';
import '../widgets/game_card.dart';
import '../widgets/custom_drawer.dart' as custom;
import '../games/write_game.dart';
import '../games/identify_letters_numbers.dart';
import 'home_page.dart';
import 'dashboard.dart';

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
      appBar: AppBar(
        title: Text(
          "Olá, ${widget.user.name}!!",
          style: TextStyle(fontSize: 18.sp, color: AppColors.white),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Center(
              child: Text(
                widget.user.level,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
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
          Future.delayed(const Duration(milliseconds: 100), () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Conquistas em breve!",
                  style: TextStyle(fontSize: 14.sp, color: AppColors.white),
                ),
                backgroundColor: AppColors.green,
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          });
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
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(color: AppColors.lightBlue),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(15.w, 10.h, 10.w, 10.h),
                    child: Row(
                      children: [
                        Icon(Icons.games, color: AppColors.orange, size: 24.sp),
                        SizedBox(width: 5.w),
                        Text(
                          "Escolhe o teu jogo:",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1.sw > 600 ? 3 : 2,

                        crossAxisSpacing: 15.w,
                        mainAxisSpacing: 15.h,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: jogosDisponiveis.length,
                      itemBuilder: (context, index) {
                        return GameCard(
                          title: jogosDisponiveis[index].title,
                          icon: jogosDisponiveis[index].icon,
                          onTap: jogosDisponiveis[index].onTap,
                          backgroundColor:
                              jogosDisponiveis[index].backgroundColor,
                          iconColor: jogosDisponiveis[index].iconColor,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
            (context) => IdentifyLettersNumbersGame(
              key: widget.key,
              userLevel: widget.user.level,
            ),
      ),
    );
  }
}

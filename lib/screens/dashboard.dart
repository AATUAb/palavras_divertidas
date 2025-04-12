import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/user_model.dart';
import '../themes/colors.dart';
import '../widgets/menu_design.dart';
import '../screens/game_menu.dart';

class DashboardScreen extends StatelessWidget {
  final UserModel user;

  const DashboardScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final bool isFirstCycle = user.schoolLevel == '1º Ciclo';
    final gameNames =
        isFirstCycle
            ? [
              'Detetive',
              'Escrever',
              'Silabas',
              'Ouvir',
              'Detetive de palavras',
              'Sílaba perdida',
            ]
            : ['Detetive', 'Escrever', 'Silabas', 'Ouvir'];

    final allGameStats = user.gamesAccuracy;
    final int crossAxisCount = isFirstCycle ? 3 : 2;

    final gameIcons = {
      'Detetive': Icons.search,
      'Escrever': Icons.edit,
      'Silabas': Icons.format_list_numbered,
      'Ouvir': Icons.hearing,
      'Detetive de palavras': Icons.find_in_page,
      'Sílaba perdida': Icons.extension,
    };

    return MenuDesign(
      hideSun: true,
      showHomeButton: true,
      onHomePressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => GameMenu(user: user)),
        );
      },
      child: Padding(
        padding: EdgeInsets.only(top: 60.h, left: 150.w, right: 150.w),
        child: GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 25.w,
          mainAxisSpacing: 25.h,
          childAspectRatio: 1.3, // <-- Aqui está o que faltava!
          children:
              gameNames.map((game) {
                final levels = allGameStats[game] ?? [0.0, 0.0, 0.0];
                final overall =
                    levels.isNotEmpty
                        ? (levels.reduce((a, b) => a + b) / levels.length) * 100
                        : 0.0;

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 16.h,
                      horizontal: 8.w,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          gameIcons[game],
                          size: 40.sp,
                          color: AppColors.green,
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          game,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          "Taxa de acerto",
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${overall.toStringAsFixed(0)}%",
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: AppColors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}

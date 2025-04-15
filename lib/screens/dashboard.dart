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
              'Detetive de letras e números',
              'Escrever',
              'Contar sílabas',
              'Ouvir e procurar',
              'Detetive de palavras',
              'Sílabas perdidas',
            ]
            : [
              'Detetive de letras e números',
              'Escrever',
              'Contar sílabas',
              'Ouvir e procurar',
            ];

    final allGameStats = user.gamesAccuracy;
    final int crossAxisCount = isFirstCycle ? 3 : 2;

    final gameIcons = {
      'Detetive de letras e números': Icons.search,
      'Escrever': Icons.edit,
      'Contar sílabas': Icons.format_list_numbered,
      'Ouvir e procurar': Icons.hearing,
      'Detetive de palavras': Icons.find_in_page,
      'Sílabas perdidas': Icons.extension,
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
        padding: EdgeInsets.only(right: 25),
        child: Scrollbar(
          thumbVisibility: true,
          thickness: 8,
          radius: const Radius.circular(10),
          child: Padding(
            padding: EdgeInsets.only(top: 60.h),
            child: GridView.count(
              padding: EdgeInsets.symmetric(horizontal: 150.w),
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 25.w,
              mainAxisSpacing: 25.h,
              childAspectRatio: 1.0,
              children:
                  gameNames.map((game) {
                    final levels = allGameStats[game] ?? [0.0, 0.0, 0.0];
                    final double overall =
                        levels.isNotEmpty
                            ? (levels.reduce((a, b) => a + b) / levels.length) *
                                100
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
                            FittedBox(
                              child: Text(
                                game,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
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
        ),
      ),
    );
  }
}

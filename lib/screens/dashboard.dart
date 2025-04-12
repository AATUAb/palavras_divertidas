import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
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

    // Ícones dos jogos (substituir pelos paths corretos se for imagem)
    final gameIcons = {
      'Detetive': Icons.search,
      'Escrever': Icons.edit,
      'Silabas': Icons.format_list_numbered,
      'Ouvir': Icons.hearing,
      'Detetive de palavras': Icons.find_in_page, // Atualizado
      'Sílaba perdida': Icons.remove_circle_outline, // Atualizado
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
        padding: EdgeInsets.only(top: 60.h, left: 20.w, right: 20.w),
        child: GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 16.h,
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
                    padding: EdgeInsets.all(8.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          gameIcons[game],
                          size: 28.sp,
                          color: AppColors.green,
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          "${overall.toStringAsFixed(0)}%",
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: AppColors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        SizedBox(
                          height: 90.h,
                          child: LineChart(
                            LineChartData(
                              minY: 0,
                              maxY: 100,
                              gridData: FlGridData(
                                show: true,
                                horizontalInterval: 20,
                              ),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 50,
                                    getTitlesWidget:
                                        (value, _) => Text(
                                          "${value.toInt()}%",
                                          style: TextStyle(fontSize: 10.sp),
                                        ),
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget:
                                        (value, _) => Padding(
                                          padding: EdgeInsets.only(top: 4.h),
                                          child: Text(
                                            "${value.toInt()}",
                                            style: TextStyle(fontSize: 10.sp),
                                          ),
                                        ),
                                  ),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  isCurved: true,
                                  color: AppColors.green,
                                  dotData: FlDotData(show: true),
                                  barWidth: 2,
                                  spots: List.generate(
                                    levels.length,
                                    (i) => FlSpot(i + 1.0, levels[i] * 100),
                                  ),
                                ),
                              ],
                            ),
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

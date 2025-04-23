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

    // 1️⃣ Jogos conforme o ciclo
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

    // Ícones por jogo
    final gameIcons = {
      'Detetive de letras e números': Icons.search,
      'Escrever': Icons.edit,
      'Contar sílabas': Icons.format_list_numbered,
      'Ouvir e procurar': Icons.hearing,
      'Detetive de palavras': Icons.find_in_page,
      'Sílabas perdidas': Icons.extension,
    };

    // 2️⃣ Calcula a % média (0.0–1.0) e converte para 0–100
    final allStats = user.gamesAccuracy;
    final percents =
        gameNames.map((game) {
          final stats = allStats[game] ?? [0.0];
          final avg = stats.reduce((a, b) => a + b) / stats.length;
          return (avg * 100).clamp(0.0, 100.0);
        }).toList();

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
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: AspectRatio(
          aspectRatio: 1,
          child: RadarChart(
            RadarChartData(
              // 0 no centro
              isMinValueAtCenter: true,

              // 4 círculos de referência: 25, 50, 75, 100
              tickCount: 4,

              ticksTextStyle: TextStyle(fontSize: 10.sp, color: AppColors.grey),
              tickBorderData: BorderSide(color: AppColors.grey),
              gridBorderData: BorderSide(
                color: AppColors.grey.withOpacity(0.5),
              ),

              // distância dos ícones ao centro
              titlePositionPercentageOffset: 0.25,

              dataSets: [
                RadarDataSet(
                  dataEntries:
                      percents.map((p) => RadarEntry(value: p)).toList(),
                  borderColor: AppColors.orange,
                  fillColor: AppColors.orange.withOpacity(0.3),
                  borderWidth: 2,
                  entryRadius: 3.sp,
                ),
              ],

              // ícones nos vértices em vez de texto
              getTitle:
                  (index, angle) => RadarChartTitle(
                    text: '',
                    angle: angle,
                    children: [
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Icon(
                          gameIcons[gameNames[index]]!,
                          size: 24.sp,
                          color: AppColors.orange,
                        ),
                      ),
                    ],
                  ),

              radarShape: RadarShape.polygon,
            ),
          ),
        ),
      ),
    );
  }
}

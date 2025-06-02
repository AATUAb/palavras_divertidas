import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/user_model.dart';
import '../themes/colors.dart';
import '../widgets/menu_design.dart';
import 'game_menu.dart';

class UserStats extends StatelessWidget {
  final UserModel user;
  const UserStats({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final isFirstCycle = user.schoolLevel == '1º Ciclo';
    final allGames =
        isFirstCycle
            ? [
              'Identificar letras e números',
              'Escrever',
              'Contar sílabas',
              'Ouvir e Procurar Imagem',
              'Ouvir e Procurar Palavra',
              'Sílaba perdida',
            ]
            : [
              'Identificar letras e números',
              'Escrever',
              'Contar sílabas',
              'Ouvir e Procurar Imagem',
            ];

    final gameIcons = <String, IconData>{
      'Identificar letras e números': Icons.search,
      'Escrever': Icons.edit,
      'Contar sílabas': Icons.format_list_numbered,
      'Ouvir e Procurar Imagem': Icons.hearing,
      'Ouvir e Procurar Palavra': Icons.find_in_page,
      'Sílaba perdida': Icons.extension,
    };

    Widget buildCustomRadarChart(int levelIndex, double size) {
      final n = allGames.length;
      final center = Offset(size / 2, size / 2);
      final radius = size / 2.3;

      final scores =
          allGames.map((game) {
            // obtém lista real ou vazia
            final raw = user.gamesAccuracy[game] ?? <int>[];
            // converte para percentagens 0.0–1.0
            final percents = raw.map((i) => i / 100).toList();
            // se não existir aquele nível, usa 0.0
            return levelIndex <= percents.length
                ? percents[levelIndex - 1]
                : 0.0;
          }).toList();

      return SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            CustomPaint(
              size: Size(size, size),
              painter: RadarPainter(
                scores: scores,
                center: center,
                radius: radius,
                segments: 4,
                sides: n,
                color: AppColors.green.withOpacity(0.1),
              ),
            ),
            // Substitua o for tradicional por este bloco:
            ...List.generate(n, (i) {
              final gameName = allGames[i];
              final raw = user.gamesAccuracy[gameName] ?? <int>[];
              final acc = levelIndex <= raw.length ? raw[levelIndex - 1] : 0;

              return Positioned(
                left:
                    center.dx +
                    (radius + 12) * cos(2 * pi * i / n - pi / 2) -
                    10,
                top:
                    center.dy +
                    (radius + 12) * sin(2 * pi * i / n - pi / 2) -
                    10,
                child: GestureDetector(
                  onTap: () {
                    final overlay = Overlay.of(context);
                    final overlayEntry = OverlayEntry(
                      builder:
                          (context) => Positioned(
                            // Ajuste para aparecer mesmo ao lado do ícone
                            left:
                                center.dx +
                                (radius) * cos(2 * pi * i / n - pi / 2) +
                                250,
                            top:
                                center.dy +
                                (radius) * sin(2 * pi * i / n - pi / 2) +
                                180,
                            child: Material(
                              color: Colors.transparent,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$acc%',
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                          ),
                    );
                    overlay.insert(overlayEntry);
                    Future.delayed(
                      const Duration(seconds: 1),
                      overlayEntry.remove,
                    );
                  },
                  child: Icon(
                    gameIcons[allGames[i]]!,
                    color: AppColors.orange,
                    size: 20.sp,
                  ),
                ),
              );
            }),
          ],
        ),
      );
    }

    return MenuDesign(
      titleText: 'Mundo das Palavras',
      showHomeButton: true,
      showSun: false,
      onHomePressed:
          () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => GameMenu(user: user)),
          ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          final spacing = 100.w;
          final availableWidth = maxWidth - 5 * spacing;
          final radarSize = availableWidth / 2.5;

          return Padding(
            padding: EdgeInsets.only(left: 15.w, top: 60.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Legenda com percentagens reais e tempo médio por jogo
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      allGames.map((game) {
                        final raw = user.gamesAccuracy[game] ?? <int>[];
                        // garante sempre 3 valores
                        final ints = <int>[
                          raw.isNotEmpty ? raw[0] : 0,
                          raw.length > 1 ? raw[1] : 0,
                          raw.length > 2 ? raw[2] : 0,
                        ];
                        // Tempo médio (null-safe)
                        final avgTime = user.gamesAverageTime[game];
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    gameIcons[game]!,
                                    color: AppColors.orange,
                                    size: 20.sp,
                                  ),
                                  SizedBox(width: 5.w),
                                  Text(
                                    game,
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: AppColors.orange,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 1.h),
                              Padding(
                                padding: EdgeInsets.only(left: 30.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      // mostra as percentagens de cada nível
                                      'Nível 1: ${ints[0]}%; '
                                      'Nível 2: ${ints[1]}%; '
                                      'Nível 3: ${ints[2]}%',
                                      style: TextStyle(
                                        fontSize: 6.sp,
                                        color: AppColors.green.withOpacity(0.5),
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      // mostra o tempo médio se existir
                                      avgTime != null && avgTime > 0
                                          ? 'Tempo médio: ${avgTime.toStringAsFixed(1)} s'
                                          : 'Tempo médio: sem dados',
                                      style: TextStyle(
                                        fontSize: 6.sp,
                                        color: AppColors.green.withOpacity(0.5),
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),

                SizedBox(width: 0.w),

                // Radares para cada nível
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(3, (idx) {
                      final lvl = idx + 1;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Nível $lvl',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.orange,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          buildCustomRadarChart(lvl, radarSize),
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Desenha o radar — ficou igual à tua implementação original
class RadarPainter extends CustomPainter {
  final List<double> scores;
  final Offset center;
  final double radius;
  final int segments;
  final int sides;
  final Color color;

  RadarPainter({
    required this.scores,
    required this.center,
    required this.radius,
    required this.segments,
    required this.sides,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintGrid =
        Paint()
          ..color = Colors.grey.withOpacity(0.5)
          ..style = PaintingStyle.stroke;
    final paintRadar =
        Paint()
          ..color = color.withOpacity(0.5)
          ..style = PaintingStyle.fill;
    final paintBorder =
        Paint()
          ..color = color
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;
    final textStyle = TextStyle(color: Colors.grey[600], fontSize: 5);

    // grade
    for (int s = 1; s <= segments; s++) {
      final path = Path();
      for (int i = 0; i < sides; i++) {
        final angle = 2 * pi * i / sides - pi / 2;
        final point = Offset(
          center.dx + radius * s / segments * cos(angle),
          center.dy + radius * s / segments * sin(angle),
        );
        if (i == 0)
          path.moveTo(point.dx, point.dy);
        else
          path.lineTo(point.dx, point.dy);
      }
      path.close();
      canvas.drawPath(path, paintGrid);

      // rótulo
      final labelOffset = Offset(
        center.dx - 12,
        center.dy - radius * s / segments - 3,
      );
      final tp = TextPainter(
        text: TextSpan(text: '${s * 25}%', style: textStyle),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, labelOffset);
    }

    // área
    final path = Path();
    final points = <Offset>[];
    for (int i = 0; i < sides; i++) {
      final angle = 2 * pi * i / sides - pi / 2;
      final value = max(scores[i].clamp(0.0, 1.0), 0.05);
      final point = Offset(
        center.dx + radius * value * cos(angle),
        center.dy + radius * value * sin(angle),
      );
      if (i == 0)
        path.moveTo(point.dx, point.dy);
      else
        path.lineTo(point.dx, point.dy);
      points.add(point);
    }
    path.close();
    canvas.drawPath(path, paintRadar);
    canvas.drawPath(path, paintBorder);

    // círculos
    final centerCircle =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 3, centerCircle);
    for (final p in points) canvas.drawCircle(p, 2, centerCircle);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

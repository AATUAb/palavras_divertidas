// Cartão visual para apresentar cada jogo no menu.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../themes/colors.dart';

/// Widget visual que representa um card de jogo no menu principal.
class GameCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? iconColor;

  const GameCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícone circular com cor de fundo
              Material(
                elevation: 4,
                shape: const CircleBorder(),
                color: backgroundColor ?? AppColors.orange,
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Icon(
                    icon,
                    size: 36.sp,
                    color: iconColor ?? AppColors.black,
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              // Título do jogo
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBlue,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget que exibe uma grelha de jogos com layout adaptável
class GamesGrid extends StatelessWidget {
  final List<GameCardData> games;
  final int crossAxisCount;
  final double spacing;

  const GamesGrid({
    super.key,
    required this.games,
    this.crossAxisCount = 3,
    this.spacing = 20,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing.w,
        mainAxisSpacing: spacing.h,
        childAspectRatio: 0.8,
      ),
      itemCount: games.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final game = games[index];
        return GameCard(
          title: game.title,
          icon: game.icon,
          onTap: game.onTap,
          backgroundColor: game.backgroundColor,
          iconColor: game.iconColor,
        );
      },
    );
  }
}

/// Modelo para representar os dados de cada jogo
class GameCardData {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? iconColor;

  GameCardData({
    required this.title,
    required this.icon,
    required this.onTap,
    this.backgroundColor,
    this.iconColor,
  });
}

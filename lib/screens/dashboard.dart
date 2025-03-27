import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/user_model.dart';
import '../themes/colors.dart';

class DashboardScreen extends StatelessWidget {
  final UserModel user;

  const DashboardScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        backgroundColor: AppColors.green,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoTile("👤 Nome", user.name),
            _buildInfoTile("🎓 Nível", user.level),
            _buildInfoTile(
              "🔠 Letras aprendidas",
              user.knownLetters.join(", "),
            ),
            _buildInfoTile("🎮 Total de jogos", "${user.knownLetters.length}"),
            _buildInfoTile(
              "⏱️ Taxa de acerto (simulada)",
              "${_calculateAccuracy()}%",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Text(
            "$title: ",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.darkBlue,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16.sp, color: AppColors.grey),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  int _calculateAccuracy() {
    // Simulação temporária: 80% se aprendeu mais que 5 letras
    return user.knownLetters.length > 5 ? 80 : 60;
  }
}

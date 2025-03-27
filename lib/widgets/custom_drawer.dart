import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../themes/colors.dart';

class CustomDrawer extends StatelessWidget {
  final String userName;
  final String userLevel;
  final VoidCallback onManageUsers;
  final VoidCallback onAchievements;
  final VoidCallback onDashboard;

  const CustomDrawer({
    super.key,
    required this.userName,
    required this.userLevel,
    required this.onManageUsers,
    required this.onAchievements,
    required this.onDashboard,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.lightGrey,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔹 Cabeçalho
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            vertical: 15.h,
                            horizontal: 15.w,
                          ),
                          decoration: const BoxDecoration(
                            color: AppColors.green,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.account_circle,
                                size: 60.sp,
                                color: AppColors.white,
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                userName,
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 30.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                userLevel,
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 10.h),

                        // 🔹 Itens do Menu
                        _buildTile(
                          icon: Icons.group,
                          label: "Utilizadores",
                          onTap: onManageUsers,
                        ),
                        _buildTile(
                          icon: Icons.emoji_events,
                          label: "Conquistas",
                          onTap: onAchievements,
                        ),
                        _buildTile(
                          icon: Icons.dashboard,
                          label: "Dashboard",
                          onTap: onDashboard,
                        ),

                        // Padding final opcional
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.grey, size: 24.sp),
      title: Text(
        label,
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
      horizontalTitleGap: 12.w,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      hoverColor: AppColors.lightBlue.withOpacity(0.2),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/user_model.dart';
import '../services/hive_service.dart';
import '../themes/colors.dart';
import 'add_user_dialog.dart';
import 'game_menu.dart';
import '../widgets/menu_design.dart';
import 'letters_selection.dart';
import 'dart:math';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<UserModel> users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    setState(() {
      users = HiveService.getUsers();
    });
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AddUserDialog(
          onUserAdded: (name, schoolLevel, letters) async {
            final newUser = UserModel(
              name: name,
              schoolLevel: schoolLevel,
              knownLetters: letters,
              gameLevel: 1,
            );
            await HiveService.addUser(newUser);
            _loadUsers();
          },
        );
      },
    );
  }

  void _showEditUserDialog(int index, UserModel user) {
    showDialog(
      context: context,
      builder: (context) {
        return AddUserDialog(
          initialName: user.name,
          initialSchoolLevel: user.schoolLevel,
          onUserAdded: (name, schoolLevel, letters) async {
            final updatedUser = UserModel(
              name: name,
              schoolLevel: schoolLevel,
              knownLetters: letters,
              gameLevel: user.gameLevel,
              accuracyByLevel: user.accuracyByLevel,
              overallAccuracy: user.overallAccuracy,
            );
            await HiveService.updateUser(index, updatedUser);
            _loadUsers();
          },
          onDelete: () async {
            await HiveService.deleteUser(index);
            _loadUsers();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double cardWidth = min(180.w, 0.28.sw);

    return Scaffold(
      body: MenuDesign(
        child: SingleChildScrollView(
          child: Transform.translate(
            offset: Offset(0, -35.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 0.h),
                Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: SizedBox(
                    width: 280.w,
                    height: 60.h,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.people,
                                color: AppColors.orange,
                                size: 25.sp,
                              ),
                              SizedBox(width: 6.w),
                              Flexible(
                                child: Text(
                                  'Quem vai jogar hoje?',
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 25.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkBlue,
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
                SizedBox(height: 25.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Wrap(
                    spacing: 10.w,
                    runSpacing: 10.h,
                    alignment: WrapAlignment.center,
                    children: [
                      ...users.asMap().entries.map(
                        (entry) => SizedBox(
                          width: cardWidth,
                          child: _buildUserCard(entry.key),
                        ),
                      ),
                      SizedBox(width: cardWidth, child: _buildAddUserButton()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(int index) {
    final user = users[index];
    final Color cardColor =
        user.schoolLevel == "Pré-Escolar" ? AppColors.green : AppColors.orange;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 200.w),
      child: Card(
        color: cardColor.withAlpha((255 * 0.8).toInt()),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        elevation: 3,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GameMenu(user: user)),
            ).then((_) => _loadUsers());
          },
          borderRadius: BorderRadius.circular(20.r),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(8.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 30.r,
                          backgroundColor: AppColors.white,
                          child: Icon(
                            user.schoolLevel == "Pré-Escolar"
                                ? Icons.child_care
                                : Icons.school,
                            size: 40.sp,
                            color: cardColor,
                          ),
                        ),
                        if (user.schoolLevel == "1º Ciclo")
                          Padding(
                            padding: EdgeInsets.only(left: 6.w),
                            child: ElevatedButton(
                              onPressed: () {
                                showLettersDialog(
                                  context: context,
                                  initialSelection: user.knownLetters,
                                  onSaved: (selectedLetters) {
                                    final updatedUser = user.copyWith(
                                      knownLetters: selectedLetters,
                                    );
                                    HiveService.updateUser(index, updatedUser);
                                    _loadUsers();
                                  },
                                );
                              },
                              child: Text("Letras?", style: TextStyle(fontSize: 12.sp)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.green,
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                minimumSize: Size.zero,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Text(
                        user.name,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      user.schoolLevel,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.white.withAlpha((255 * 0.9).toInt()),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 5.h,
                right: 5.w,
                child: IconButton(
                  onPressed: () => _showEditUserDialog(index, user),
                  icon: Icon(Icons.edit, color: AppColors.white, size: 18.sp),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddUserButton() {
    return SizedBox(
      width: 160.w,
      child: Card(
        color: AppColors.lightGrey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: BorderSide(color: AppColors.grey, width: 2.w),
        ),
        elevation: 3,
        child: InkWell(
          onTap: _showAddUserDialog,
          borderRadius: BorderRadius.circular(20.r),
          child: Padding(
            padding: EdgeInsets.all(8.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle, size: 60.sp, color: AppColors.green),
                SizedBox(height: 10.h),
                Text(
                  "Adiciona Utilizador",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

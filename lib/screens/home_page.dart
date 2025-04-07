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
  final ScrollController _scrollController = ScrollController();
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
    double cardWidth = min(160.w, 0.26.sw);

    return Scaffold(
      body: MenuDesign(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 6.h),
            Padding(
              padding: EdgeInsets.only(bottom: 4.h),
              child: SizedBox(
                width: 280.w,
                height: 30.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people,
                      color: AppColors.orange,
                      size: 20.sp,
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
            ),
            SizedBox(height: 6.h),
            SizedBox(
              height: 90.h,
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(scrollbars: true),
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  thickness: 10.w,
                  radius: Radius.circular(8.r),
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.only(left: 16.w, right: 8.w, bottom: 10.h),
                    itemCount: users.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: EdgeInsets.only(right: 10.w),
                          child: SizedBox(width: cardWidth, child: _buildAddUserButton()),
                        );
                      } else {
                        return Padding(
                          padding: EdgeInsets.only(right: 10.w),
                          child: SizedBox(
                            width: cardWidth,
                            child: _buildUserCard(index - 1),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
          ],
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
                          radius: 20.r,
                          backgroundColor: AppColors.white,
                          child: Icon(
                            user.schoolLevel == "Pré-Escolar"
                                ? Icons.child_care
                                : Icons.school,
                            size: 26.sp,
                            color: cardColor,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (user.schoolLevel == "1º Ciclo")
                              ElevatedButton(
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
                                child: Text("Letras?", style: TextStyle(fontSize: 9.sp)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.green,
                                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  minimumSize: Size.zero,
                                ),
                              ),
                            Text(
                              user.schoolLevel,
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: AppColors.white.withAlpha((255 * 0.9).toInt()),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      user.name,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 5.h,
                right: 5.w,
                child: IconButton(
                  onPressed: () => _showEditUserDialog(index, user),
                  icon: Icon(Icons.edit, color: AppColors.white, size: 16.sp),
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
        color: AppColors.lightGrey.withAlpha((255 * 0.8).toInt()),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        elevation: 3,
        child: InkWell(
          onTap: _showAddUserDialog,
          borderRadius: BorderRadius.circular(20.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle, size: 32.sp, color: AppColors.green),
                SizedBox(height: 6.h),
                Text(
                  "Adiciona Utilizador",
                  style: TextStyle(
                    fontSize: 11.sp,
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
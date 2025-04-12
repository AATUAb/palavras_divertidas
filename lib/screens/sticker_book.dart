import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../themes/colors.dart';
import '../widgets/menu_design.dart';
import 'game_menu.dart'; // Certifica-te de que o caminho está correto

class Sticker {
  final String name;
  final String imagePath;
  bool unlocked;

  Sticker({required this.name, required this.imagePath, this.unlocked = false});
}

class StickerBookScreen extends StatefulWidget {
  final dynamic user; // Usa UserModel se tiveres o tipo definido

  const StickerBookScreen({super.key, required this.user});

  @override
  State<StickerBookScreen> createState() => _StickerBookScreenState();
}

class _StickerBookScreenState extends State<StickerBookScreen> {
  final List<Sticker> stickers = [
    Sticker(
      name: 'Macaco',
      imagePath: 'assets/stickers/monkey.jpg',
      unlocked: false,
    ),
    Sticker(
      name: 'Elefante',
      imagePath: 'assets/stickers/elephant.jpg',
      unlocked: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.green,
        child: const Icon(Icons.lock_open),
        onPressed: () {
          setState(() {
            for (var sticker in stickers) {
              sticker.unlocked = true;
            }
          });
        },
      ),
      body: MenuDesign(
        headerText: 'Conquistas',
        showHomeButton: true,
        onHomePressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => GameMenu(user: widget.user),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.only(top: 100.h, left: 250.w, right: 250.w),
          child: GridView.builder(
            itemCount: stickers.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15.w,
              mainAxisSpacing: 15.h,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) => _buildStickerCard(stickers[index]),
          ),
        ),
      ),
    );
  }

  Widget _buildStickerCard(Sticker sticker) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ColorFiltered(
          colorFilter:
              sticker.unlocked
                  ? const ColorFilter.mode(
                    Colors.transparent,
                    BlendMode.multiply,
                  )
                  : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
          child: Opacity(
            opacity: sticker.unlocked ? 1.0 : 0.2,
            child: Image.asset(
              sticker.imagePath,
              height: 80.h,
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          sticker.name,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: sticker.unlocked ? AppColors.darkBlue : AppColors.grey,
          ),
        ),
        if (!sticker.unlocked)
          Icon(Icons.lock, color: AppColors.grey, size: 16.sp),
      ],
    );
  }
}

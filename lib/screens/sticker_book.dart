import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../themes/colors.dart';

class Sticker {
  final String name;
  final String imagePath;
  bool unlocked;

  Sticker({required this.name, required this.imagePath, this.unlocked = false});
}

class StickerBookScreen extends StatefulWidget {
  const StickerBookScreen({super.key});

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
      appBar: AppBar(
        title: Text(
          'Caderneta de Cromos',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.green,
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: GridView.builder(
          itemCount: stickers.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) => _buildStickerCard(stickers[index]),
        ),
      ),
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

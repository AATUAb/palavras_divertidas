import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../themes/colors.dart';

Future<void> showLettersDialog({
  required BuildContext context,
  required List<String> initialSelection,
  required void Function(List<String> selectedLetters) onSaved,
}) async {
  final List<String> letters = [
    "Vogais: A, E,I, O, U", "P", "T", "L", "D", "M", "V",
    "C", "Q", "N", "R", "B", "G", "J", "F", "S", "Z", "H", "X",
    "CH", "LH", "NH",
    "BR, CR, DR, FR, GR, PR, TR, VR",
    "BL, CL, FL, GL, PL, TL",
  ];

  Map<String, bool> selectedMap = {
    for (var l in letters) l: initialSelection.contains(l),
  };

  bool selectAll = selectedMap.values.every((e) => e);

  await showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 500.h),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Seleciona as letras que já aprendeste",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBlue,
                ),
              ),
              SizedBox(height: 12.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        selectAll = !selectAll;
                        selectedMap.updateAll((key, _) => selectAll);
                        (context as Element).markNeedsBuild();
                      },
                      icon: Icon(
                        selectAll ? Icons.check_box : Icons.check_box_outline_blank,
                        size: 16.sp,
                        color: AppColors.green,
                      ),
                      label: Text(
                        "Selecionar todas",
                        style: TextStyle(fontSize: 12.sp, color: AppColors.green),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        selectedMap.updateAll((key, _) => false);
                        selectAll = false;
                        (context as Element).markNeedsBuild();
                      },
                      icon: Icon(Icons.clear, size: 16.sp, color: AppColors.red),
                      label: Text(
                        "Limpar seleção",
                        style: TextStyle(fontSize: 12.sp, color: AppColors.red),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: letters.map((letter) {
                      final isSelected = selectedMap[letter] ?? false;
                      return GestureDetector(
                        onTap: () {
                          selectedMap[letter] = !isSelected;
                          selectAll = selectedMap.values.every((v) => v);
                          (context as Element).markNeedsBuild();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.green : AppColors.lightGrey,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: isSelected ? AppColors.green : AppColors.grey),
                          ),
                          child: Text(
                            letter,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.cancel, size: 16.sp, color: AppColors.grey),
                    label: Text("Cancelar", style: TextStyle(color: AppColors.grey)),
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.save, size: 16.sp),
                    label: Text("Guardar"),
                    onPressed: () {
                      final selected = selectedMap.entries
                          .where((e) => e.value)
                          .map((e) => e.key)
                          .toList();
                      onSaved(selected);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

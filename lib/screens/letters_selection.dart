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
              CheckboxListTile(
                title: Text("Todas", style: TextStyle(fontSize: 13.sp)),
                value: selectAll,
                onChanged: (value) {
                  selectAll = value ?? false;
                  selectedMap.updateAll((key, _) => selectAll);
                  (context as Element).markNeedsBuild();
                },
              ),
              SizedBox(height: 8.h),
              Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  thickness: 4.w,
                  radius: Radius.circular(8.r),
                  child: ListView.builder(
                    itemCount: letters.length,
                    itemBuilder: (context, index) {
                      final letter = letters[index];
                      return CheckboxListTile(
                        title: Text(letter, style: TextStyle(fontSize: 13.sp)),
                        value: selectedMap[letter],
                        onChanged: (value) {
                          selectedMap[letter] = value ?? false;
                          selectAll = selectedMap.values.every((v) => v);
                          (context as Element).markNeedsBuild();
                        },
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancelar", style: TextStyle(color: AppColors.grey)),
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

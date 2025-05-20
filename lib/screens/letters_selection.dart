// Caixa de seleçºao de letras para o 1º ciclo
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:audioplayers/audioplayers.dart';
import '../themes/colors.dart';

Future<void> showLettersDialog({
  required BuildContext context,
  required List<String> initialSelection,
  required void Function(List<String> selectedLetters) onSaved,
}) async {
  final List<String> letters = [
    "Vogais: A,E, I, O, U", "P", "T", "L", "D", "M", "V",
    "C", "Q", "N", "R", "B", "G", "J", "F", "S", "Z", "H", "X",
    "CH", "LH", "NH",
    "BR, CR, DR, FR, GR, PR, TR, VR",
    "BL, CL, FL, GL, PL, TL",
  ];

  Map<String, bool> selectedMap = {
    for (var l in letters) l: initialSelection.contains(l),
  };

  bool selectAll = selectedMap.values.every((v) => v);
  bool allSelectedMode = false;

  final player = AudioPlayer();
  final ValueNotifier<bool> introPlayed = ValueNotifier(false);

 void playIntroSoundOnce(AudioPlayer player, bool hasPlayed, void Function() markAsPlayed) {
  if (!hasPlayed) {
    markAsPlayed();
    player.stop().then((_) {
      player.play(AssetSource('sounds/select_letters.ogg'));
    });
  }
}
 
  await showDialog(
  context: context,
  builder: (context) => StatefulBuilder(
    builder: (context, setState) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        playIntroSoundOnce(player, introPlayed.value, () => introPlayed.value = true);
      });

      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 500.h),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                        Text(
                        "Escolhe as letras ou sons que já aprendeste na escola",
                        style: TextStyle(
                          fontSize: 20.sp,
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
                                allSelectedMode = selectAll;
                                selectedMap.updateAll((key, _) => selectAll);
                                setState(() {});
                              },
                              icon: Icon(
                                selectAll ? Icons.check_box : Icons.check_box_outline_blank,
                                size: 20.sp,
                                color: AppColors.green,
                              ),
                              label: Text(
                                "Todas",
                                style: TextStyle(fontSize: 20.sp, color: AppColors.green),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                selectedMap.updateAll((key, _) => false);
                                selectAll = false;
                                allSelectedMode = false;
                                setState(() {});
                              },
                              icon: Icon(Icons.clear, size: 20.sp, color: AppColors.red),
                              label: Text(
                                "Limpar",
                                style: TextStyle(fontSize: 20.sp, color: AppColors.red),
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
                            children: letters.asMap().entries.map((entry) {
                              final index = entry.key;
                              final letter = entry.value;
                              final isSelected = selectedMap[letter] ?? false;

                              final lastSelectedIndex = letters.lastIndexWhere((l) => selectedMap[l] == true);
                              final canTap = index == 0 || index == lastSelectedIndex + 1 || isSelected;

                              return GestureDetector(
                                onTap: () async {
                                  if (allSelectedMode) {
                                    await player.stop();
                                    await player.play(AssetSource('sounds/animations/clear_letters.ogg'));

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Tens de limpar tudo antes de escolher letras manualmente."),
                                        backgroundColor: Colors.orange,
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                    return;
                                  }

                                  if (canTap) {
                                    selectedMap[letter] = !isSelected;
                                    selectAll = selectedMap.values.every((v) => v);
                                    setState(() {});
                                  } else {
                                    try {
                                    await player.stop();
                                    await player.play(AssetSource('sounds/animations/before_leter.ogg'));
                                    } catch (e) {
                                      debugPrint('Erro ao reproduzir som: $e');
                                    }

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Ainda não clicaste na opção anterior."),
                                        backgroundColor: Colors.orange,
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                                child: Opacity(
                                  opacity: canTap ? 1.0 : 0.4,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.green : AppColors.lightGrey,
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: isSelected ? AppColors.green : AppColors.grey,
                                      ),
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
                            icon: Icon(Icons.cancel, size: 20.sp, color: AppColors.grey),
                            label: Text("Cancelar", style: TextStyle(color: AppColors.grey)),
                          ),
                          ElevatedButton.icon(
                            icon: Icon(Icons.save, size: 20.sp),
                            label: Text("OK"),
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
          ),
        );
      },
    ),
  );
}



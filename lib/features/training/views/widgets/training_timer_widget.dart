import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/features/training/controllers/training_controller.dart';

/// Widget del timer compacto estilo iOS
class TrainingTimerWidget extends StatelessWidget {
  const TrainingTimerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TrainingController>();
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark
            ? CupertinoColors.darkBackgroundGray
            : CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.clock,
            color: isDark
                ? CupertinoColors.systemGrey
                : CupertinoColors.systemGrey2,
            size: 20,
          ),
          const SizedBox(width: 8),
          Obx(
            () => Text(
              controller.formattedTime,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: controller.isPaused.value
                    ? CupertinoColors.systemOrange
                    : CupertinoColors.activeBlue,
                letterSpacing: 1,
              ),
            ),
          ),
          Obx(
            () => controller.isPaused.value
                ? Row(
                    children: [
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemOrange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'PAUSA',
                          style: TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}


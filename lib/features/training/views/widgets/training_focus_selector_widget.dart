import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/features/training/controllers/training_controller.dart';
import 'package:tribbe_app/shared/utils/workout_utils.dart';
import 'package:tribbe_app/shared/widgets/focus_selector_modal.dart';

/// Widget para mostrar y cambiar el enfoque del entrenamiento
class TrainingFocusSelectorWidget extends StatelessWidget {
  const TrainingFocusSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TrainingController>();
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final focus = controller.focusType.value;
      final color = WorkoutUtils.getFocusColor(focus);
      final icon = WorkoutUtils.getFocusIcon(focus);

      return GestureDetector(
        onTap: () async {
          final newFocus = await FocusSelectorModal.show(
            context: context,
            currentFocus: focus,
          );

          if (newFocus != null && newFocus != focus) {
            controller.changeFocus(newFocus);
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: WorkoutUtils.getGradientColors(focus, isDark: isDark),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: CupertinoColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: CupertinoColors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enfoque de Entrenamiento',
                      style: TextStyle(
                        fontSize: 11,
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      focus,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: CupertinoColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Cambiar',
                      style: TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      CupertinoIcons.chevron_right,
                      color: CupertinoColors.white,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}


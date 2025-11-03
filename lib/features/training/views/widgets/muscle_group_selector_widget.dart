import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/features/training/controllers/training_controller.dart';
import 'package:tribbe_app/shared/models/exercise_model.dart';

/// Widget para seleccionar el grupo muscular del entrenamiento
class MuscleGroupSelectorWidget extends StatelessWidget {
  const MuscleGroupSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TrainingController>();
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? CupertinoColors.darkBackgroundGray
            : CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Grupo Muscular',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? CupertinoColors.systemGrey
                    : CupertinoColors.systemGrey2,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                _buildChip(
                  label: 'Todos',
                  isSelected: controller.selectedMuscleGroup.value == null,
                  onTap: () => controller.changeMuscleGroup(null),
                  isDark: isDark,
                ),
                ...MuscleGroups.all.map((muscleGroup) {
                  return _buildChip(
                    label: muscleGroup,
                    isSelected:
                        controller.selectedMuscleGroup.value == muscleGroup,
                    onTap: () => controller.changeMuscleGroup(muscleGroup),
                    isDark: isDark,
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? CupertinoColors.activeBlue
                : (isDark
                    ? CupertinoColors.systemGrey5
                    : CupertinoColors.white),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? CupertinoColors.activeBlue
                  : (isDark
                      ? CupertinoColors.systemGrey4
                      : CupertinoColors.systemGrey5),
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? CupertinoColors.white
                  : (isDark
                      ? CupertinoColors.white
                      : CupertinoColors.black),
            ),
          ),
        ),
      ),
    );
  }
}


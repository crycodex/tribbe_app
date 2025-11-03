import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/app/routes/route_paths.dart';
import 'package:tribbe_app/shared/models/exercise_model.dart';
import 'package:tribbe_app/features/training/controllers/training_controller.dart';

/// Widget de ejercicios sugeridos - Reactivo al filtro de grupo muscular
class SuggestedExercisesWidget extends StatelessWidget {
  final List<ExerciseTemplate> exercises;
  final Function(ExerciseTemplate) onExerciseSelected;

  const SuggestedExercisesWidget({
    super.key,
    required this.exercises,
    required this.onExerciseSelected,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TrainingController>();
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return Obx(() {
      // Reactivo a cambios en availableExercises
      final suggested = controller.availableExercises.take(6).toList();

      if (suggested.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              'No hay ejercicios disponibles para este filtro',
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? CupertinoColors.systemGrey
                    : CupertinoColors.systemGrey2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ejercicios sugeridos',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color:
                        isDark ? CupertinoColors.white : CupertinoColors.black,
                  ),
                ),
                if (controller.selectedMuscleGroup.value != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: CupertinoColors.activeBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      controller.selectedMuscleGroup.value!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: suggested.length,
              itemBuilder: (context, index) {
                final exercise = suggested[index];
                return _SuggestedExerciseCard(
                  exercise: exercise,
                  isDark: isDark,
                  onTap: () => onExerciseSelected(exercise),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}

class _SuggestedExerciseCard extends StatelessWidget {
  final ExerciseTemplate exercise;
  final bool isDark;
  final VoidCallback onTap;

  const _SuggestedExerciseCard({
    required this.exercise,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? CupertinoColors.darkBackgroundGray
              : CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? CupertinoColors.systemGrey
                : CupertinoColors.systemGrey4,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Header con íconos
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(
                  CupertinoIcons.add_circled_solid,
                  color: CupertinoColors.activeBlue,
                  size: 24,
                ),
                // Botón de información
                GestureDetector(
                  onTap: () {
                    Get.toNamed(
                      RoutePaths.exerciseDetail,
                      arguments: {'exerciseId': exercise.id},
                    );
                  },
                  child: Icon(
                    CupertinoIcons.info_circle,
                    size: 20,
                    color: isDark
                        ? CupertinoColors.systemGrey
                        : CupertinoColors.systemGrey2,
                  ),
                ),
              ],
            ),
            // Info del ejercicio
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? CupertinoColors.white
                        : CupertinoColors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  exercise.equipment,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? CupertinoColors.systemGrey
                        : CupertinoColors.systemGrey2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

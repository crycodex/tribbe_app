import 'package:flutter/cupertino.dart';
import 'package:tribbe_app/shared/models/exercise_model.dart';

/// Widget de ejercicios sugeridos
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
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final suggested = exercises.take(6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Ejercicios sugeridos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDark ? CupertinoColors.white : CupertinoColors.black,
            ),
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
            const Icon(
              CupertinoIcons.add_circled_solid,
              color: CupertinoColors.activeBlue,
              size: 24,
            ),
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

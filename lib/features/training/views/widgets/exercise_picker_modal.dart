import 'package:flutter/cupertino.dart';
import 'package:tribbe_app/shared/models/exercise_model.dart';

/// Modal para seleccionar ejercicio estilo Cupertino
class ExercisePickerModal extends StatelessWidget {
  final List<ExerciseTemplate> exercises;
  final Function(ExerciseTemplate) onExerciseSelected;

  const ExercisePickerModal({
    super.key,
    required this.exercises,
    required this.onExerciseSelected,
  });

  static void show({
    required BuildContext context,
    required List<ExerciseTemplate> exercises,
    required Function(ExerciseTemplate) onExerciseSelected,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => ExercisePickerModal(
        exercises: exercises,
        onExerciseSelected: onExerciseSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: isDark
            ? CupertinoColors.darkBackgroundGray
            : CupertinoColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(context, isDark),
          Expanded(
            child: ListView.builder(
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];
                return CupertinoListTile(
                  title: Text(exercise.name),
                  subtitle: Text(
                    '${exercise.muscleGroup} • ${exercise.equipment}',
                  ),
                  trailing: const Icon(CupertinoIcons.add_circled),
                  onTap: () {
                    Navigator.pop(context);
                    onExerciseSelected(exercise);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? CupertinoColors.systemGrey
                : CupertinoColors.systemGrey5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Seleccionar Ejercicio',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.none,
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(context),
            child: const Icon(CupertinoIcons.xmark_circle_fill),
          ),
        ],
      ),
    );
  }
}

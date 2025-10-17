import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/app/routes/route_paths.dart';
import 'package:tribbe_app/features/training/controllers/training_controller.dart';
import 'package:tribbe_app/shared/data/exercises_data.dart';

/// Widget de item de ejercicio en la lista
class ExerciseListItemWidget extends StatelessWidget {
  final ExerciseData exercise;
  final bool isBeingEdited;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ExerciseListItemWidget({
    super.key,
    required this.exercise,
    required this.isBeingEdited,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: Key(
        'exercise_${exercise.name}_${DateTime.now().millisecondsSinceEpoch}',
      ),
      direction: isBeingEdited
          ? DismissDirection.none
          : DismissDirection.horizontal,
      background: _buildSwipeBackground(
        alignment: Alignment.centerLeft,
        color: CupertinoColors.systemOrange,
        icon: CupertinoIcons.pencil_circle_fill,
        label: 'Editar',
      ),
      secondaryBackground: _buildSwipeBackground(
        alignment: Alignment.centerRight,
        color: CupertinoColors.systemRed,
        icon: CupertinoIcons.delete_solid,
        label: 'Eliminar',
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onEdit();
          return false;
        }
        return true;
      },
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isBeingEdited
              ? LinearGradient(
                  colors: [
                    CupertinoColors.systemOrange.withValues(alpha: 0.15),
                    CupertinoColors.systemOrange.withValues(alpha: 0.05),
                  ],
                )
              : null,
          color: isBeingEdited
              ? null
              : (isDark
                    ? CupertinoColors.darkBackgroundGray
                    : CupertinoColors.systemGrey6),
          borderRadius: BorderRadius.circular(12),
          border: isBeingEdited
              ? Border.all(color: CupertinoColors.systemOrange, width: 2)
              : null,
          boxShadow: isBeingEdited
              ? [
                  BoxShadow(
                    color: CupertinoColors.systemOrange.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(isDark),
            const SizedBox(height: 12),
            ..._buildSetsList(isDark),
            const SizedBox(height: 8),
            Divider(
              color: isDark
                  ? CupertinoColors.systemGrey
                  : CupertinoColors.systemGrey5,
            ),
            const SizedBox(height: 4),
            _buildVolumeInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildSwipeBackground({
    required Alignment alignment,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: alignment,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: CupertinoColors.white, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (isBeingEdited) _buildEditingBadge(),
                  Expanded(
                    child: Text(
                      exercise.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? CupertinoColors.white
                            : CupertinoColors.black,
                      ),
                    ),
                  ),
                ],
              ),
              if (!isBeingEdited) _buildSwipeHints(isDark),
            ],
          ),
        ),
        // Botón de información del ejercicio
        CupertinoButton(
          padding: EdgeInsets.zero,
          minSize: 0,
          onPressed: () {
            // Buscar el ejercicio por nombre en la data
            final exerciseTemplate = ExercisesData.exercises.firstWhere(
              (ex) => ex.name == exercise.name,
              orElse: () => ExercisesData.exercises.first,
            );
            Get.toNamed(
              RoutePaths.exerciseDetail,
              arguments: {'exerciseId': exerciseTemplate.id},
            );
          },
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            child: Icon(
              CupertinoIcons.info_circle,
              size: 20,
              color: CupertinoColors.activeBlue.withOpacity(0.7),
            ),
          ),
        ),
        // Badge de series
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: CupertinoColors.activeBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${exercise.sets.length} series',
            style: const TextStyle(
              fontSize: 11,
              color: CupertinoColors.activeBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditingBadge() {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: CupertinoColors.systemOrange,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(CupertinoIcons.pencil, color: CupertinoColors.white, size: 10),
          SizedBox(width: 4),
          Text(
            'EDITANDO',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeHints(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.arrow_right,
            size: 12,
            color: CupertinoColors.systemOrange.withOpacity(0.5),
          ),
          const SizedBox(width: 4),
          Text(
            'Editar',
            style: TextStyle(
              fontSize: 10,
              color: isDark
                  ? CupertinoColors.systemGrey2
                  : CupertinoColors.systemGrey3,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            CupertinoIcons.arrow_left,
            size: 12,
            color: CupertinoColors.systemRed.withOpacity(0.5),
          ),
          const SizedBox(width: 4),
          Text(
            'Eliminar',
            style: TextStyle(
              fontSize: 10,
              color: isDark
                  ? CupertinoColors.systemGrey2
                  : CupertinoColors.systemGrey3,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSetsList(bool isDark) {
    return exercise.sets.asMap().entries.map((entry) {
      final index = entry.key;
      final set = entry.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: CupertinoColors.activeBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.activeBlue,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${set.weight} kg × ${set.reps} reps',
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? CupertinoColors.systemGrey
                    : CupertinoColors.systemGrey2,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildVolumeInfo() {
    return Row(
      children: [
        const Icon(
          CupertinoIcons.chart_bar_circle,
          size: 16,
          color: CupertinoColors.activeGreen,
        ),
        const SizedBox(width: 6),
        Text(
          'Volumen total: ${exercise.totalVolume.toStringAsFixed(1)} kg',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.activeGreen,
          ),
        ),
      ],
    );
  }
}

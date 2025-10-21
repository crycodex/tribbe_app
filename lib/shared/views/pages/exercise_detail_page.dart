import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/shared/controllers/exercises_controller.dart';
import 'package:tribbe_app/shared/models/exercise_model.dart';

/// Página de Detalle de Ejercicio - Estilo Minimalista Cupertino
class ExerciseDetailPage extends StatelessWidget {
  const ExerciseDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ExercisesController>();
    final args = Get.arguments as Map<String, dynamic>;
    final exerciseId = args['exerciseId'] as String;
    final exercise = controller.getExerciseById(exerciseId);

    if (exercise == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64),
              const SizedBox(height: 16),
              const Text('Ejercicio no encontrado'),
              const SizedBox(height: 16),
              CupertinoButton.filled(
                onPressed: () => Get.back(),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          // AppBar
          _buildAppBar(exercise, isDark),

          // Contenido
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con nombre y badges
                  _buildHeader(exercise, isDark),

                  const SizedBox(height: 24),

                  // Información básica
                  _buildInfoCard(exercise, isDark),

                  const SizedBox(height: 24),

                  // Músculos trabajados
                  _buildMusclesSection(exercise, isDark),

                  const SizedBox(height: 24),

                  // Instrucciones
                  if (exercise.instructions != null &&
                      exercise.instructions!.isNotEmpty)
                    _buildInstructionsSection(exercise, isDark),

                  const SizedBox(height: 24),

                  // Errores comunes (si están disponibles)
                  if (exercise.commonMistakes != null &&
                      exercise.commonMistakes!.isNotEmpty)
                    _buildMistakesSection(exercise, isDark),

                  const SizedBox(height: 24),

                  // Tips profesionales (si están disponibles)
                  if (exercise.proTips != null && exercise.proTips!.isNotEmpty)
                    _buildProTipsSection(exercise, isDark),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// AppBar
  Widget _buildAppBar(ExerciseTemplate exercise, bool isDark) {
    return CupertinoSliverNavigationBar(
      backgroundColor: isDark ? Colors.black : Colors.grey.shade50,
      largeTitle: const Text('Detalle'),
      leading: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => Get.back(),
        child: Icon(
          CupertinoIcons.back,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  /// Header con nombre y badges
  Widget _buildHeader(ExerciseTemplate exercise, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nombre
        Text(
          exercise.name,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),

        const SizedBox(height: 12),

        // Badges
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildBadge(
              exercise.muscleGroup,
              _getMuscleGroupColor(exercise.muscleGroup),
              CupertinoIcons.circle_fill,
            ),
            _buildBadge(
              exercise.equipment,
              CupertinoColors.systemGrey,
              CupertinoIcons.square_stack_3d_up,
            ),
            _buildBadge(
              exercise.difficulty,
              _getDifficultyColor(exercise.difficulty),
              CupertinoIcons.chart_bar_fill,
            ),
          ],
        ),
      ],
    );
  }

  /// Badge
  Widget _buildBadge(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Card de información básica
  Widget _buildInfoCard(ExerciseTemplate exercise, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            'Grupo Muscular Principal',
            exercise.muscleGroup,
            CupertinoIcons.heart_fill,
            isDark,
          ),
          if (exercise.secondaryMuscles.isNotEmpty) ...[
            const Divider(height: 24),
            _buildInfoRow(
              'Músculos Secundarios',
              exercise.secondaryMuscles.join(', '),
              CupertinoIcons.heart,
              isDark,
            ),
          ],
          const Divider(height: 24),
          _buildInfoRow(
            'Equipamiento',
            exercise.equipment,
            CupertinoIcons.square_stack_3d_up,
            isDark,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            'Nivel',
            exercise.difficulty,
            CupertinoIcons.chart_bar,
            isDark,
          ),
        ],
      ),
    );
  }

  /// Fila de información
  Widget _buildInfoRow(String label, String value, IconData icon, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: CupertinoColors.activeBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: CupertinoColors.activeBlue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Sección de músculos trabajados
  Widget _buildMusclesSection(ExerciseTemplate exercise, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.person_fill,
                size: 20,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                'Músculos Trabajados',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Músculo principal
          _buildMuscleChip(
            exercise.muscleGroup,
            'Principal',
            _getMuscleGroupColor(exercise.muscleGroup),
          ),

          // Músculos secundarios
          if (exercise.secondaryMuscles.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: exercise.secondaryMuscles
                  .map(
                    (muscle) => _buildMuscleChip(
                      muscle,
                      'Secundario',
                      _getMuscleGroupColor(muscle),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  /// Chip de músculo
  Widget _buildMuscleChip(String muscle, String type, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            type,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            muscle,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Sección de instrucciones
  Widget _buildInstructionsSection(ExerciseTemplate exercise, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.list_bullet,
                size: 20,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                'Instrucciones',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            exercise.instructions!,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  /// Sección de errores comunes
  Widget _buildMistakesSection(ExerciseTemplate exercise, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.exclamationmark_triangle,
                size: 20,
                color: Colors.orange,
              ),
              const SizedBox(width: 8),
              const Text(
                'Errores Comunes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...exercise.commonMistakes!.map(
            (mistake) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    CupertinoIcons.xmark_circle,
                    size: 16,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      mistake,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? Colors.grey.shade300
                            : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Sección de tips profesionales
  Widget _buildProTipsSection(ExerciseTemplate exercise, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.lightbulb, size: 20, color: Colors.amber),
              const SizedBox(width: 8),
              const Text(
                'Tips Profesionales',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...exercise.proTips!.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    CupertinoIcons.checkmark_circle,
                    size: 16,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tip,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? Colors.grey.shade300
                            : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Obtener color del grupo muscular
  Color _getMuscleGroupColor(String muscleGroup) {
    switch (muscleGroup) {
      case 'Pecho':
        return Colors.blue;
      case 'Espalda':
        return Colors.green;
      case 'Hombros':
        return Colors.orange;
      case 'Bíceps':
        return Colors.purple;
      case 'Tríceps':
        return Colors.pink;
      case 'Piernas':
        return Colors.red;
      case 'Glúteos':
        return Colors.deepOrange;
      case 'Abdomen':
        return Colors.teal;
      case 'Pantorrillas':
        return Colors.brown;
      case 'Antebrazos':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  /// Obtener color de dificultad
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Principiante':
        return Colors.green;
      case 'Intermedio':
        return Colors.orange;
      case 'Avanzado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

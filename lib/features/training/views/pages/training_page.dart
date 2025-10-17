import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/app/routes/route_paths.dart';
import 'package:tribbe_app/shared/controllers/exercises_controller.dart';
import 'package:tribbe_app/shared/models/exercise_model.dart';

/// Página de Entrenamiento - Consulta de Ejercicios
class TrainingPage extends StatelessWidget {
  const TrainingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ExercisesController());
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          // AppBar
          CupertinoSliverNavigationBar(
            backgroundColor: isDark ? Colors.black : Colors.grey.shade50,
            largeTitle: const Text('Entrenar'),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Get.toNamed(RoutePaths.exercisesLibrary),
              child: const Icon(
                CupertinoIcons.search,
                color: CupertinoColors.activeBlue,
              ),
            ),
          ),

          // Búsqueda rápida
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Campo de búsqueda
                  CupertinoSearchTextField(
                    placeholder: 'Buscar ejercicios...',
                    onSubmitted: (query) {
                      controller.setSearchQuery(query);
                      Get.toNamed(RoutePaths.exercisesLibrary);
                    },
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    backgroundColor: isDark
                        ? Colors.grey.shade900
                        : Colors.white,
                  ),

                  const SizedBox(height: 24),

                  // Título de grupos musculares
                  Text(
                    'Grupos Musculares',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Grupos musculares
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final muscleGroup = MuscleGroups.all[index];
                return _buildMuscleGroupCard(muscleGroup, isDark, () {
                  controller.setMuscleGroup(muscleGroup);
                  Get.toNamed(RoutePaths.exercisesLibrary);
                });
              }, childCount: MuscleGroups.all.length),
            ),
          ),

          // Espacio al final
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  /// Card de grupo muscular
  Widget _buildMuscleGroupCard(
    String muscleGroup,
    bool isDark,
    VoidCallback onTap,
  ) {
    final color = _getMuscleGroupColor(muscleGroup);
    final icon = _getMuscleGroupIcon(muscleGroup);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(height: 12),
                Text(
                  muscleGroup,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
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

  /// Obtener icono del grupo muscular
  IconData _getMuscleGroupIcon(String muscleGroup) {
    switch (muscleGroup) {
      case 'Pecho':
        return CupertinoIcons.square_fill_line_vertical_square;
      case 'Espalda':
        return CupertinoIcons.rectangle_3_offgrid;
      case 'Hombros':
        return CupertinoIcons.triangle;
      case 'Bíceps':
      case 'Tríceps':
        return CupertinoIcons.hammer;
      case 'Piernas':
        return CupertinoIcons.square_stack;
      case 'Glúteos':
        return CupertinoIcons.circle_grid_hex;
      case 'Abdomen':
        return CupertinoIcons.square_grid_3x2;
      case 'Pantorrillas':
        return CupertinoIcons.rectangle_stack;
      case 'Antebrazos':
        return CupertinoIcons.square_list;
      default:
        return CupertinoIcons.circle;
    }
  }
}

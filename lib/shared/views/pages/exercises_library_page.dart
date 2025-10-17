import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/app/routes/route_paths.dart';
import 'package:tribbe_app/shared/controllers/exercises_controller.dart';
import 'package:tribbe_app/shared/models/exercise_model.dart';

/// Página de Biblioteca de Ejercicios - Estilo Minimalista Cupertino
class ExercisesLibraryPage extends StatelessWidget {
  const ExercisesLibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ExercisesController());
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          // AppBar con búsqueda
          _buildAppBar(controller, isDark),

          // Filtros
          SliverToBoxAdapter(child: _buildFilters(controller, isDark)),

          // Lista de ejercicios
          Obx(() {
            if (controller.isLoading.value) {
              return const SliverFillRemaining(
                child: Center(child: CupertinoActivityIndicator()),
              );
            }

            if (controller.filteredExercises.isEmpty) {
              return SliverFillRemaining(child: _buildEmptyState(isDark));
            }

            return SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final exercise = controller.filteredExercises[index];
                  return _buildExerciseCard(
                    exercise,
                    isDark,
                    () => Get.toNamed(
                      RoutePaths.exerciseDetail,
                      arguments: {'exerciseId': exercise.id},
                    ),
                  );
                }, childCount: controller.filteredExercises.length),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// AppBar con búsqueda
  Widget _buildAppBar(ExercisesController controller, bool isDark) {
    return CupertinoSliverNavigationBar(
      backgroundColor: isDark ? Colors.black : Colors.grey.shade50,
      largeTitle: const Text('Ejercicios'),
      leading: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => Get.back(),
        child: Icon(
          CupertinoIcons.back,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _showFilterSheet(controller),
        child: Obx(() {
          final hasFilters =
              controller.selectedMuscleGroup.value.isNotEmpty ||
              controller.selectedEquipment.isNotEmpty ||
              controller.selectedDifficulty.value.isNotEmpty;
          return Stack(
            children: [
              Icon(
                CupertinoIcons.slider_horizontal_3,
                color: isDark ? Colors.white : Colors.black,
              ),
              if (hasFilters)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: CupertinoColors.activeBlue,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  /// Filtros
  Widget _buildFilters(ExercisesController controller, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // Barra de búsqueda
          CupertinoSearchTextField(
            placeholder: 'Buscar ejercicios...',
            onChanged: controller.setSearchQuery,
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
            backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
          ),

          // Chips de filtros activos
          Obx(() {
            final hasFilters =
                controller.selectedMuscleGroup.value.isNotEmpty ||
                controller.selectedEquipment.isNotEmpty ||
                controller.selectedDifficulty.value.isNotEmpty;

            if (!hasFilters) return const SizedBox.shrink();

            return Container(
              margin: const EdgeInsets.only(top: 12),
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  if (controller.selectedMuscleGroup.value.isNotEmpty)
                    _buildFilterChip(
                      controller.selectedMuscleGroup.value,
                      () => controller.setMuscleGroup(null),
                      isDark,
                    ),
                  if (controller.selectedDifficulty.value.isNotEmpty)
                    _buildFilterChip(
                      controller.selectedDifficulty.value,
                      () => controller.setDifficulty(null),
                      isDark,
                    ),
                  ...controller.selectedEquipment.map(
                    (eq) => _buildFilterChip(
                      eq,
                      () => controller.toggleEquipment(eq),
                      isDark,
                    ),
                  ),
                  // Botón limpiar todo
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minSize: 0,
                    onPressed: controller.clearFilters,
                    child: const Text(
                      'Limpiar todo',
                      style: TextStyle(
                        fontSize: 13,
                        color: CupertinoColors.destructiveRed,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Chip de filtro activo
  Widget _buildFilterChip(String label, VoidCallback onRemove, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: CupertinoColors.activeBlue.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CupertinoColors.activeBlue.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: CupertinoColors.activeBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              CupertinoIcons.xmark_circle_fill,
              size: 16,
              color: CupertinoColors.activeBlue,
            ),
          ),
        ],
      ),
    );
  }

  /// Card de ejercicio
  Widget _buildExerciseCard(
    ExerciseTemplate exercise,
    bool isDark,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icono del grupo muscular
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getMuscleGroupColor(
                      exercise.muscleGroup,
                    ).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getMuscleGroupIcon(exercise.muscleGroup),
                    color: _getMuscleGroupColor(exercise.muscleGroup),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Información
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        exercise.muscleGroup,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _buildBadge(
                            exercise.equipment,
                            CupertinoIcons.square_stack_3d_up,
                            isDark,
                          ),
                          const SizedBox(width: 8),
                          _buildBadge(
                            exercise.difficulty,
                            CupertinoIcons.chart_bar,
                            isDark,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Flecha
                Icon(
                  CupertinoIcons.chevron_right,
                  size: 18,
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Badge de info
  Widget _buildBadge(String text, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey.shade800.withOpacity(0.5)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  /// Estado vacío
  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.search,
            size: 64,
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No se encontraron ejercicios',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta ajustar los filtros',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  /// Mostrar hoja de filtros
  void _showFilterSheet(ExercisesController controller) {
    Get.bottomSheet(
      _FilterSheet(controller: controller),
      isScrollControlled: true,
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

/// Hoja de filtros
class _FilterSheet extends StatelessWidget {
  final ExercisesController controller;

  const _FilterSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filtros',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Get.back(),
                  child: const Text('Listo'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Contenido
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Grupo Muscular
                _buildFilterSection(
                  'Grupo Muscular',
                  MuscleGroups.all,
                  controller.selectedMuscleGroup.value,
                  (value) => controller.setMuscleGroup(
                    value == controller.selectedMuscleGroup.value
                        ? null
                        : value,
                  ),
                  isDark,
                ),

                const SizedBox(height: 24),

                // Dificultad
                _buildFilterSection(
                  'Dificultad',
                  Difficulty.all,
                  controller.selectedDifficulty.value,
                  (value) => controller.setDifficulty(
                    value == controller.selectedDifficulty.value ? null : value,
                  ),
                  isDark,
                ),

                const SizedBox(height: 24),

                // Equipamiento
                const Text(
                  'Equipamiento',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: Equipment.all.map((eq) {
                      final isSelected = controller.selectedEquipment.contains(
                        eq,
                      );
                      return FilterChip(
                        label: Text(eq),
                        selected: isSelected,
                        onSelected: (_) => controller.toggleEquipment(eq),
                        backgroundColor: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade100,
                        selectedColor: CupertinoColors.activeBlue.withOpacity(
                          0.2,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(
    String title,
    List<String> options,
    String selectedValue,
    ValueChanged<String> onChanged,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedValue == option;
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (_) => onChanged(option),
              backgroundColor: isDark
                  ? Colors.grey.shade800
                  : Colors.grey.shade100,
              selectedColor: CupertinoColors.activeBlue.withOpacity(0.2),
            );
          }).toList(),
        ),
      ],
    );
  }
}

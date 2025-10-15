import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/features/training/controllers/training_controller.dart';
import 'package:tribbe_app/features/training/views/widgets/add_exercise_dialog.dart';

/// Página de modo entrenamiento
class TrainingModePage extends StatelessWidget {
  const TrainingModePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TrainingController());
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Iniciar entrenamiento automáticamente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!controller.isTraining.value) {
        controller.startTraining();
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Modo Entrenamiento'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          Obx(
            () => IconButton(
              icon: Icon(
                controller.isPaused.value ? Icons.play_arrow : Icons.pause,
              ),
              onPressed: controller.togglePause,
            ),
          ),
        ],
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Timer grande
                    _buildTimer(controller, isDark),

                    const SizedBox(height: 32),

                    // Selector de enfoque
                    _buildFocusSelector(controller, isDark),

                    const SizedBox(height: 32),

                    // Estadísticas rápidas
                    _buildQuickStats(controller, isDark),

                    const SizedBox(height: 32),

                    // Lista de ejercicios
                    _buildExercisesList(controller, context, isDark),

                    const SizedBox(height: 24),

                    // Botón agregar ejercicio
                    ElevatedButton.icon(
                      onPressed: () =>
                          _showAddExerciseDialog(context, controller),
                      icon: const Icon(Icons.add),
                      label: const Text('Agregar Ejercicio'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Botón finalizar
                    ElevatedButton(
                      onPressed: () => _showFinishDialog(context, controller),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Finalizar Entrenamiento',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Botón cancelar
                    TextButton(
                      onPressed: () => _showCancelDialog(context, controller),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.red[400]),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  /// Timer grande
  Widget _buildTimer(TrainingController controller, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          Text(
            'Tiempo',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Obx(
            () => Text(
              controller.formattedTime,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Obx(
            () => controller.isPaused.value
                ? const Text(
                    'PAUSADO',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// Selector de enfoque
  Widget _buildFocusSelector(TrainingController controller, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enfoque',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Obx(
          () => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.focusTypes.map((focus) {
              final isSelected = controller.focusType.value == focus;
              return GestureDetector(
                onTap: () => controller.changeFocus(focus),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.blueAccent
                        : (isDark ? Colors.grey[800] : Colors.grey[200]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    focus,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white : Colors.black),
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// Estadísticas rápidas
  Widget _buildQuickStats(TrainingController controller, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Ejercicios',
            controller.exercises.length.toString(),
            Icons.fitness_center,
            isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Obx(
            () => _buildStatCard(
              'Series',
              controller.totalSets.toString(),
              Icons.repeat,
              isDark,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Obx(
            () => _buildStatCard(
              'Volumen',
              '${controller.totalVolume.toStringAsFixed(0)} kg',
              Icons.scale,
              isDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: Colors.blueAccent),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Lista de ejercicios
  Widget _buildExercisesList(
    TrainingController controller,
    BuildContext context,
    bool isDark,
  ) {
    return Obx(() {
      if (controller.exercises.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                Icons.fitness_center,
                size: 48,
                color: isDark ? Colors.grey[700] : Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Sin ejercicios aún',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Agrega ejercicios para comenzar',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[500] : Colors.grey[500],
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ejercicios (${controller.exercises.length})',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          ...controller.exercises.asMap().entries.map((entry) {
            final index = entry.key;
            final exercise = entry.value;
            return Dismissible(
              key: Key('exercise_$index'),
              direction: DismissDirection.endToStart,
              background: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.centerRight,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) => controller.removeExercise(index),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...exercise.sets.asMap().entries.map((setEntry) {
                      final setIndex = setEntry.key;
                      final set = setEntry.value;
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Serie ${setIndex + 1}: ${set.weight} kg × ${set.reps} reps',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    Text(
                      'Volumen: ${exercise.totalVolume.toStringAsFixed(1)} kg',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      );
    });
  }

  /// Mostrar diálogo para agregar ejercicio
  void _showAddExerciseDialog(
    BuildContext context,
    TrainingController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AddExerciseDialog(controller: controller),
    );
  }

  /// Mostrar diálogo para finalizar
  void _showFinishDialog(BuildContext context, TrainingController controller) {
    final captionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalizar Entrenamiento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('¿Quieres agregar un comentario?'),
            const SizedBox(height: 16),
            TextField(
              controller: captionController,
              decoration: const InputDecoration(
                hintText: '¡Excelente sesión! 💪',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.finishTraining(caption: captionController.text);
            },
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
  }

  /// Mostrar diálogo para cancelar
  void _showCancelDialog(BuildContext context, TrainingController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Entrenamiento'),
        content: const Text(
          '¿Estás seguro? Se perderán todos los datos del entrenamiento.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.cancelTraining();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
  }
}

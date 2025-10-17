import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/features/training/controllers/training_controller.dart';
import 'package:tribbe_app/features/training/models/exercise_model.dart';
import 'package:tribbe_app/features/training/models/workout_model.dart';

/// Página de modo entrenamiento - Diseño Cupertino simplificado
class TrainingModePage extends StatefulWidget {
  const TrainingModePage({super.key});

  @override
  State<TrainingModePage> createState() => _TrainingModePageState();
}

class _TrainingModePageState extends State<TrainingModePage> {
  ExerciseTemplate? selectedExercise;
  final weightController = TextEditingController();
  final repsController = TextEditingController();
  final List<SetModel> currentSets = [];
  int? editingSetIndex;
  int? editingExerciseIndex; // Índice del ejercicio que se está editando

  @override
  void dispose() {
    weightController.dispose();
    repsController.dispose();
    super.dispose();
  }

  void _selectExercise(ExerciseTemplate exercise) {
    setState(() {
      selectedExercise = exercise;
      currentSets.clear();
      weightController.clear();
      repsController.clear();
      editingSetIndex = null;
      editingExerciseIndex = null; // Nuevo ejercicio, no editando
    });
  }

  void _addSet() {
    final weight = double.tryParse(weightController.text);
    final reps = int.tryParse(repsController.text);

    if (weight != null && weight > 0 && reps != null && reps > 0) {
      setState(() {
        if (editingSetIndex != null) {
          // Editando serie existente
          currentSets[editingSetIndex!] = SetModel(weight: weight, reps: reps);
          editingSetIndex = null;
        } else {
          // Agregando nueva serie
          currentSets.add(SetModel(weight: weight, reps: reps));
        }
        weightController.clear();
        repsController.clear();
      });
      HapticFeedback.mediumImpact();
    }
  }

  void _editSet(int index) {
    final set = currentSets[index];
    setState(() {
      editingSetIndex = index;
      weightController.text = set.weight.toString();
      repsController.text = set.reps.toString();
    });
    HapticFeedback.lightImpact();
  }

  void _cancelEdit() {
    setState(() {
      editingSetIndex = null;
      weightController.clear();
      repsController.clear();
    });
  }

  void _removeSet(int index) {
    setState(() {
      currentSets.removeAt(index);
      if (editingSetIndex == index) {
        editingSetIndex = null;
        weightController.clear();
        repsController.clear();
      } else if (editingSetIndex != null && editingSetIndex! > index) {
        editingSetIndex = editingSetIndex! - 1;
      }
    });
    HapticFeedback.mediumImpact();
  }

  void _saveExercise(TrainingController controller) {
    if (selectedExercise != null && currentSets.isNotEmpty) {
      if (editingExerciseIndex != null) {
        // EDITANDO: Reemplazar el ejercicio en su posición original
        final exercises = List<ExerciseData>.from(controller.exercises);
        exercises[editingExerciseIndex!] = ExerciseData(
          name: selectedExercise!.name,
          sets: List.from(currentSets),
        );
        // Actualizar toda la lista de una vez
        controller.exercises.value = exercises;
      } else {
        // NUEVO: Agregar al final
        controller.addExercise(
          name: selectedExercise!.name,
          sets: List.from(currentSets),
        );
      }

      setState(() {
        selectedExercise = null;
        currentSets.clear();
        weightController.clear();
        repsController.clear();
        editingSetIndex = null;
        editingExerciseIndex = null;
      });
      HapticFeedback.mediumImpact();
    }
  }

  void _cancelExercise() {
    setState(() {
      selectedExercise = null;
      currentSets.clear();
      weightController.clear();
      repsController.clear();
      editingSetIndex = null;
      editingExerciseIndex = null; // Limpiar índice de edición
    });
  }

  void _editExercise(TrainingController controller, int exerciseIndex) {
    final exercise = controller.exercises[exerciseIndex];

    // Buscar el template del ejercicio
    final template = controller.availableExercises.firstWhere(
      (e) => e.name == exercise.name,
      orElse: () => controller.availableExercises.first,
    );

    setState(() {
      selectedExercise = template;
      currentSets.clear();
      currentSets.addAll(exercise.sets); // Cargar series existentes
      editingSetIndex = null;
      editingExerciseIndex =
          exerciseIndex; // Guardar índice para eliminar después
      weightController.clear();
      repsController.clear();
    });

    HapticFeedback.mediumImpact();
  }

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
      backgroundColor: isDark ? CupertinoColors.black : CupertinoColors.white,
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CupertinoActivityIndicator())
            : CustomScrollView(
                slivers: [
                  // AppBar estilo Cupertino
                  CupertinoSliverNavigationBar(
                    backgroundColor: isDark
                        ? CupertinoColors.black
                        : CupertinoColors.white,
                    largeTitle: const Text('Entrenamiento'),
                    trailing: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: controller.togglePause,
                      child: Icon(
                        controller.isPaused.value
                            ? CupertinoIcons.play_fill
                            : CupertinoIcons.pause_fill,
                        color: CupertinoColors.activeBlue,
                      ),
                    ),
                  ),

                  // Contenido
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(height: 8),

                        // Timer compacto
                        _buildCompactTimer(controller, isDark),

                        const SizedBox(height: 16),

                        // Stats Row
                        _buildStatsRow(controller, isDark),

                        const SizedBox(height: 24),

                        // Panel de configuración de ejercicio O ejercicios sugeridos
                        if (selectedExercise != null)
                          _buildExerciseConfigPanel(controller, isDark)
                        else if (controller.exercises.isEmpty)
                          _buildSuggestedExercises(controller, context, isDark),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),

                  // Lista de ejercicios agregados
                  _buildExercisesListSliver(controller, isDark),

                  // Botones de acción
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Botón agregar (oculto si está agregando o editando serie)
                          if (selectedExercise == null)
                            CupertinoButton.filled(
                              onPressed: () =>
                                  _showExercisePicker(context, controller),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(CupertinoIcons.add_circled),
                                  SizedBox(width: 8),
                                  Text('Agregar Ejercicio'),
                                ],
                              ),
                            ),

                          const SizedBox(height: 12),

                          // Botón finalizar
                          CupertinoButton(
                            onPressed: controller.exercises.isEmpty
                                ? null
                                : () => _showFinishDialog(context, controller),
                            color: CupertinoColors.systemGreen,
                            child: const Text('Finalizar Entrenamiento'),
                          ),

                          const SizedBox(height: 8),

                          // Botón cancelar
                          CupertinoButton(
                            onPressed: () =>
                                _showCancelDialog(context, controller),
                            child: Text(
                              'Cancelar',
                              style: TextStyle(
                                color: CupertinoColors.systemRed,
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// Timer compacto estilo iOS
  Widget _buildCompactTimer(TrainingController controller, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark
            ? CupertinoColors.darkBackgroundGray
            : CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.clock,
            color: isDark
                ? CupertinoColors.systemGrey
                : CupertinoColors.systemGrey2,
            size: 20,
          ),
          const SizedBox(width: 8),
          Obx(
            () => Text(
              controller.formattedTime,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: controller.isPaused.value
                    ? CupertinoColors.systemOrange
                    : CupertinoColors.activeBlue,
                letterSpacing: 1,
              ),
            ),
          ),
          if (controller.isPaused.value) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: CupertinoColors.systemOrange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'PAUSA',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Stats Row compacto
  Widget _buildStatsRow(TrainingController controller, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              CupertinoIcons.sportscourt,
              'Ejercicios',
              controller.exercises.length.toString(),
              isDark,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: isDark
                ? CupertinoColors.systemGrey
                : CupertinoColors.systemGrey5,
          ),
          Expanded(
            child: Obx(
              () => _buildStatItem(
                CupertinoIcons.repeat,
                'Series',
                controller.totalSets.toString(),
                isDark,
              ),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: isDark
                ? CupertinoColors.systemGrey
                : CupertinoColors.systemGrey5,
          ),
          Expanded(
            child: Obx(
              () => _buildStatItem(
                CupertinoIcons.chart_bar_alt_fill,
                'Volumen',
                '${controller.totalVolume.toStringAsFixed(0)}kg',
                isDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String label,
    String value,
    bool isDark,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark
              ? CupertinoColors.systemGrey
              : CupertinoColors.systemGrey2,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? CupertinoColors.white : CupertinoColors.black,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark
                ? CupertinoColors.systemGrey
                : CupertinoColors.systemGrey2,
          ),
        ),
      ],
    );
  }

  /// Ejercicios sugeridos para comenzar
  Widget _buildSuggestedExercises(
    TrainingController controller,
    BuildContext context,
    bool isDark,
  ) {
    // Obtener ejercicios más comunes según el filtro
    final suggested = controller.availableExercises.take(6).toList();

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
              return GestureDetector(
                onTap: () => _selectExercise(exercise),
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
                      Icon(
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
            },
          ),
        ),
      ],
    );
  }

  /// Lista de ejercicios agregados (Sliver)
  Widget _buildExercisesListSliver(TrainingController controller, bool isDark) {
    return Obx(() {
      if (controller.exercises.isEmpty) {
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      }

      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final exercise = controller.exercises[index];
            final isBeingEdited = editingExerciseIndex == index;

            return Dismissible(
              key: Key('exercise_$index'),
              direction: isBeingEdited
                  ? DismissDirection
                        .none // No permitir swipe si está editando
                  : DismissDirection.horizontal,
              // Background IZQUIERDO (aparece al deslizar DERECHA) = EDITAR
              background: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      CupertinoColors.systemOrange,
                      CupertinoColors.systemOrange.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.centerLeft,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.pencil_circle_fill,
                      color: CupertinoColors.white,
                      size: 28,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Editar',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Background DERECHO (aparece al deslizar IZQUIERDA) = ELIMINAR
              secondaryBackground: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      CupertinoColors.systemRed,
                      CupertinoColors.systemRed.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.centerRight,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.delete_solid,
                      color: CupertinoColors.white,
                      size: 28,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Eliminar',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  // Deslizar de IZQUIERDA a DERECHA = EDITAR
                  _editExercise(controller, index);
                  return false;
                } else {
                  // Deslizar de DERECHA a IZQUIERDA = ELIMINAR
                  return true;
                }
              },
              onDismissed: (_) => controller.removeExercise(index),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: isBeingEdited
                      ? LinearGradient(
                          colors: [
                            CupertinoColors.systemOrange.withOpacity(0.15),
                            CupertinoColors.systemOrange.withOpacity(0.05),
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
                      ? Border.all(
                          color: CupertinoColors.systemOrange,
                          width: 2,
                        )
                      : null,
                  boxShadow: isBeingEdited
                      ? [
                          BoxShadow(
                            color: CupertinoColors.systemOrange.withOpacity(
                              0.3,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (isBeingEdited)
                                    Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.systemOrange,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(
                                            CupertinoIcons.pencil,
                                            color: CupertinoColors.white,
                                            size: 10,
                                          ),
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
                                    ),
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
                              if (!isBeingEdited) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.arrow_right,
                                      size: 12,
                                      color: CupertinoColors.systemOrange
                                          .withOpacity(0.5),
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
                                      color: CupertinoColors.systemRed
                                          .withOpacity(0.5),
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
                              ],
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
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
                    ),
                    const SizedBox(height: 12),
                    ...exercise.sets.asMap().entries.map((setEntry) {
                      final setIndex = setEntry.key;
                      final set = setEntry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: CupertinoColors.activeBlue.withOpacity(
                                  0.1,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${setIndex + 1}',
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
                    }),
                    const SizedBox(height: 8),
                    Divider(
                      color: isDark
                          ? CupertinoColors.systemGrey
                          : CupertinoColors.systemGrey5,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
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
                    ),
                  ],
                ),
              ),
            );
          }, childCount: controller.exercises.length),
        ),
      );
    });
  }

  /// Mostrar picker de ejercicios estilo Cupertino
  void _showExercisePicker(
    BuildContext context,
    TrainingController controller,
  ) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? CupertinoColors.darkBackgroundGray
              : CupertinoColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
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
            ),
            // Lista de ejercicios
            Expanded(
              child: ListView.builder(
                itemCount: controller.availableExercises.length,
                itemBuilder: (context, index) {
                  final exercise = controller.availableExercises[index];
                  return CupertinoListTile(
                    title: Text(exercise.name),
                    subtitle: Text(
                      '${exercise.muscleGroup} • ${exercise.equipment}',
                    ),
                    trailing: const Icon(CupertinoIcons.add_circled),
                    onTap: () {
                      Navigator.pop(context);
                      _selectExercise(exercise);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Panel de configuración de ejercicio inline
  Widget _buildExerciseConfigPanel(TrainingController controller, bool isDark) {
    final totalVolume = currentSets.fold<double>(
      0.0,
      (sum, set) => sum + (set.weight * set.reps),
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1C1C1E), const Color(0xFF2C2C2E)]
              : [Colors.white, const Color(0xFFF5F5F7)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CupertinoColors.activeBlue, width: 2),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.activeBlue.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: editingExerciseIndex != null
                    ? (isDark
                          ? [
                              CupertinoColors.systemOrange.withOpacity(0.3),
                              CupertinoColors.systemOrange.withOpacity(0.15),
                            ]
                          : [
                              CupertinoColors.systemOrange.withOpacity(0.15),
                              CupertinoColors.systemOrange.withOpacity(0.05),
                            ])
                    : (isDark
                          ? [
                              CupertinoColors.activeBlue.withOpacity(0.3),
                              CupertinoColors.activeBlue.withOpacity(0.15),
                            ]
                          : [
                              CupertinoColors.activeBlue.withOpacity(0.15),
                              CupertinoColors.activeBlue.withOpacity(0.05),
                            ]),
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: editingExerciseIndex != null
                            ? CupertinoColors.systemOrange
                            : CupertinoColors.activeBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        editingExerciseIndex != null
                            ? CupertinoIcons.pencil_circle_fill
                            : CupertinoIcons.sportscourt_fill,
                        color: CupertinoColors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (editingExerciseIndex != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.systemOrange,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'EDITANDO',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: CupertinoColors.white,
                                    ),
                                  ),
                                ),
                              if (editingExerciseIndex != null)
                                const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  selectedExercise!.name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? CupertinoColors.white
                                        : CupertinoColors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${selectedExercise!.muscleGroup} • ${selectedExercise!.equipment}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? CupertinoColors.systemGrey
                                  : CupertinoColors.systemGrey2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: _cancelExercise,
                      child: Icon(
                        CupertinoIcons.xmark_circle_fill,
                        color: isDark
                            ? CupertinoColors.systemGrey
                            : CupertinoColors.systemGrey2,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Formulario
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Campos de entrada
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Peso (kg)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? CupertinoColors.systemGrey
                                  : CupertinoColors.systemGrey2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          CupertinoTextField(
                            controller: weightController,
                            placeholder: '0',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}'),
                              ),
                            ],
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? CupertinoColors.black
                                  : CupertinoColors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            style: const TextStyle(fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reps',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? CupertinoColors.systemGrey
                                  : CupertinoColors.systemGrey2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          CupertinoTextField(
                            controller: repsController,
                            placeholder: '0',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? CupertinoColors.black
                                  : CupertinoColors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            style: const TextStyle(fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Indicador de modo edición
                if (editingSetIndex != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: CupertinoColors.systemOrange,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          CupertinoIcons.pencil_circle_fill,
                          color: CupertinoColors.systemOrange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Editando serie ${editingSetIndex! + 1}',
                            style: const TextStyle(
                              color: CupertinoColors.systemOrange,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: _cancelEdit,
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(
                              fontSize: 13,
                              color: CupertinoColors.systemOrange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Botón agregar/actualizar serie
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    color: editingSetIndex != null
                        ? CupertinoColors.systemOrange
                        : CupertinoColors.activeBlue,
                    borderRadius: BorderRadius.circular(10),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    onPressed: _addSet,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          editingSetIndex != null
                              ? 'Actualizar Serie'
                              : 'Agregar Serie',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Get.isDarkMode
                                ? CupertinoColors.black
                                : CupertinoColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Lista de series
                if (currentSets.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: currentSets.length,
                      itemBuilder: (context, index) {
                        final set = currentSets[index];
                        final isEditing = editingSetIndex == index;
                        return Dismissible(
                          key: Key('temp_set_$index'),
                          direction: DismissDirection.horizontal,
                          // Background IZQUIERDO (aparece al deslizar DERECHA) = EDITAR
                          background: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  CupertinoColors.systemOrange,
                                  CupertinoColors.systemOrange.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.pencil_circle_fill,
                                  color: CupertinoColors.white,
                                  size: 24,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Editar',
                                  style: TextStyle(
                                    color: CupertinoColors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Background DERECHO (aparece al deslizar IZQUIERDA) = ELIMINAR
                          secondaryBackground: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  CupertinoColors.systemRed,
                                  CupertinoColors.systemRed.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.delete_solid,
                                  color: CupertinoColors.white,
                                  size: 24,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Eliminar',
                                  style: TextStyle(
                                    color: CupertinoColors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.startToEnd) {
                              // Deslizar de IZQUIERDA a DERECHA = EDITAR
                              _editSet(index);
                              return false;
                            } else {
                              // Deslizar de DERECHA a IZQUIERDA = ELIMINAR
                              return true;
                            }
                          },
                          onDismissed: (_) => _removeSet(index),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: isEditing
                                  ? LinearGradient(
                                      colors: [
                                        CupertinoColors.systemOrange
                                            .withOpacity(0.2),
                                        CupertinoColors.systemOrange
                                            .withOpacity(0.1),
                                      ],
                                    )
                                  : null,
                              color: isEditing
                                  ? null
                                  : (isDark
                                        ? const Color(0xFF1C1C1E)
                                        : Colors.white),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isEditing
                                    ? CupertinoColors.systemOrange
                                    : (isDark
                                          ? CupertinoColors.systemGrey
                                          : CupertinoColors.systemGrey4),
                                width: isEditing ? 2 : 1,
                              ),
                              boxShadow: isEditing
                                  ? [
                                      BoxShadow(
                                        color: CupertinoColors.systemOrange
                                            .withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isEditing
                                          ? [
                                              CupertinoColors.systemOrange,
                                              CupertinoColors.systemOrange
                                                  .withOpacity(0.8),
                                            ]
                                          : [
                                              CupertinoColors.activeBlue,
                                              CupertinoColors.activeBlue
                                                  .withOpacity(0.8),
                                            ],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            (isEditing
                                                    ? CupertinoColors
                                                          .systemOrange
                                                    : CupertinoColors
                                                          .activeBlue)
                                                .withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: CupertinoColors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${set.weight} kg × ${set.reps} reps',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? CupertinoColors.white
                                              : CupertinoColors.black,
                                        ),
                                      ),
                                      Text(
                                        'Vol: ${(set.weight * set.reps).toStringAsFixed(0)} kg',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark
                                              ? CupertinoColors.systemGrey
                                              : CupertinoColors.systemGrey2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.arrow_right,
                                      size: 14,
                                      color: CupertinoColors.systemOrange
                                          .withOpacity(0.6),
                                    ),
                                    const SizedBox(width: 2),
                                    Icon(
                                      CupertinoIcons.arrow_left,
                                      size: 14,
                                      color: CupertinoColors.systemRed
                                          .withOpacity(0.6),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.chart_bar_circle_fill,
                        size: 16,
                        color: CupertinoColors.activeGreen,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Volumen: ${totalVolume.toStringAsFixed(0)} kg',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.activeGreen,
                        ),
                      ),
                    ],
                  ),
                ],

                if (currentSets.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      color: CupertinoColors.activeGreen,
                      borderRadius: BorderRadius.circular(10),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      onPressed: () => _saveExercise(controller),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.checkmark_circle, size: 20),
                          SizedBox(width: 6),
                          Text(
                            'Guardar Ejercicio',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Mostrar modal para finalizar - estilo minimalista
  void _showFinishDialog(BuildContext context, TrainingController controller) {
    final captionController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: isDark
              ? CupertinoColors.darkBackgroundGray
              : CupertinoColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header fijo con título
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? CupertinoColors.systemGrey
                        : CupertinoColors.systemGrey5,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        color: isDark
                            ? CupertinoColors.systemGrey
                            : CupertinoColors.systemGrey2,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),

                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.pop(context);
                      controller.finishTraining(
                        caption: captionController.text,
                      );
                    },
                    child: const Text(
                      'Finalizar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Contenido scrolleable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Icono simple
                    Icon(
                      CupertinoIcons.checkmark_circle,
                      size: 60,
                      color: isDark
                          ? CupertinoColors.systemGreen
                          : CupertinoColors.systemGreen,
                    ),

                    const SizedBox(height: 24),

                    // Título simple
                    Text(
                      'Entrenamiento Completado',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        color: isDark
                            ? CupertinoColors.white
                            : CupertinoColors.black,
                        decoration: TextDecoration.none,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    // Stats simples
                    Obx(
                      () => Text(
                        '${controller.exercises.length} ejercicios • ${controller.totalSets} series • ${controller.formattedTime}',
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark
                              ? CupertinoColors.systemGrey
                              : CupertinoColors.systemGrey2,
                          decoration: TextDecoration.none,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Campo de texto simple
                    CupertinoTextField(
                      controller: captionController,
                      placeholder: 'Agregar comentario...',
                      maxLines: 4,
                      minLines: 4,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark
                            ? CupertinoColors.systemGrey6
                            : CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? CupertinoColors.systemGrey5
                              : CupertinoColors.systemGrey4,
                          width: 1,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark
                            ? CupertinoColors.white
                            : CupertinoColors.black,
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mostrar diálogo para cancelar - estilo Cupertino
  void _showCancelDialog(BuildContext context, TrainingController controller) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Cancelar Entrenamiento'),
        content: const Text(
          '¿Estás seguro? Se perderán todos los datos del entrenamiento.',
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              controller.cancelTraining();
            },
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
  }
}

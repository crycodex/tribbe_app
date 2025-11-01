import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/features/training/controllers/training_controller.dart';
import 'package:tribbe_app/features/training/controllers/training_exercise_editor_controller.dart';
import 'package:tribbe_app/features/training/views/widgets/cancel_training_dialog.dart';
import 'package:tribbe_app/features/training/views/widgets/exercise_config_panel_widget.dart';
import 'package:tribbe_app/features/training/views/widgets/exercise_list_item_widget.dart';
import 'package:tribbe_app/features/training/views/widgets/exercise_picker_modal.dart';
import 'package:tribbe_app/features/training/views/widgets/finish_training_modal.dart';
import 'package:tribbe_app/features/training/views/widgets/suggested_exercises_widget.dart';
import 'package:tribbe_app/features/training/views/widgets/training_stats_row_widget.dart';
import 'package:tribbe_app/features/training/views/widgets/training_timer_widget.dart';
import 'package:tribbe_app/features/training/views/widgets/training_focus_selector_widget.dart';

/// Página de modo entrenamiento - Diseño Cupertino simplificado
/// Actúa como orquestador de widgets especializados
class TrainingModePage extends StatefulWidget {
  const TrainingModePage({super.key});

  @override
  State<TrainingModePage> createState() => _TrainingModePageState();
}

class _TrainingModePageState extends State<TrainingModePage> {
  late final TrainingController trainingController;
  late final TrainingExerciseEditorController editorController;

  @override
  void initState() {
    super.initState();
    // Si ya existe el controller, usarlo; si no, crear uno nuevo
    trainingController = Get.isRegistered<TrainingController>()
        ? Get.find<TrainingController>()
        : Get.put(TrainingController(), permanent: true);
    editorController = Get.put(TrainingExerciseEditorController());

    // Obtener enfoque seleccionado de los argumentos
    final args = Get.arguments as Map<String, dynamic>?;
    final selectedFocus = args?['selectedFocus'] as String?;

    // Iniciar entrenamiento automáticamente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!trainingController.isTraining.value) {
        trainingController.startTraining(focus: selectedFocus);
      }
    });
  }

  @override
  void dispose() {
    // Eliminar solo el TrainingExerciseEditorController
    // NO eliminar TrainingController para mantener el estado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<TrainingExerciseEditorController>()) {
        Get.delete<TrainingExerciseEditorController>();
      }
      // El TrainingController se mantiene vivo para conservar el estado
      // Solo se eliminará cuando se finalice o cancele el entrenamiento
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? CupertinoColors.black : CupertinoColors.white,
      body: Obx(
        () => trainingController.isLoading.value
            ? const Center(child: CupertinoActivityIndicator())
            : CustomScrollView(
                slivers: [
                  _buildAppBar(isDark),
                  _buildContent(isDark),
                  _buildExercisesList(isDark),
                  _buildActionButtons(context, isDark),
                ],
              ),
      ),
    );
  }

  /// AppBar estilo Cupertino
  Widget _buildAppBar(bool isDark) {
    return CupertinoSliverNavigationBar(
      backgroundColor: isDark ? CupertinoColors.black : CupertinoColors.white,
      largeTitle: const Text('Entrenamiento'),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: trainingController.togglePause,
        child: Obx(
          () => Icon(
            trainingController.isPaused.value
                ? CupertinoIcons.play_fill
                : CupertinoIcons.pause_fill,
            color: CupertinoColors.activeBlue,
          ),
        ),
      ),
    );
  }

  /// Contenido principal
  Widget _buildContent(bool isDark) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          const SizedBox(height: 8),
          const TrainingFocusSelectorWidget(),
          const SizedBox(height: 12),
          const TrainingTimerWidget(),
          const SizedBox(height: 16),
          const TrainingStatsRowWidget(),
          const SizedBox(height: 24),
          Obx(() {
            if (editorController.hasExerciseSelected) {
              return ExerciseConfigPanelWidget(
                onSave: _handleSaveExercise,
                onCancel: editorController.cancelExercise,
              );
            } else if (trainingController.exercises.isEmpty) {
              return SuggestedExercisesWidget(
                exercises: trainingController.availableExercises,
                onExerciseSelected: editorController.selectExercise,
              );
            }
            return const SizedBox.shrink();
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Lista de ejercicios agregados
  Widget _buildExercisesList(bool isDark) {
    return Obx(() {
      if (trainingController.exercises.isEmpty) {
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      }

      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final exercise = trainingController.exercises[index];
            return Obx(
              () => ExerciseListItemWidget(
                exercise: exercise,
                isBeingEdited:
                    editorController.editingExerciseIndex.value == index,
                onEdit: () => _handleEditExercise(index),
                onDelete: () => trainingController.removeExercise(index),
              ),
            );
          }, childCount: trainingController.exercises.length),
        ),
      );
    });
  }

  /// Botones de acción
  Widget _buildActionButtons(BuildContext context, bool isDark) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Obx(
              () => editorController.hasExerciseSelected
                  ? const SizedBox.shrink()
                  : CupertinoButton.filled(
                      onPressed: () => _showExercisePicker(context),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.add_circled),
                          SizedBox(width: 8),
                          Text('Agregar Ejercicio'),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => CupertinoButton(
                onPressed: trainingController.exercises.isEmpty
                    ? null
                    : () => FinishTrainingModal.show(context),
                color: CupertinoColors.systemGreen,
                child: const Text('Finalizar Entrenamiento'),
              ),
            ),
            const SizedBox(height: 8),
            CupertinoButton(
              onPressed: () => CancelTrainingDialog.show(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: CupertinoColors.systemRed),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Handlers
  void _showExercisePicker(BuildContext context) {
    ExercisePickerModal.show(
      context: context,
      exercises: trainingController.availableExercises,
      onExerciseSelected: editorController.selectExercise,
    );
  }

  void _handleEditExercise(int index) {
    final exercise = trainingController.exercises[index];
    editorController.editExercise(
      exercise,
      index,
      trainingController.availableExercises,
    );
  }

  void _handleSaveExercise() {
    final configuredExercise = editorController.getConfiguredExercise();
    if (configuredExercise == null) return;

    if (editorController.isEditingExercise) {
      // Editando: reemplazar ejercicio existente
      final exercises = List<ExerciseData>.from(trainingController.exercises);
      exercises[editorController.editingExerciseIndex.value!] =
          configuredExercise;
      trainingController.exercises.value = exercises;
    } else {
      // Nuevo: agregar al final
      trainingController.addExercise(
        name: configuredExercise.name,
        sets: configuredExercise.sets,
      );
    }

    editorController.reset();
  }
}

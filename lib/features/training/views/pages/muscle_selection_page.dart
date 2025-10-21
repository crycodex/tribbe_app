import 'package:body_part_selector/body_part_selector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/app/routes/route_paths.dart';
import 'package:tribbe_app/shared/models/exercise_model.dart';

/// Página de selección de músculo y equipamiento (estilo Muscle Wiki)
class MuscleSelectionPage extends StatefulWidget {
  const MuscleSelectionPage({super.key});

  @override
  State<MuscleSelectionPage> createState() => _MuscleSelectionPageState();
}

class _MuscleSelectionPageState extends State<MuscleSelectionPage> {
  BodyParts _bodyParts = const BodyParts();
  final Set<String> selectedEquipment = {};
  String selectedFocus = 'Fuerza'; // Enfoque por defecto

  @override
  void initState() {
    super.initState();
    // Obtener el enfoque seleccionado de los argumentos si existe
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['selectedFocus'] != null) {
      selectedFocus = args['selectedFocus'] as String;
    }
  }

  /// Aplica selección espejo: si seleccionas un lado, se selecciona el otro,
  /// y si deseleccionas uno, ambos se deseleccionan.
  BodyParts _applyMirrorSelection(
    BodyParts updatedParts,
    BodyParts currentBodyParts,
  ) {
    // Helper para determinar el estado espejado de un par de partes izquierda/derecha
    bool getMirroredState({
      required bool newLeft,
      required bool newRight,
      required bool oldLeft,
      required bool oldRight,
    }) {
      // Si el lado izquierdo fue explícitamente toggled
      if (newLeft != oldLeft) {
        return newLeft;
      }
      // Si el lado derecho fue explícitamente toggled
      if (newRight != oldRight) {
        return newRight;
      }
      // Si ninguna de las partes fue toggled (esto no debería pasar con un solo tap),
      // o si ambas ya estaban en un estado consistente, mantenemos el estado actual.
      return newLeft || newRight;
    }

    return updatedParts.copyWith(
      // Hombros
      leftShoulder: getMirroredState(
        newLeft: updatedParts.leftShoulder,
        newRight: updatedParts.rightShoulder,
        oldLeft: currentBodyParts.leftShoulder,
        oldRight: currentBodyParts.rightShoulder,
      ),
      rightShoulder: getMirroredState(
        newLeft: updatedParts.leftShoulder,
        newRight: updatedParts.rightShoulder,
        oldLeft: currentBodyParts.leftShoulder,
        oldRight: currentBodyParts.rightShoulder,
      ),

      // Brazos superiores
      leftUpperArm: getMirroredState(
        newLeft: updatedParts.leftUpperArm,
        newRight: updatedParts.rightUpperArm,
        oldLeft: currentBodyParts.leftUpperArm,
        oldRight: currentBodyParts.rightUpperArm,
      ),
      rightUpperArm: getMirroredState(
        newLeft: updatedParts.leftUpperArm,
        newRight: updatedParts.rightUpperArm,
        oldLeft: currentBodyParts.leftUpperArm,
        oldRight: currentBodyParts.rightUpperArm,
      ),

      // Codos
      leftElbow: getMirroredState(
        newLeft: updatedParts.leftElbow,
        newRight: updatedParts.rightElbow,
        oldLeft: currentBodyParts.leftElbow,
        oldRight: currentBodyParts.rightElbow,
      ),
      rightElbow: getMirroredState(
        newLeft: updatedParts.leftElbow,
        newRight: updatedParts.rightElbow,
        oldLeft: currentBodyParts.leftElbow,
        oldRight: currentBodyParts.rightElbow,
      ),

      // Antebrazos
      leftLowerArm: getMirroredState(
        newLeft: updatedParts.leftLowerArm,
        newRight: updatedParts.rightLowerArm,
        oldLeft: currentBodyParts.leftLowerArm,
        oldRight: currentBodyParts.rightLowerArm,
      ),
      rightLowerArm: getMirroredState(
        newLeft: updatedParts.leftLowerArm,
        newRight: updatedParts.rightLowerArm,
        oldLeft: currentBodyParts.leftLowerArm,
        oldRight: currentBodyParts.rightLowerArm,
      ),

      // Manos
      leftHand: getMirroredState(
        newLeft: updatedParts.leftHand,
        newRight: updatedParts.rightHand,
        oldLeft: currentBodyParts.leftHand,
        oldRight: currentBodyParts.rightHand,
      ),
      rightHand: getMirroredState(
        newLeft: updatedParts.leftHand,
        newRight: updatedParts.rightHand,
        oldLeft: currentBodyParts.leftHand,
        oldRight: currentBodyParts.rightHand,
      ),

      // Piernas superiores
      leftUpperLeg: getMirroredState(
        newLeft: updatedParts.leftUpperLeg,
        newRight: updatedParts.rightUpperLeg,
        oldLeft: currentBodyParts.leftUpperLeg,
        oldRight: currentBodyParts.rightUpperLeg,
      ),
      rightUpperLeg: getMirroredState(
        newLeft: updatedParts.leftUpperLeg,
        newRight: updatedParts.rightUpperLeg,
        oldLeft: currentBodyParts.leftUpperLeg,
        oldRight: currentBodyParts.rightUpperLeg,
      ),

      // Rodillas
      leftKnee: getMirroredState(
        newLeft: updatedParts.leftKnee,
        newRight: updatedParts.rightKnee,
        oldLeft: currentBodyParts.leftKnee,
        oldRight: currentBodyParts.rightKnee,
      ),
      rightKnee: getMirroredState(
        newLeft: updatedParts.leftKnee,
        newRight: updatedParts.rightKnee,
        oldLeft: currentBodyParts.leftKnee,
        oldRight: currentBodyParts.rightKnee,
      ),

      // Pantorrillas
      leftLowerLeg: getMirroredState(
        newLeft: updatedParts.leftLowerLeg,
        newRight: updatedParts.rightLowerLeg,
        oldLeft: currentBodyParts.leftLowerLeg,
        oldRight: currentBodyParts.rightLowerLeg,
      ),
      rightLowerLeg: getMirroredState(
        newLeft: updatedParts.leftLowerLeg,
        newRight: updatedParts.rightLowerLeg,
        oldLeft: currentBodyParts.leftLowerLeg,
        oldRight: currentBodyParts.rightLowerLeg,
      ),

      // Pies
      leftFoot: getMirroredState(
        newLeft: updatedParts.leftFoot,
        newRight: updatedParts.rightFoot,
        oldLeft: currentBodyParts.leftFoot,
        oldRight: currentBodyParts.rightFoot,
      ),
      rightFoot: getMirroredState(
        newLeft: updatedParts.leftFoot,
        newRight: updatedParts.rightFoot,
        oldLeft: currentBodyParts.leftFoot,
        oldRight: currentBodyParts.rightFoot,
      ),
    );
  }

  /// Mapea las partes del cuerpo seleccionadas a grupos musculares
  List<String> _getSelectedMuscleGroups() {
    final List<String> selected = [];

    // Hombros
    if (_bodyParts.leftShoulder || _bodyParts.rightShoulder) {
      selected.add(MuscleGroups.hombros);
    }

    // Brazos superiores (bíceps/tríceps) - lo tratamos como bíceps por defecto
    if (_bodyParts.leftUpperArm || _bodyParts.rightUpperArm) {
      selected.add(MuscleGroups.biceps);
    }

    // Torso superior (pecho/espalda) - lo tratamos como pecho por defecto
    if (_bodyParts.upperBody) {
      selected.add(MuscleGroups.pecho);
    }

    // Abdomen (está en lowerBody del selector)
    if (_bodyParts.lowerBody) {
      selected.add(MuscleGroups.abdomen);
    }

    // Piernas superiores
    if (_bodyParts.leftUpperLeg || _bodyParts.rightUpperLeg) {
      selected.add(MuscleGroups.piernas);
    }

    // Piernas inferiores (pantorrillas)
    if (_bodyParts.leftLowerLeg || _bodyParts.rightLowerLeg) {
      selected.add(MuscleGroups.pantorrillas);
    }

    // Glúteos (está en abdomen del selector)
    if (_bodyParts.abdomen) {
      selected.add(MuscleGroups.gluteos);
    }

    return selected.toSet().toList(); // Asegura valores únicos
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedMuscle = _getSelectedMuscleGroups();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Seleccionar Entrenamiento'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  const Text(
                    'Selecciona el músculo',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Toca sobre el músculo que quieres entrenar',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Cuerpo interactivo con BodyPartSelector
                  Center(
                    child: SizedBox(
                      height: 500,
                      child: BodyPartSelectorTurnable(
                        bodyParts: _bodyParts,
                        onSelectionUpdated: (parts) {
                          setState(() {
                            // Aplicar selección espejo
                            _bodyParts = _applyMirrorSelection(
                              parts,
                              _bodyParts,
                            );
                          });
                        },
                        labelData: const RotationStageLabelData(
                          front: 'Frente',
                          left: 'Izquierda',
                          right: 'Derecha',
                          back: 'Espalda',
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Músculo seleccionado
                  if (selectedMuscle.isNotEmpty)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blueAccent,
                            width: 2,
                          ),
                        ),
                        child: Wrap(
                          spacing: 8.0, // Espacio horizontal entre chips
                          runSpacing:
                              8.0, // Espacio vertical entre líneas de chips
                          alignment: WrapAlignment.center,
                          children: selectedMuscle
                              .map(
                                (muscle) => Chip(
                                  label: Text(muscle),
                                  backgroundColor: Colors.blueAccent
                                      .withValues(alpha: 0.2),
                                  labelStyle: const TextStyle(
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  side: const BorderSide(
                                    color: Colors.blueAccent,
                                    width: 1,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),

                  const SizedBox(height: 32),

                  // Equipamiento
                  const Text(
                    'Equipamiento disponible',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Selecciona el equipamiento que tienes disponible',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),

                  const SizedBox(height: 24),

                  _buildEquipmentSelection(isDark),

                  const SizedBox(height: 80), // Espacio para el botón
                ],
              ),
            ),
          ),

          // Botón de inicio
          _buildStartButton(isDark, selectedMuscle),
        ],
      ),
    );
  }

  /// Construir selección de equipamiento
  Widget _buildEquipmentSelection(bool isDark) {
    return Column(
      children: Equipment.all.map((equipment) {
        final isSelected = selectedEquipment.contains(equipment);
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Colors.blueAccent
                  : (isDark ? Colors.grey[800]! : Colors.grey[200]!),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: CheckboxListTile(
            value: isSelected,
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  selectedEquipment.add(equipment);
                } else {
                  selectedEquipment.remove(equipment);
                }
              });
            },
            title: Row(
              children: [
                Icon(
                  _getEquipmentIcon(equipment),
                  size: 20,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                const SizedBox(width: 12),
                Text(equipment, style: const TextStyle(fontSize: 15)),
              ],
            ),
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: Colors.blueAccent,
          ),
        );
      }).toList(),
    );
  }

  /// Botón de inicio
  Widget _buildStartButton(bool isDark, List<String> selectedMuscle) {
    final canStart = selectedMuscle.isNotEmpty || selectedEquipment.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selectedMuscle.isNotEmpty || selectedEquipment.isNotEmpty) ...[
            Text(
              selectedMuscle.isNotEmpty
                  ? 'Entrenarás: ${selectedMuscle.join(", ")}'
                  : 'Todos los músculos',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            if (selectedEquipment.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Con: ${selectedEquipment.join(", ")}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[500] : Colors.grey[500],
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: canStart
                  ? () {
                      // Navegar al modo entrenamiento con filtros
                      Get.toNamed(
                        RoutePaths.trainingMode,
                        arguments: {
                          'muscleGroup': selectedMuscle.join(", "),
                          'equipment': selectedEquipment.toList(),
                          'selectedFocus': selectedFocus,
                        },
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                disabledBackgroundColor: isDark
                    ? Colors.grey[800]
                    : Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Comenzar Entrenamiento',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getEquipmentIcon(String equipment) {
    switch (equipment) {
      case Equipment.barraOlimpica:
        return Icons.horizontal_rule;
      case Equipment.mancuernas:
        return Icons.fitness_center;
      case Equipment.maquina:
        return Icons.settings;
      case Equipment.pesoCorporal:
        return Icons.accessibility;
      case Equipment.polea:
        return Icons.linear_scale;
      case Equipment.bandasElasticas:
        return Icons.all_out;
      case Equipment.barraZ:
        return Icons.show_chart;
      case Equipment.discos:
        return Icons.album;
      case Equipment.banca:
        return Icons.weekend;
      case Equipment.balon:
        return Icons.sports_baseball;
      default:
        return Icons.fitness_center;
    }
  }
}

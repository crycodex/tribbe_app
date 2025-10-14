import 'package:tribbe_app/features/training/models/exercise_model.dart';

/// Base de datos local de ejercicios
class ExercisesData {
  static final List<ExerciseTemplate> exercises = [
    // ========== PECHO ==========
    ExerciseTemplate(
      id: 'pecho_1',
      name: 'Press Banca',
      muscleGroup: MuscleGroups.pecho,
      secondaryMuscles: [MuscleGroups.triceps, MuscleGroups.hombros],
      equipment: Equipment.barraOlimpica,
      difficulty: Difficulty.intermedio,
    ),
    ExerciseTemplate(
      id: 'pecho_2',
      name: 'Press Banca Inclinado',
      muscleGroup: MuscleGroups.pecho,
      secondaryMuscles: [MuscleGroups.triceps, MuscleGroups.hombros],
      equipment: Equipment.barraOlimpica,
      difficulty: Difficulty.intermedio,
    ),
    ExerciseTemplate(
      id: 'pecho_3',
      name: 'Press con Mancuernas',
      muscleGroup: MuscleGroups.pecho,
      secondaryMuscles: [MuscleGroups.triceps, MuscleGroups.hombros],
      equipment: Equipment.mancuernas,
      difficulty: Difficulty.principiante,
    ),
    ExerciseTemplate(
      id: 'pecho_4',
      name: 'Aperturas con Mancuernas',
      muscleGroup: MuscleGroups.pecho,
      equipment: Equipment.mancuernas,
      difficulty: Difficulty.principiante,
    ),
    ExerciseTemplate(
      id: 'pecho_5',
      name: 'Fondos en Paralelas',
      muscleGroup: MuscleGroups.pecho,
      secondaryMuscles: [MuscleGroups.triceps],
      equipment: Equipment.pesoCorporal,
      difficulty: Difficulty.intermedio,
    ),
    ExerciseTemplate(
      id: 'pecho_6',
      name: 'Cruces en Cables',
      muscleGroup: MuscleGroups.pecho,
      equipment: Equipment.maquina,
      difficulty: Difficulty.intermedio,
    ),
    ExerciseTemplate(
      id: 'pecho_7',
      name: 'Flexiones',
      muscleGroup: MuscleGroups.pecho,
      secondaryMuscles: [MuscleGroups.triceps, MuscleGroups.abdomen],
      equipment: Equipment.pesoCorporal,
      difficulty: Difficulty.principiante,
    ),

    // ========== ESPALDA ==========
    ExerciseTemplate(
      id: 'espalda_1',
      name: 'Dominadas',
      muscleGroup: MuscleGroups.espalda,
      secondaryMuscles: [MuscleGroups.biceps],
      equipment: Equipment.pesoCorporal,
      difficulty: Difficulty.intermedio,
    ),
    ExerciseTemplate(
      id: 'espalda_2',
      name: 'Remo con Barra',
      muscleGroup: MuscleGroups.espalda,
      secondaryMuscles: [MuscleGroups.biceps],
      equipment: Equipment.barraOlimpica,
      difficulty: Difficulty.intermedio,
    ),
    ExerciseTemplate(
      id: 'espalda_3',
      name: 'Remo con Mancuerna',
      muscleGroup: MuscleGroups.espalda,
      secondaryMuscles: [MuscleGroups.biceps],
      equipment: Equipment.mancuernas,
      difficulty: Difficulty.principiante,
    ),
    ExerciseTemplate(
      id: 'espalda_4',
      name: 'Peso Muerto',
      muscleGroup: MuscleGroups.espalda,
      secondaryMuscles: [MuscleGroups.piernas, MuscleGroups.gluteos],
      equipment: Equipment.barraOlimpica,
      difficulty: Difficulty.avanzado,
    ),
    ExerciseTemplate(
      id: 'espalda_5',
      name: 'Jalón al Pecho',
      muscleGroup: MuscleGroups.espalda,
      secondaryMuscles: [MuscleGroups.biceps],
      equipment: Equipment.maquina,
      difficulty: Difficulty.principiante,
    ),

    // ========== PIERNAS ==========
    ExerciseTemplate(
      id: 'piernas_1',
      name: 'Sentadilla',
      muscleGroup: MuscleGroups.piernas,
      secondaryMuscles: [MuscleGroups.gluteos],
      equipment: Equipment.barraOlimpica,
      difficulty: Difficulty.intermedio,
    ),
    ExerciseTemplate(
      id: 'piernas_2',
      name: 'Sentadilla con Mancuernas',
      muscleGroup: MuscleGroups.piernas,
      secondaryMuscles: [MuscleGroups.gluteos],
      equipment: Equipment.mancuernas,
      difficulty: Difficulty.principiante,
    ),
    ExerciseTemplate(
      id: 'piernas_3',
      name: 'Zancadas',
      muscleGroup: MuscleGroups.piernas,
      secondaryMuscles: [MuscleGroups.gluteos],
      equipment: Equipment.mancuernas,
      difficulty: Difficulty.principiante,
    ),
    ExerciseTemplate(
      id: 'piernas_4',
      name: 'Prensa de Piernas',
      muscleGroup: MuscleGroups.piernas,
      secondaryMuscles: [MuscleGroups.gluteos],
      equipment: Equipment.maquina,
      difficulty: Difficulty.principiante,
    ),
    ExerciseTemplate(
      id: 'piernas_5',
      name: 'Curl Femoral',
      muscleGroup: MuscleGroups.piernas,
      equipment: Equipment.maquina,
      difficulty: Difficulty.principiante,
    ),
    ExerciseTemplate(
      id: 'piernas_6',
      name: 'Extensión de Cuádriceps',
      muscleGroup: MuscleGroups.piernas,
      equipment: Equipment.maquina,
      difficulty: Difficulty.principiante,
    ),

    // ========== HOMBROS ==========
    ExerciseTemplate(
      id: 'hombros_1',
      name: 'Press Militar',
      muscleGroup: MuscleGroups.hombros,
      secondaryMuscles: [MuscleGroups.triceps],
      equipment: Equipment.barraOlimpica,
      difficulty: Difficulty.intermedio,
    ),
    ExerciseTemplate(
      id: 'hombros_2',
      name: 'Press con Mancuernas',
      muscleGroup: MuscleGroups.hombros,
      secondaryMuscles: [MuscleGroups.triceps],
      equipment: Equipment.mancuernas,
      difficulty: Difficulty.principiante,
    ),
    ExerciseTemplate(
      id: 'hombros_3',
      name: 'Elevaciones Laterales',
      muscleGroup: MuscleGroups.hombros,
      equipment: Equipment.mancuernas,
      difficulty: Difficulty.principiante,
    ),
    ExerciseTemplate(
      id: 'hombros_4',
      name: 'Elevaciones Frontales',
      muscleGroup: MuscleGroups.hombros,
      equipment: Equipment.mancuernas,
      difficulty: Difficulty.principiante,
    ),
    ExerciseTemplate(
      id: 'hombros_5',
      name: 'Face Pull',
      muscleGroup: MuscleGroups.hombros,
      equipment: Equipment.maquina,
      difficulty: Difficulty.intermedio,
    ),

    // ========== BÍCEPS ==========
    ExerciseTemplate(
      id: 'biceps_1',
      name: 'Curl con Barra',
      muscleGroup: MuscleGroups.biceps,
      equipment: Equipment.barraOlimpica,
      difficulty: Difficulty.principiante,
    ),
    ExerciseTemplate(
      id: 'biceps_2',
      name: 'Curl con Mancuernas',
      muscleGroup: MuscleGroups.biceps,
      equipment: Equipment.mancuernas,
      difficulty: Difficulty.principiante,
    ),
    ExerciseTemplate(
      id: 'biceps_3',
      name: 'Curl Martillo',
      muscleGroup: MuscleGroups.biceps,
      secondaryMuscles: [MuscleGroups.antebrazos],
      equipment: Equipment.mancuernas,
      difficulty: Difficulty.principiante,
    ),
    ExerciseTemplate(
      id: 'biceps_4',
      name: 'Curl en Banco Scott',
      muscleGroup: MuscleGroups.biceps,
      equipment: Equipment.barraOlimpica,
      difficulty: Difficulty.intermedio,
    ),

    // ========== TRÍCEPS ==========
    ExerciseTemplate(
      id: 'triceps_1',
      name: 'Press Francés',
      muscleGroup: MuscleGroups.triceps,
      equipment: Equipment.barraOlimpica,
      difficulty: Difficulty.intermedio,
    ),
    ExerciseTemplate(
      id: 'triceps_2',
      name: 'Extensiones con Mancuerna',
      muscleGroup: MuscleGroups.triceps,
      equipment: Equipment.mancuernas,
      difficulty: Difficulty.principiante,
    ),
    ExerciseTemplate(
      id: 'triceps_3',
      name: 'Fondos en Banco',
      muscleGroup: MuscleGroups.triceps,
      equipment: Equipment.pesoCorporal,
      difficulty: Difficulty.principiante,
    ),
    ExerciseTemplate(
      id: 'triceps_4',
      name: 'Press en Polea',
      muscleGroup: MuscleGroups.triceps,
      equipment: Equipment.maquina,
      difficulty: Difficulty.principiante,
    ),

    // ========== ABDOMEN ==========
    ExerciseTemplate(
      id: 'abdomen_1',
      name: 'Plancha',
      muscleGroup: MuscleGroups.abdomen,
      equipment: Equipment.pesoCorporal,
      difficulty: Difficulty.principiante,
    ),
    ExerciseTemplate(
      id: 'abdomen_2',
      name: 'Crunches',
      muscleGroup: MuscleGroups.abdomen,
      equipment: Equipment.pesoCorporal,
      difficulty: Difficulty.principiante,
    ),
    ExerciseTemplate(
      id: 'abdomen_3',
      name: 'Elevación de Piernas',
      muscleGroup: MuscleGroups.abdomen,
      equipment: Equipment.pesoCorporal,
      difficulty: Difficulty.intermedio,
    ),
    ExerciseTemplate(
      id: 'abdomen_4',
      name: 'Russian Twist',
      muscleGroup: MuscleGroups.abdomen,
      equipment: Equipment.maquina,
      difficulty: Difficulty.intermedio,
    ),
    ExerciseTemplate(
      id: 'abdomen_5',
      name: 'Ab Wheel',
      muscleGroup: MuscleGroups.abdomen,
      equipment: Equipment.maquina,
      difficulty: Difficulty.avanzado,
    ),

    // ========== GLÚTEOS ==========
    ExerciseTemplate(
      id: 'gluteos_1',
      name: 'Hip Thrust',
      muscleGroup: MuscleGroups.gluteos,
      equipment: Equipment.barraOlimpica,
      difficulty: Difficulty.intermedio,
    ),
    ExerciseTemplate(
      id: 'gluteos_2',
      name: 'Puente de Glúteos',
      muscleGroup: MuscleGroups.gluteos,
      equipment: Equipment.pesoCorporal,
      difficulty: Difficulty.principiante,
    ),
    ExerciseTemplate(
      id: 'gluteos_3',
      name: 'Patada de Glúteo en Cable',
      muscleGroup: MuscleGroups.gluteos,
      equipment: Equipment.maquina,
      difficulty: Difficulty.principiante,
    ),
  ];

  /// Obtener ejercicios filtrados por grupo muscular y equipamiento
  static List<ExerciseTemplate> getFiltered({
    String? muscleGroup,
    List<String>? equipment,
  }) {
    return exercises.where((exercise) {
      // Filtro por grupo muscular
      if (muscleGroup != null && muscleGroup.isNotEmpty) {
        if (exercise.muscleGroup != muscleGroup &&
            !exercise.secondaryMuscles.contains(muscleGroup)) {
          return false;
        }
      }

      // Filtro por equipamiento
      if (equipment != null && equipment.isNotEmpty) {
        if (!equipment.contains(exercise.equipment)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Buscar ejercicios por nombre
  static List<ExerciseTemplate> search(String query) {
    if (query.isEmpty) return exercises;

    final lowerQuery = query.toLowerCase();
    return exercises.where((exercise) {
      return exercise.name.toLowerCase().contains(lowerQuery) ||
          exercise.muscleGroup.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}

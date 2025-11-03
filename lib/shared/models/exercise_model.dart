/// Plantilla de ejercicio de la base de datos local
class ExerciseTemplate {
  final String id;
  final String name;
  final String muscleGroup; // Grupo muscular principal
  final List<String> secondaryMuscles; // Músculos secundarios
  final String equipment; // Equipamiento necesario
  final String difficulty; // Principiante, Intermedio, Avanzado
  final String exerciseType; // Tipo: Fuerza, Cardio, Tiempo
  final String? instructions;
  final String? imageUrl;
  final List<String>? commonMistakes; // Bulleted list of common errors to avoid.
  final List<String>? proTips; // Actionable tips for better form and muscle activation.
  final String? videoUrl; // For future expansion into video tutorials.

  ExerciseTemplate({
    required this.id,
    required this.name,
    required this.muscleGroup,
    this.secondaryMuscles = const [],
    required this.equipment,
    required this.difficulty,
    this.exerciseType = ExerciseType.fuerza, // Por defecto es fuerza
    this.instructions,
    this.imageUrl,
    this.commonMistakes,
    this.proTips,
    this.videoUrl,
  });

  factory ExerciseTemplate.fromJson(Map<String, dynamic> json) {
    return ExerciseTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      muscleGroup: json['muscle_group'] as String,
      secondaryMuscles: (json['secondary_muscles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      equipment: json['equipment'] as String,
      difficulty: json['difficulty'] as String,
      exerciseType:
          json['exercise_type'] as String? ?? ExerciseType.fuerza,
      instructions: json['instructions'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'muscle_group': muscleGroup,
      'secondary_muscles': secondaryMuscles,
      'equipment': equipment,
      'difficulty': difficulty,
      'exercise_type': exerciseType,
      'instructions': instructions,
      'image_url': imageUrl,
    };
  }

  /// Helper para verificar si es ejercicio de cardio
  bool get isCardio => exerciseType == ExerciseType.cardio;

  /// Helper para verificar si es ejercicio de fuerza
  bool get isStrength => exerciseType == ExerciseType.fuerza;

  /// Helper para verificar si es ejercicio de tiempo
  bool get isTime => exerciseType == ExerciseType.tiempo;

  @override
  String toString() =>
      'ExerciseTemplate($name, $muscleGroup, $equipment, $exerciseType)';
}

/// Grupos musculares
class MuscleGroups {
  static const String pecho = 'Pecho';
  static const String espalda = 'Espalda';
  static const String hombros = 'Hombros';
  static const String biceps = 'Bíceps';
  static const String triceps = 'Tríceps';
  static const String piernas = 'Piernas';
  static const String gluteos = 'Glúteos';
  static const String abdomen = 'Abdomen';
  static const String pantorrillas = 'Pantorrillas';
  static const String antebrazos = 'Antebrazos';

  static const List<String> all = [
    pecho,
    espalda,
    hombros,
    biceps,
    triceps,
    piernas,
    gluteos,
    abdomen,
    pantorrillas,
    antebrazos,
  ];
}

/// Equipamiento
class Equipment {
  static const String barraOlimpica = 'Barra Olímpica';
  static const String mancuernas = 'Mancuernas';
  static const String pesoCorporal = 'Peso Corporal';
  static const String maquina = 'Máquina';
  static const String polea = 'Polea/Cable';
  static const String bandasElasticas = 'Bandas Elásticas';
  static const String barraZ = 'Barra Z';
  static const String discos = 'Discos/Placas';
  static const String banca = 'Banca';
  static const String balon = 'Balón Medicinal';

  static const List<String> all = [
    barraOlimpica,
    mancuernas,
    pesoCorporal,
    maquina,
    polea,
    bandasElasticas,
    barraZ,
    discos,
    banca,
    balon,
  ];
}

/// Dificultad
class Difficulty {
  static const String principiante = 'Principiante';
  static const String intermedio = 'Intermedio';
  static const String avanzado = 'Avanzado';

  static const List<String> all = [principiante, intermedio, avanzado];
}

/// Tipo de ejercicio
class ExerciseType {
  static const String fuerza = 'Fuerza'; // Peso y repeticiones
  static const String cardio = 'Cardio'; // Distancia y duración
  static const String tiempo = 'Tiempo'; // Solo duración (plancha, etc.)

  static const List<String> all = [fuerza, cardio, tiempo];
}

/// Plantilla de ejercicio de la base de datos local
class ExerciseTemplate {
  final String id;
  final String name;
  final String muscleGroup; // Grupo muscular principal
  final List<String> secondaryMuscles; // Músculos secundarios
  final String equipment; // Equipamiento necesario
  final String difficulty; // Principiante, Intermedio, Avanzado
  final String? instructions;
  final String? imageUrl;

  ExerciseTemplate({
    required this.id,
    required this.name,
    required this.muscleGroup,
    this.secondaryMuscles = const [],
    required this.equipment,
    required this.difficulty,
    this.instructions,
    this.imageUrl,
  });

  factory ExerciseTemplate.fromJson(Map<String, dynamic> json) {
    return ExerciseTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      muscleGroup: json['muscle_group'] as String,
      secondaryMuscles:
          (json['secondary_muscles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      equipment: json['equipment'] as String,
      difficulty: json['difficulty'] as String,
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
      'instructions': instructions,
      'image_url': imageUrl,
    };
  }

  @override
  String toString() => 'ExerciseTemplate($name, $muscleGroup, $equipment)';
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

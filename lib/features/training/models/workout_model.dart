/// Modelo de entrenamiento individual
class WorkoutModel {
  final String id;
  final String userId;
  final String? userName;
  final String focus;
  final int duration;
  final List<ExerciseModel> exercises;
  final DateTime createdAt;

  WorkoutModel({
    required this.id,
    required this.userId,
    this.userName,
    required this.focus,
    required this.duration,
    required this.exercises,
    required this.createdAt,
  });

  /// Crear desde JSON (Firebase)
  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    return WorkoutModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String?,
      focus: json['focus'] as String,
      duration: json['duration'] as int,
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convertir a JSON (Firebase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'focus': focus,
      'duration': duration,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Crear copia con cambios
  WorkoutModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? focus,
    int? duration,
    List<ExerciseModel>? exercises,
    DateTime? createdAt,
  }) {
    return WorkoutModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      focus: focus ?? this.focus,
      duration: duration ?? this.duration,
      exercises: exercises ?? this.exercises,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Calcular volumen total (peso x reps x series)
  double get totalVolume {
    return exercises.fold(0.0, (sum, exercise) => sum + exercise.totalVolume);
  }

  /// Calcular total de series
  int get totalSets {
    return exercises.fold(0, (sum, exercise) => sum + exercise.sets.length);
  }

  /// Calcular total de repeticiones
  int get totalReps {
    return exercises.fold(0, (sum, exercise) => sum + exercise.totalReps);
  }

  @override
  String toString() =>
      'WorkoutModel($focus, ${exercises.length} ejercicios, $duration min)';
}

/// Modelo de ejercicio dentro de un entrenamiento
class ExerciseModel {
  final String name;
  final List<SetModel> sets;

  ExerciseModel({required this.name, required this.sets});

  /// Crear desde JSON
  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      name: json['name'] as String,
      sets: (json['sets'] as List<dynamic>)
          .map((s) => SetModel.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {'name': name, 'sets': sets.map((s) => s.toJson()).toList()};
  }

  /// Calcular volumen total del ejercicio
  double get totalVolume {
    return sets.fold(0.0, (sum, set) => sum + (set.weight * set.reps));
  }

  /// Calcular total de repeticiones
  int get totalReps {
    return sets.fold(0, (sum, set) => sum + set.reps);
  }

  @override
  String toString() => 'ExerciseModel($name, ${sets.length} series)';
}

/// Modelo de serie dentro de un ejercicio
/// Soporta diferentes tipos de métricas:
/// - Fuerza: weight + reps
/// - Cardio: distance + duration
/// - Tiempo: solo duration
class SetModel {
  // Métricas de fuerza
  final double weight; // kg
  final int reps; // repeticiones

  // Métricas de cardio
  final double? distance; // km
  final int? duration; // segundos

  SetModel({
    this.weight = 0,
    this.reps = 0,
    this.distance,
    this.duration,
  });

  /// Constructor para ejercicios de fuerza
  factory SetModel.strength({
    required double weight,
    required int reps,
  }) {
    return SetModel(weight: weight, reps: reps);
  }

  /// Constructor para ejercicios de cardio
  factory SetModel.cardio({
    required double distance,
    required int duration,
  }) {
    return SetModel(
      weight: 0,
      reps: 0,
      distance: distance,
      duration: duration,
    );
  }

  /// Constructor para ejercicios de tiempo
  factory SetModel.time({required int duration}) {
    return SetModel(weight: 0, reps: 0, duration: duration);
  }

  /// Crear desde JSON
  factory SetModel.fromJson(Map<String, dynamic> json) {
    return SetModel(
      weight: (json['weight'] as num?)?.toDouble() ?? 0,
      reps: json['reps'] as int? ?? 0,
      distance: (json['distance'] as num?)?.toDouble(),
      duration: json['duration'] as int?,
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'weight': weight,
      'reps': reps,
    };

    if (distance != null) {
      data['distance'] = distance;
    }

    if (duration != null) {
      data['duration'] = duration;
    }

    return data;
  }

  /// Verificar si es un set de fuerza
  bool get isStrength => weight > 0 && reps > 0;

  /// Verificar si es un set de cardio
  bool get isCardio => distance != null && duration != null;

  /// Verificar si es un set de tiempo
  bool get isTime => duration != null && distance == null;

  @override
  String toString() {
    if (isCardio) {
      return 'SetModel(${distance?.toStringAsFixed(2)} km en ${_formatDuration(duration!)})';
    } else if (isTime) {
      return 'SetModel(${_formatDuration(duration!)})';
    } else {
      return 'SetModel($weight kg x $reps)';
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${secs}s';
    }
    return '${secs}s';
  }
}

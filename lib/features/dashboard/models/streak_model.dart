/// Modelo para representar la racha de entrenamiento del usuario
class StreakModel {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastWorkoutDate;
  final List<bool> weeklyStreak; // 7 días: [lun, mar, mie, jue, vie, sab, dom]
  final DateTime? createdAt;
  final DateTime? updatedAt;

  StreakModel({
    required this.currentStreak,
    required this.longestStreak,
    this.lastWorkoutDate,
    required this.weeklyStreak,
    this.createdAt,
    this.updatedAt,
  });

  /// Crear desde cero (nuevo usuario)
  factory StreakModel.empty() {
    final now = DateTime.now();
    return StreakModel(
      currentStreak: 0,
      longestStreak: 0,
      lastWorkoutDate: null,
      weeklyStreak: List.filled(7, false),
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Crear desde JSON
  factory StreakModel.fromJson(Map<String, dynamic> json) {
    return StreakModel(
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      lastWorkoutDate: json['last_workout_date'] != null
          ? DateTime.parse(json['last_workout_date'] as String)
          : null,
      weeklyStreak:
          (json['weekly_streak'] as List<dynamic>?)
              ?.map((e) => e as bool)
              .toList() ??
          List.filled(7, false),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_workout_date': lastWorkoutDate?.toIso8601String(),
      'weekly_streak': weeklyStreak,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Copiar con modificaciones
  StreakModel copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastWorkoutDate,
    List<bool>? weeklyStreak,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StreakModel(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastWorkoutDate: lastWorkoutDate ?? this.lastWorkoutDate,
      weeklyStreak: weeklyStreak ?? List.from(this.weeklyStreak),
      createdAt: createdAt ?? this.createdAt,
      updatedAt:
          updatedAt ??
          DateTime.now(), // Siempre actualizar la fecha de modificación
    );
  }

  /// Verificar si entrenó hoy
  bool hasTrainedToday() {
    if (lastWorkoutDate == null) return false;
    final now = DateTime.now();
    return lastWorkoutDate!.year == now.year &&
        lastWorkoutDate!.month == now.month &&
        lastWorkoutDate!.day == now.day;
  }

  /// Verificar si la racha está activa (entrenó hoy o ayer)
  bool isStreakActive() {
    if (lastWorkoutDate == null) return false;
    final now = DateTime.now();
    final difference = now.difference(lastWorkoutDate!).inDays;
    return difference <= 1;
  }

  /// Obtener el índice del día actual en la semana (0 = lunes, 6 = domingo)
  static int getCurrentDayIndex() {
    final now = DateTime.now();
    // DateTime.weekday: 1 = lunes, 7 = domingo
    // Convertimos a: 0 = lunes, 6 = domingo
    return now.weekday - 1;
  }

  @override
  String toString() =>
      'StreakModel(current: $currentStreak, longest: $longestStreak, today: ${hasTrainedToday()})';
}

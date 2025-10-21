/// Modelo para representar la racha de entrenamiento del usuario
class StreakModel {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastWorkoutDate;
  final List<bool> weeklyStreak; // 7 días: [lun, mar, mie, jue, vie, sab, dom]
  final List<DateTime> trainedDates; // Fechas específicas entrenadas
  final DateTime? createdAt;
  final DateTime? updatedAt;

  StreakModel({
    required this.currentStreak,
    required this.longestStreak,
    this.lastWorkoutDate,
    required this.weeklyStreak,
    required this.trainedDates,
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
      trainedDates: [],
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
      trainedDates:
          (json['trained_dates'] as List<dynamic>?)
              ?.map((e) => DateTime.parse(e as String))
              .toList() ??
          [],
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
      'trained_dates': trainedDates
          .map((date) => date.toIso8601String())
          .toList(),
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
    List<DateTime>? trainedDates,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StreakModel(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastWorkoutDate: lastWorkoutDate ?? this.lastWorkoutDate,
      weeklyStreak: weeklyStreak ?? List.from(this.weeklyStreak),
      trainedDates: trainedDates ?? List.from(this.trainedDates),
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

  /// Obtener días desde el último entrenamiento
  int getDaysSinceLastWorkout() {
    if (lastWorkoutDate == null) return 0;
    final now = DateTime.now();
    return now.difference(lastWorkoutDate!).inDays;
  }

  /// Verificar si la racha está en peligro (pasó 1 día sin entrenar)
  bool isStreakInDanger() {
    final daysSince = getDaysSinceLastWorkout();
    return daysSince >= 2 && daysSince <= 3;
  }

  /// Verificar si la racha se perdió (más de 3 días sin entrenar)
  bool isStreakLost() {
    final daysSince = getDaysSinceLastWorkout();
    return daysSince > 3;
  }

  /// Obtener mensaje de estado de la racha
  String getStreakStatusMessage() {
    if (hasTrainedToday()) {
      return '¡Ya entrenaste hoy! 💪';
    } else if (isStreakActive()) {
      return 'Racha activa - ¡Sigue así! 🔥';
    } else if (isStreakInDanger()) {
      return '⚠️ Tu racha no se incrementará hasta que entrenes';
    } else if (isStreakLost()) {
      return '😔 Racha perdida - ¡Empieza de nuevo!';
    }
    return 'Empieza tu racha hoy 🚀';
  }

  /// Verificar si entrenó en una fecha específica
  bool hasTrainedOnDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    return trainedDates.any((trainedDate) {
      final trainedDateOnly = DateTime(
        trainedDate.year,
        trainedDate.month,
        trainedDate.day,
      );
      return trainedDateOnly.isAtSameMomentAs(targetDate);
    });
  }

  /// Obtener fechas entrenadas de la semana actual
  List<DateTime> getTrainedDatesThisWeek() {
    final now = DateTime.now();
    final currentWeekStart = _getWeekStart(now);
    final currentWeekEnd = currentWeekStart.add(const Duration(days: 6));

    return trainedDates.where((date) {
      return date.isAfter(currentWeekStart.subtract(const Duration(days: 1))) &&
          date.isBefore(currentWeekEnd.add(const Duration(days: 1)));
    }).toList();
  }

  /// Obtener el inicio de la semana (lunes a las 00:00:00)
  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday; // 1 = lunes, 7 = domingo
    final daysToSubtract = weekday - 1; // Días desde el lunes
    final weekStart = DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: daysToSubtract));
    return weekStart;
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

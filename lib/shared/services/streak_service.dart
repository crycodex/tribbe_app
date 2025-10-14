import 'dart:convert';
import 'package:get/get.dart';
import 'package:tribbe_app/features/dashboard/models/streak_model.dart';
import 'package:tribbe_app/shared/services/storage_service.dart';

/// Servicio para manejar las rachas de entrenamiento
class StreakService {
  final StorageService _storageService = Get.find<StorageService>();

  /// Obtener la racha actual del usuario
  StreakModel getStreak() {
    try {
      final streakData = _storageService.getStreakData();

      if (streakData == null) {
        return StreakModel.empty();
      }

      final json = jsonDecode(streakData) as Map<String, dynamic>;
      final streak = StreakModel.fromJson(json);

      // Verificar si necesitamos resetear la semana
      return _checkAndResetWeek(streak);
    } catch (e) {
      print('Error al obtener racha: $e');
      return StreakModel.empty();
    }
  }

  /// Guardar la racha
  Future<void> saveStreak(StreakModel streak) async {
    try {
      final json = jsonEncode(streak.toJson());
      await _storageService.saveStreakData(json);
    } catch (e) {
      print('Error al guardar racha: $e');
    }
  }

  /// Registrar un entrenamiento (incrementar racha)
  Future<StreakModel> registerWorkout() async {
    final currentStreak = getStreak();

    // Si ya entrenó hoy, no hacer nada
    if (currentStreak.hasTrainedToday()) {
      return currentStreak;
    }

    final now = DateTime.now();
    final dayIndex = StreakModel.getCurrentDayIndex();

    // Actualizar el día de hoy en la semana
    final newWeeklyStreak = List<bool>.from(currentStreak.weeklyStreak);
    newWeeklyStreak[dayIndex] = true;

    // Calcular nueva racha
    int newCurrentStreak;
    if (currentStreak.isStreakActive()) {
      // Continuar la racha
      newCurrentStreak = currentStreak.currentStreak + 1;
    } else {
      // Resetear la racha (perdió días)
      newCurrentStreak = 1;
    }

    // Actualizar racha más larga si es necesario
    final newLongestStreak = newCurrentStreak > currentStreak.longestStreak
        ? newCurrentStreak
        : currentStreak.longestStreak;

    final updatedStreak = currentStreak.copyWith(
      currentStreak: newCurrentStreak,
      longestStreak: newLongestStreak,
      lastWorkoutDate: now,
      weeklyStreak: newWeeklyStreak,
    );

    await saveStreak(updatedStreak);
    return updatedStreak;
  }

  /// Verificar y resetear la semana si es necesario
  StreakModel _checkAndResetWeek(StreakModel streak) {
    final now = DateTime.now();
    final weekStartString = _storageService.getWeekStartDate();

    if (weekStartString == null) {
      // Primera vez, guardar el inicio de la semana actual
      _saveWeekStart(now);
      return streak;
    }

    final weekStart = DateTime.parse(weekStartString);
    final daysSinceWeekStart = now.difference(weekStart).inDays;

    // Si han pasado 7 días o más, resetear la semana
    if (daysSinceWeekStart >= 7) {
      final resetStreak = streak.copyWith(weeklyStreak: List.filled(7, false));
      _saveWeekStart(now);
      saveStreak(resetStreak);
      return resetStreak;
    }

    return streak;
  }

  /// Guardar la fecha de inicio de semana
  void _saveWeekStart(DateTime date) {
    _storageService.saveWeekStartDate(date.toIso8601String());
  }

  /// Resetear completamente la racha (útil para testing)
  Future<void> resetStreak() async {
    await _storageService.removeStreakData();
    await _storageService.removeWeekStartDate();
  }

  /// Obtener los nombres de los días de la semana
  static List<String> getWeekDayNames() {
    return ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab', 'Dom'];
  }
}

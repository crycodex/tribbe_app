import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tribbe_app/features/dashboard/models/streak_model.dart';

/// Servicio para manejar las rachas de entrenamiento en Firestore
class StreakService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Colecciones
  static const String usersCollection = 'users';
  static const String streaksSubcollection = 'streaks';
  static const String streakDocId =
      'current_streak'; // Documento único para la racha actual

  /// Obtener la racha actual del usuario desde Firestore
  Future<StreakModel> getStreak() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return StreakModel.empty();
      }

      final docSnapshot = await _firestore
          .collection(usersCollection)
          .doc(userId)
          .collection(streaksSubcollection)
          .doc(streakDocId)
          .get();

      if (!docSnapshot.exists || docSnapshot.data() == null) {
        // Si no existe, crear una racha nueva
        final newStreak = StreakModel.empty();
        await saveStreak(newStreak);
        return newStreak;
      }

      final streak = StreakModel.fromJson(docSnapshot.data()!);

      // Verificar si necesitamos resetear la semana
      return _checkAndResetWeek(streak);
    } catch (e) {
      print('Error al obtener racha: $e');
      return StreakModel.empty();
    }
  }

  /// Guardar la racha en Firestore
  Future<void> saveStreak(StreakModel streak) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      await _firestore
          .collection(usersCollection)
          .doc(userId)
          .collection(streaksSubcollection)
          .doc(streakDocId)
          .set(streak.toJson(), SetOptions(merge: true));
    } catch (e) {
      print('Error al guardar racha: $e');
      throw Exception('Error al guardar racha: ${e.toString()}');
    }
  }

  /// Registrar un entrenamiento (incrementar racha)
  Future<StreakModel> registerWorkout() async {
    final currentStreak = await getStreak();

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

    // Guardar en el historial si es un nuevo récord
    if (newCurrentStreak == newLongestStreak && newCurrentStreak > 1) {
      await _saveStreakHistory(updatedStreak);
    }

    return updatedStreak;
  }

  /// Verificar y resetear la semana si es necesario
  StreakModel _checkAndResetWeek(StreakModel streak) {
    final now = DateTime.now();
    final lastWorkoutDate = streak.lastWorkoutDate;

    if (lastWorkoutDate == null) {
      return streak;
    }

    // Calcular el inicio de la semana actual (lunes)
    final currentWeekStart = _getWeekStart(now);
    final lastWorkoutWeekStart = _getWeekStart(lastWorkoutDate);

    // Si estamos en una semana diferente, resetear la semana
    if (currentWeekStart.isAfter(lastWorkoutWeekStart)) {
      return streak.copyWith(weeklyStreak: List.filled(7, false));
    }

    return streak;
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

  /// Guardar en el historial de rachas (cuando se alcanza un nuevo récord)
  Future<void> _saveStreakHistory(StreakModel streak) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _firestore
          .collection(usersCollection)
          .doc(userId)
          .collection(streaksSubcollection)
          .add({
            'current_streak': streak.currentStreak,
            'longest_streak': streak.longestStreak,
            'achieved_at': FieldValue.serverTimestamp(),
            'type': 'new_record',
          });
    } catch (e) {
      print('Error al guardar historial de racha: $e');
    }
  }

  /// Obtener el historial de récords de rachas
  Future<List<Map<String, dynamic>>> getStreakHistory() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final snapshot = await _firestore
          .collection(usersCollection)
          .doc(userId)
          .collection(streaksSubcollection)
          .where('type', isEqualTo: 'new_record')
          .orderBy('achieved_at', descending: true)
          .limit(10)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error al obtener historial de rachas: $e');
      return [];
    }
  }

  /// Resetear completamente la racha (útil para testing)
  Future<void> resetStreak() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _firestore
          .collection(usersCollection)
          .doc(userId)
          .collection(streaksSubcollection)
          .doc(streakDocId)
          .delete();
    } catch (e) {
      print('Error al resetear racha: $e');
    }
  }

  /// Stream para escuchar cambios en la racha en tiempo real
  Stream<StreakModel> getStreakStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value(StreakModel.empty());
    }

    return _firestore
        .collection(usersCollection)
        .doc(userId)
        .collection(streaksSubcollection)
        .doc(streakDocId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists || snapshot.data() == null) {
            return StreakModel.empty();
          }
          return StreakModel.fromJson(snapshot.data()!);
        });
  }

  /// Obtener los nombres de los días de la semana
  static List<String> getWeekDayNames() {
    return ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab', 'Dom'];
  }
}

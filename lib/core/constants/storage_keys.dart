/// Constantes para keys de almacenamiento local (SharedPreferences)
class StorageKeys {
  StorageKeys._();

  // Autenticación
  static const String authToken = 'auth_token';
  static const String userData = 'user_data';
  static const String isLoggedIn = 'is_logged_in';

  // Configuraciones
  static const String themeMode = 'theme_mode';
  static const String language = 'language';
  static const String gender = 'gender';

  // Onboarding
  static const String hasCompletedOnboarding = 'has_completed_onboarding';

  // Preferencias de usuario
  static const String notificationsEnabled = 'notifications_enabled';
  static const String soundEnabled = 'sound_enabled';

  // Rachas de entrenamiento
  static const String userStreak = 'user_streak';
  static const String weekStartDate = 'week_start_date';
}

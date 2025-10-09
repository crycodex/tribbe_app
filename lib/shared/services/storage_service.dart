import 'package:shared_preferences/shared_preferences.dart';
import 'package:tribbe_app/core/constants/storage_keys.dart';
import 'package:tribbe_app/core/enums/app_enums.dart';

/// Servicio para manejar el almacenamiento local usando SharedPreferences
class StorageService {
  late final SharedPreferences _prefs;

  /// Inicializar el servicio
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ========== CONFIGURACIONES ==========

  /// Obtener el modo de tema
  AppThemeMode getThemeMode() {
    final value = _prefs.getString(StorageKeys.themeMode);
    return value != null ? AppThemeMode.fromString(value) : AppThemeMode.system;
  }

  /// Guardar el modo de tema
  Future<bool> saveThemeMode(AppThemeMode mode) {
    return _prefs.setString(StorageKeys.themeMode, mode.value);
  }

  /// Obtener el idioma
  AppLanguage getLanguage() {
    final code = _prefs.getString(StorageKeys.language);
    return code != null ? AppLanguage.fromCode(code) : AppLanguage.spanish;
  }

  /// Guardar el idioma
  Future<bool> saveLanguage(AppLanguage language) {
    return _prefs.setString(StorageKeys.language, language.code);
  }

  /// Obtener el género del usuario
  UserGender? getGender() {
    final value = _prefs.getString(StorageKeys.gender);
    return value != null ? UserGender.fromString(value) : null;
  }

  /// Guardar el género del usuario
  Future<bool> saveGender(UserGender gender) {
    return _prefs.setString(StorageKeys.gender, gender.value);
  }

  // ========== AUTENTICACIÓN ==========

  /// Obtener el token de autenticación
  String? getAuthToken() {
    return _prefs.getString(StorageKeys.authToken);
  }

  /// Alias para getAuthToken
  String? getToken() => getAuthToken();

  /// Guardar el token de autenticación
  Future<bool> saveAuthToken(String token) {
    return _prefs.setString(StorageKeys.authToken, token);
  }

  /// Alias para saveAuthToken
  Future<bool> saveToken(String token) => saveAuthToken(token);

  /// Obtener datos del usuario
  Map<String, dynamic>? getUserData() {
    final jsonString = _prefs.getString(StorageKeys.userData);
    if (jsonString == null) return null;

    try {
      final Map<String, dynamic> data = {};
      // SharedPreferences no soporta guardar Map directamente,
      // así que guardamos como strings individuales con prefijo
      final keys = _prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith('user_')) {
          final userKey = key.substring(5); // Remover prefijo 'user_'
          data[userKey] = _prefs.get(key);
        }
      }
      return data.isEmpty ? null : data;
    } catch (e) {
      return null;
    }
  }

  /// Guardar datos del usuario
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    // Guardar cada campo con prefijo 'user_'
    for (final entry in userData.entries) {
      final key = 'user_${entry.key}';
      final value = entry.value;

      if (value is String) {
        await _prefs.setString(key, value);
      } else if (value is int) {
        await _prefs.setInt(key, value);
      } else if (value is double) {
        await _prefs.setDouble(key, value);
      } else if (value is bool) {
        await _prefs.setBool(key, value);
      } else if (value != null) {
        await _prefs.setString(key, value.toString());
      }
    }
  }

  /// Verificar si el usuario está logueado
  bool isLoggedIn() {
    return _prefs.getBool(StorageKeys.isLoggedIn) ?? false;
  }

  /// Guardar el estado de login
  Future<bool> saveLoginState(bool isLoggedIn) {
    return _prefs.setBool(StorageKeys.isLoggedIn, isLoggedIn);
  }

  // ========== ONBOARDING ==========

  /// Verificar si completó el onboarding
  bool hasCompletedOnboarding() {
    return _prefs.getBool(StorageKeys.hasCompletedOnboarding) ?? false;
  }

  /// Marcar el onboarding como completado
  Future<bool> setOnboardingCompleted() {
    return _prefs.setBool(StorageKeys.hasCompletedOnboarding, true);
  }

  // ========== PREFERENCIAS ==========

  /// Obtener si las notificaciones están habilitadas
  bool areNotificationsEnabled() {
    return _prefs.getBool(StorageKeys.notificationsEnabled) ?? true;
  }

  /// Guardar el estado de las notificaciones
  Future<bool> saveNotificationsEnabled(bool enabled) {
    return _prefs.setBool(StorageKeys.notificationsEnabled, enabled);
  }

  /// Obtener si el sonido está habilitado
  bool isSoundEnabled() {
    return _prefs.getBool(StorageKeys.soundEnabled) ?? true;
  }

  /// Guardar el estado del sonido
  Future<bool> saveSoundEnabled(bool enabled) {
    return _prefs.setBool(StorageKeys.soundEnabled, enabled);
  }

  // ========== UTILIDADES ==========

  /// Limpiar todos los datos almacenados
  Future<bool> clearAll() {
    return _prefs.clear();
  }

  /// Alias para clearAll
  Future<bool> clear() => clearAll();

  /// Limpiar solo datos de sesión (mantener configuraciones)
  Future<void> clearSessionData() async {
    await _prefs.remove(StorageKeys.authToken);
    await _prefs.remove(StorageKeys.userData);
    await _prefs.remove(StorageKeys.isLoggedIn);

    // Limpiar todos los campos de usuario con prefijo 'user_'
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith('user_')) {
        await _prefs.remove(key);
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/core/enums/app_enums.dart';
import 'package:tribbe_app/shared/services/storage_service.dart';

/// Controller para manejar la configuración de la aplicación
class SettingsController extends GetxController {
  final StorageService _storageService = Get.find();

  // Observables
  final themeMode = Rx<AppThemeMode>(AppThemeMode.system);
  final language = Rx<AppLanguage>(AppLanguage.spanish);
  final gender = Rx<UserGender?>(null);

  // Getters computados
  bool get isDarkMode {
    if (themeMode.value == AppThemeMode.system) {
      return Get.isDarkMode;
    }
    return themeMode.value == AppThemeMode.dark;
  }

  ThemeMode get flutterThemeMode {
    switch (themeMode.value) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  /// Cargar configuraciones desde storage
  void _loadSettings() {
    themeMode.value = _storageService.getThemeMode();
    language.value = _storageService.getLanguage();
    gender.value = _storageService.getGender();
  }

  /// Cambiar el modo de tema
  Future<void> setThemeMode(AppThemeMode mode) async {
    themeMode.value = mode;
    await _storageService.saveThemeMode(mode);

    // Aplicar el tema en GetX
    Get.changeThemeMode(flutterThemeMode);
  }

  /// Cambiar el idioma
  Future<void> setLanguage(AppLanguage newLanguage) async {
    language.value = newLanguage;
    await _storageService.saveLanguage(newLanguage);
    // TODO: Actualizar el idioma de la app cuando se implemente i18n
    // Get.updateLocale(Locale(newLanguage.code));
  }

  /// Cambiar el género
  Future<void> setGender(UserGender newGender) async {
    gender.value = newGender;
    await _storageService.saveGender(newGender);
  }

  /// Alternar entre modo claro y oscuro
  Future<void> toggleTheme() async {
    final newMode = isDarkMode ? AppThemeMode.light : AppThemeMode.dark;
    await setThemeMode(newMode);
  }
}

/// Modo de tema de la aplicación
enum AppThemeMode {
  light('light', 'Claro'),
  dark('dark', 'Oscuro'),
  system('system', 'Sistema');

  const AppThemeMode(this.value, this.label);

  final String value;
  final String label;

  static AppThemeMode fromString(String value) {
    return AppThemeMode.values.firstWhere(
      (mode) => mode.value == value,
      orElse: () => AppThemeMode.system,
    );
  }
}

/// Idiomas disponibles en la aplicación
enum AppLanguage {
  spanish('es', 'Español', '🇪🇸'),
  english('en', 'English', '🇺🇸');

  const AppLanguage(this.code, this.label, this.flag);

  final String code;
  final String label;
  final String flag;

  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => AppLanguage.spanish,
    );
  }
}

/// Género del usuario
enum UserGender {
  male('male', 'Masculino', 'M'),
  female('female', 'Femenino', 'F');

  const UserGender(this.value, this.label, this.abbreviation);

  final String value;
  final String label;
  final String abbreviation;

  static UserGender fromString(String value) {
    return UserGender.values.firstWhere(
      (gender) => gender.value == value,
      orElse: () => UserGender.male,
    );
  }
}

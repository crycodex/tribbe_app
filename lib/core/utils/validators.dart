/// Validadores de formularios reutilizables
class Validators {
  Validators._();

  /// Valida que el campo no esté vacío
  static String? required(String? value, {String fieldName = 'Campo'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }
    return null;
  }

  /// Valida formato de email
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email es requerido';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Ingresa un email válido';
    }
    return null;
  }

  /// Valida contraseña (mínimo 6 caracteres)
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Contraseña es requerida';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  /// Valida que las contraseñas coincidan
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }
    if (value != password) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  /// Valida username (sin espacios, solo letras, números y guiones bajos)
  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Usuario es requerido';
    }
    if (value.length < 3) {
      return 'El usuario debe tener al menos 3 caracteres';
    }
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value)) {
      return 'Solo letras, números y guiones bajos';
    }
    return null;
  }

  /// Valida números positivos
  static String? positiveNumber(String? value, {String fieldName = 'Número'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }
    final number = double.tryParse(value.trim());
    if (number == null || number <= 0) {
      return '$fieldName debe ser un número positivo';
    }
    return null;
  }
}

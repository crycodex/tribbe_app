import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/features/auth/models/user_profile_model.dart';
import 'package:tribbe_app/shared/services/firestore_service.dart';
import 'package:tribbe_app/shared/services/firebase_auth_service.dart';

/// Controlador para personalizar la tarjeta de crédito
class CreditCardCustomizationController extends GetxController {
  // Dependencias
  final FirestoreService _firestoreService = Get.find();
  final FirebaseAuthService _authService = Get.find();

  // Observables
  final RxBool isLoading = false.obs;
  final Rx<CardPreferences> cardPreferences = CardPreferences().obs;
  final RxString selectedStyle = 'minimal'.obs;
  final RxBool showPattern = true.obs;
  final RxDouble patternOpacity = 0.02.obs;
  final Rx<Color> color1 = const Color(0xFF1A1A1A).obs;
  final Rx<Color> color2 = const Color(0xFF2D2D2D).obs;
  final Rx<Color> color3 = const Color(0xFF1A1A1A).obs;

  // Estilos predefinidos
  final List<Map<String, dynamic>> cardStyles = [
    {
      'name': 'minimal',
      'label': 'Minimalista',
      'colors': [
        Color(0xFF1A1A1A),
        Color(0xFF2D2D2D),
        Color(0xFF1A1A1A),
      ],
    },
    {
      'name': 'gradient',
      'label': 'Gradiente',
      'colors': [
        Color(0xFF667EEA),
        Color(0xFF764BA2),
        Color(0xFF667EEA),
      ],
    },
    {
      'name': 'dark',
      'label': 'Oscuro',
      'colors': [
        Color(0xFF000000),
        Color(0xFF1A1A1A),
        Color(0xFF000000),
      ],
    },
    {
      'name': 'light',
      'label': 'Claro',
      'colors': [
        Color(0xFFFFFFFF),
        Color(0xFFF5F5F5),
        Color(0xFFFFFFFF),
      ],
    },
  ];

  @override
  void onInit() {
    super.onInit();
    _loadCardPreferences();
  }

  /// Cargar preferencias de la tarjeta desde Firebase
  Future<void> _loadCardPreferences() async {
    try {
      isLoading.value = true;
      final user = _authService.currentUser;
      if (user == null) return;

      final profile = await _firestoreService.getUserProfile(user.uid);
      if (profile?.preferencias?.cardPreferences != null) {
        final prefs = profile!.preferencias!.cardPreferences!;
        cardPreferences.value = prefs;
        selectedStyle.value = prefs.cardStyle ?? 'minimal';
        showPattern.value = prefs.showPattern;
        patternOpacity.value = prefs.patternOpacity;

        if (prefs.gradientColors != null &&
            prefs.gradientColors!.length >= 3) {
          color1.value = Color(int.parse(prefs.gradientColors![0]));
          color2.value = Color(int.parse(prefs.gradientColors![1]));
          color3.value = Color(int.parse(prefs.gradientColors![2]));
        } else {
          _applyStyleColors(selectedStyle.value);
        }
      } else {
        _applyStyleColors(selectedStyle.value);
      }
    } catch (e) {
      debugPrint('Error cargando preferencias de tarjeta: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Aplicar colores de un estilo predefinido
  void _applyStyleColors(String style) {
    final styleData = cardStyles.firstWhere(
      (s) => s['name'] == style,
      orElse: () => cardStyles[0],
    );
    final colors = styleData['colors'] as List<Color>;
    color1.value = colors[0];
    color2.value = colors[1];
    color3.value = colors[2];
  }

  /// Cambiar estilo de tarjeta
  void changeStyle(String style) {
    selectedStyle.value = style;
    _applyStyleColors(style);
    _updateCardPreferences();
  }

  /// Cambiar color personalizado
  void changeColor(int index, Color color) {
    switch (index) {
      case 0:
        color1.value = color;
        break;
      case 1:
        color2.value = color;
        break;
      case 2:
        color3.value = color;
        break;
    }
    _updateCardPreferences();
  }

  /// Toggle mostrar patrón
  void togglePattern() {
    showPattern.value = !showPattern.value;
    _updateCardPreferences();
  }

  /// Cambiar opacidad del patrón
  void changePatternOpacity(double opacity) {
    patternOpacity.value = opacity;
    _updateCardPreferences();
  }

  /// Actualizar preferencias en Firebase
  Future<void> _updateCardPreferences() async {
    try {
      final user = _authService.currentUser;
      if (user == null) return;

      final gradientColors = [
        color1.value.value.toString(),
        color2.value.value.toString(),
        color3.value.value.toString(),
      ];

      final newCardPreferences = CardPreferences(
        gradientColors: gradientColors,
        cardStyle: selectedStyle.value,
        showPattern: showPattern.value,
        patternOpacity: patternOpacity.value,
      );

      cardPreferences.value = newCardPreferences;

      // Obtener preferencias actuales
      final profile = await _firestoreService.getUserProfile(user.uid);
      final currentPrefs = profile?.preferencias ?? Preferencias();

      // Actualizar con nuevas preferencias de tarjeta
      final updatedPrefs = currentPrefs.copyWith(
        cardPreferences: newCardPreferences,
      );

      await _firestoreService.updatePreferencias(
        uid: user.uid,
        preferencias: updatedPrefs,
      );
    } catch (e) {
      debugPrint('Error actualizando preferencias de tarjeta: $e');
      Get.snackbar(
        'Error',
        'No se pudieron guardar las preferencias',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Guardar preferencias (llamado explícitamente desde la UI)
  Future<void> savePreferences() async {
    try {
      isLoading.value = true;
      await _updateCardPreferences();
      Get.snackbar(
        'Éxito',
        'Preferencias guardadas',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron guardar las preferencias',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Obtener colores actuales
  List<Color> getCurrentColors() {
    return [color1.value, color2.value, color3.value];
  }
}


import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/app/routes/route_paths.dart';
import 'package:tribbe_app/core/enums/app_enums.dart';
import 'package:tribbe_app/features/auth/models/user_profile_model.dart';
import 'package:tribbe_app/shared/controllers/settings_controller.dart';
import 'package:tribbe_app/shared/services/firestore_service.dart';
import 'package:tribbe_app/shared/services/friendship_service.dart';

/// Controlador para el stepper de personalización inicial
class OnboardingStepperController extends GetxController {
  final FirestoreService _firestoreService = Get.find();
  final SettingsController _settingsController = Get.find();
  final FriendshipService _friendshipService = Get.find();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Estado del stepper
  final RxInt currentStep = 0.obs;
  final RxBool isLoading = false.obs;
  final RxString userId = ''.obs;

  // Step 1: Preferencias (ya guardadas, solo para mostrar)
  final RxString tema = 'Día'.obs;
  final RxString idioma = 'Español'.obs;
  final RxString genero = 'Masculino'.obs;
  final RxString unidadMedida = 'cm'.obs;
  final RxString unidadPeso = 'kg'.obs;

  // Step 2: Info Personal
  final Rx<DateTime?> fechaNacimiento = Rx<DateTime?>(null);
  final RxString bio = ''.obs;
  final RxString metaFitness = 'Masa muscular'.obs;
  final RxList<String> lesiones = <String>[].obs;
  final RxString nivelExperiencia = 'Intermedio'.obs;
  final RxInt condicionFisicaActual = 50.obs;
  final RxString pais = ''.obs;
  final RxString provincia = ''.obs;
  final RxString ciudad = ''.obs;
  final Rx<double?> latitud = Rx<double?>(null);
  final Rx<double?> longitud = Rx<double?>(null);

  // Step 3: Personaje/Avatar
  final RxString nombreCompleto = ''.obs;
  final RxInt tonoPiel = 1.obs; // 1, 2, 3
  final RxString avatarUrl = ''.obs;

  // Validación de username
  final RxBool isCheckingUsername = false.obs;
  final RxString usernameValidationError = ''.obs;
  Timer? _usernameDebounce;

  // Step 4: Medidas
  final RxDouble alturaCm = 170.0.obs;
  final RxDouble pesoKg = 70.0.obs;
  final RxDouble porcentajeGrasa = 15.0.obs;

  // Medidas específicas
  final RxDouble cuello = 0.0.obs;
  final RxDouble hombro = 0.0.obs;
  final RxDouble brazoIzquierdo = 0.0.obs;
  final RxDouble brazoDerecho = 0.0.obs;
  final RxDouble antebrazoIzquierdo = 0.0.obs;
  final RxDouble antebrazoDerecho = 0.0.obs;
  final RxDouble pecho = 0.0.obs;
  final RxDouble espalda = 0.0.obs;
  final RxDouble cintura = 0.0.obs;
  final RxDouble cuadricepIzquierdo = 0.0.obs;
  final RxDouble cuadricepDerecho = 0.0.obs;
  final RxDouble pantorrillaIzquierda = 0.0.obs;
  final RxDouble pantorrillaDerecha = 0.0.obs;

  // Lista de lesiones disponibles
  final List<String> lesionesList = [
    'Hombros',
    'Codos',
    'Muñecas',
    'Espalda baja',
    'Espalda alta',
    'Rodillas',
    'Tobillos',
    'Caderas',
    'Cuello',
  ];

  // Metas fitness disponibles
  final List<String> metasFitness = [
    'Masa muscular',
    'Pérdida de peso',
    'Fuerza',
    'Resistencia',
    'Salud general',
    'Definición',
  ];

  // Niveles de experiencia
  final List<String> nivelesExperiencia = [
    'Principiante',
    'Intermedio',
    'Avanzado',
  ];

  @override
  void onInit() {
    super.onInit();
    // Obtener userId del usuario autenticado
    _initializeUserId();
    // Cargar preferencias ya guardadas
    _loadExistingPreferences();
  }

  /// Inicializar userId desde FirebaseAuth o argumentos
  void _initializeUserId() {
    // Primero intentar obtener desde argumentos
    if (Get.arguments != null && Get.arguments['userId'] != null) {
      userId.value = Get.arguments['userId'] as String;
    }
    // Si no hay argumentos, obtener del usuario autenticado
    else if (_auth.currentUser != null) {
      userId.value = _auth.currentUser!.uid;
    }
  }

  @override
  void onClose() {
    _usernameDebounce?.cancel();
    super.onClose();
  }

  /// Verificar disponibilidad de username con debounce
  void checkUsernameAvailability(String username) {
    nombreCompleto.value = username;

    // Cancelar el timer anterior
    _usernameDebounce?.cancel();

    // Limpiar error si el campo está vacío
    if (username.trim().isEmpty) {
      usernameValidationError.value = '';
      isCheckingUsername.value = false;
      return;
    }

    // Validación básica del formato
    final normalizedUsername = username.toLowerCase().trim();

    // Solo letras, números y guiones bajos
    final validFormat = RegExp(r'^[a-z0-9_]+$');
    if (!validFormat.hasMatch(normalizedUsername)) {
      usernameValidationError.value = 'Solo letras, números y guiones bajos';
      isCheckingUsername.value = false;
      return;
    }

    // Mínimo 3 caracteres
    if (normalizedUsername.length < 3) {
      usernameValidationError.value = 'Mínimo 3 caracteres';
      isCheckingUsername.value = false;
      return;
    }

    // Máximo 20 caracteres
    if (normalizedUsername.length > 20) {
      usernameValidationError.value = 'Máximo 20 caracteres';
      isCheckingUsername.value = false;
      return;
    }

    // Iniciar debounce para verificar disponibilidad
    isCheckingUsername.value = true;
    usernameValidationError.value = '';

    _usernameDebounce = Timer(const Duration(milliseconds: 500), () async {
      final isAvailable = await _friendshipService.isUsernameAvailable(
        normalizedUsername,
      );

      isCheckingUsername.value = false;

      if (!isAvailable) {
        usernameValidationError.value = 'Este nombre de usuario ya está en uso';
      } else {
        usernameValidationError.value = '';
      }
    });
  }

  /// Cargar preferencias existentes del usuario (desde SettingsController)
  Future<void> _loadExistingPreferences() async {
    // Cargar desde el SettingsController (que ya tiene las preferencias de SharedPreferences)
    final currentTheme = _settingsController.themeMode.value;
    tema.value = currentTheme == AppThemeMode.dark ? 'Noche' : 'Día';

    final currentLanguage = _settingsController.language.value;
    idioma.value = currentLanguage == AppLanguage.spanish
        ? 'Español'
        : 'English';

    final currentGender = _settingsController.gender.value;
    if (currentGender != null) {
      genero.value = currentGender == UserGender.male
          ? 'Masculino'
          : 'Femenino';
    }
  }

  /// Actualizar tema en tiempo real
  Future<void> updateTema(String nuevoTema) async {
    tema.value = nuevoTema;
    final themeMode = nuevoTema == 'Noche'
        ? AppThemeMode.dark
        : AppThemeMode.light;
    await _settingsController.setThemeMode(themeMode);
  }

  /// Actualizar idioma en tiempo real
  Future<void> updateIdioma(String nuevoIdioma) async {
    idioma.value = nuevoIdioma;
    final language = nuevoIdioma == 'Español'
        ? AppLanguage.spanish
        : AppLanguage.english;
    await _settingsController.setLanguage(language);
  }

  /// Actualizar género en tiempo real
  Future<void> updateGenero(String nuevoGenero) async {
    genero.value = nuevoGenero;

    // Solo guardamos en settings si es Masculino o Femenino
    // "Otro" no tiene correspondencia en el enum UserGender
    if (nuevoGenero == 'Masculino') {
      await _settingsController.setGender(UserGender.male);
    } else if (nuevoGenero == 'Femenino') {
      await _settingsController.setGender(UserGender.female);
    }
    // Para "Otro" solo actualizamos el valor local, se guardará en Firestore al finalizar
  }

  /// Actualizar unidad de peso
  void updateUnidadPeso(String nuevaUnidad) {
    if (unidadPeso.value == nuevaUnidad) return;

    // Convertir el peso actual
    if (nuevaUnidad == 'lb' && unidadPeso.value == 'kg') {
      // kg a lb
      pesoKg.value = pesoKg.value * 2.20462;
    } else if (nuevaUnidad == 'kg' && unidadPeso.value == 'lb') {
      // lb a kg
      pesoKg.value = pesoKg.value / 2.20462;
    }

    unidadPeso.value = nuevaUnidad;
  }

  /// Actualizar unidad de medida
  void updateUnidadMedida(String nuevaUnidad) {
    if (unidadMedida.value == nuevaUnidad) return;

    // Convertir altura
    if (nuevaUnidad == 'in' && unidadMedida.value == 'cm') {
      // cm a in
      alturaCm.value = alturaCm.value / 2.54;
    } else if (nuevaUnidad == 'cm' && unidadMedida.value == 'in') {
      // in a cm
      alturaCm.value = alturaCm.value * 2.54;
    }

    // Convertir medidas específicas si están activadas
    if (cuello.value > 0) {
      _convertirMedidasEspecificas(nuevaUnidad);
    }

    unidadMedida.value = nuevaUnidad;
  }

  /// Convertir todas las medidas específicas
  void _convertirMedidasEspecificas(String nuevaUnidad) {
    final factor = nuevaUnidad == 'in' ? 1 / 2.54 : 2.54;

    if (cuello.value > 0) cuello.value *= factor;
    if (hombro.value > 0) hombro.value *= factor;
    if (brazoIzquierdo.value > 0) brazoIzquierdo.value *= factor;
    if (brazoDerecho.value > 0) brazoDerecho.value *= factor;
    if (antebrazoIzquierdo.value > 0) antebrazoIzquierdo.value *= factor;
    if (antebrazoDerecho.value > 0) antebrazoDerecho.value *= factor;
    if (pecho.value > 0) pecho.value *= factor;
    if (espalda.value > 0) espalda.value *= factor;
    if (cintura.value > 0) cintura.value *= factor;
    if (cuadricepIzquierdo.value > 0) cuadricepIzquierdo.value *= factor;
    if (cuadricepDerecho.value > 0) cuadricepDerecho.value *= factor;
    if (pantorrillaIzquierda.value > 0) pantorrillaIzquierda.value *= factor;
    if (pantorrillaDerecha.value > 0) pantorrillaDerecha.value *= factor;
  }

  /// Obtener altura con unidad
  String get alturaConUnidad {
    if (unidadMedida.value == 'cm') {
      return '${alturaCm.value.toInt()} cm';
    } else {
      return '${alturaCm.value.toStringAsFixed(1)} in';
    }
  }

  /// Obtener peso con unidad
  String get pesoConUnidad {
    if (unidadPeso.value == 'kg') {
      return '${pesoKg.value.toInt()} kg';
    } else {
      return '${pesoKg.value.toStringAsFixed(1)} lb';
    }
  }

  /// Validar step actual antes de avanzar
  bool validateCurrentStep() {
    switch (currentStep.value) {
      case 0: // Preferencias - siempre válido
        return true;

      case 1: // Info Personal - fecha, meta fitness y ubicación obligatorias
        // Validar fecha de nacimiento
        if (fechaNacimiento.value == null) {
          Get.snackbar(
            'Campo requerido',
            'Por favor selecciona tu fecha de nacimiento',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
          return false;
        }

        // Validar que sea mayor de edad (opcional pero recomendado)
        final edad =
            DateTime.now().difference(fechaNacimiento.value!).inDays ~/ 365;
        if (edad < 13) {
          Get.snackbar(
            'Edad no válida',
            'Debes tener al menos 13 años para usar Tribbe',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
          return false;
        }

        if (edad > 120) {
          Get.snackbar(
            'Fecha no válida',
            'Por favor verifica tu fecha de nacimiento',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
          return false;
        }

        // Validar meta fitness
        if (metaFitness.value.isEmpty) {
          Get.snackbar(
            'Campo requerido',
            'Por favor selecciona tu meta fitness',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
          return false;
        }

        // Validar ubicación (al menos país y ciudad)
        if (pais.value.isEmpty || ciudad.value.isEmpty) {
          Get.snackbar(
            'Ubicación requerida',
            'Por favor configura tu ubicación (país y ciudad)',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
          return false;
        }

        return true;

      case 2: // Personaje - username obligatorio
        if (nombreCompleto.value.trim().isEmpty) {
          Get.snackbar(
            'Campo requerido',
            'Por favor ingresa tu nombre de usuario',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
          return false;
        }

        // Validar que el username tenga al menos 3 caracteres
        if (nombreCompleto.value.trim().length < 3) {
          Get.snackbar(
            'Username inválido',
            'El nombre de usuario debe tener al menos 3 caracteres',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
          return false;
        }

        // Validar que no haya errores de validación
        if (usernameValidationError.value.isNotEmpty) {
          Get.snackbar(
            'Username no válido',
            usernameValidationError.value,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
          return false;
        }

        // Esperar a que termine la verificación si está en progreso
        if (isCheckingUsername.value) {
          Get.snackbar(
            'Verificando',
            'Por favor espera mientras verificamos la disponibilidad',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
          return false;
        }

        return true;

      case 3: // Medidas - altura y peso obligatorios
        if (alturaCm.value <= 0) {
          Get.snackbar(
            'Altura requerida',
            'Por favor ajusta tu altura',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
          return false;
        }

        if (pesoKg.value <= 0) {
          Get.snackbar(
            'Peso requerido',
            'Por favor ajusta tu peso',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
          return false;
        }

        // Validaciones de rangos razonables
        final esCm = unidadMedida.value == 'cm';
        final minAltura = esCm ? 100.0 : 39.4;
        final maxAltura = esCm ? 250.0 : 98.4;

        if (alturaCm.value < minAltura || alturaCm.value > maxAltura) {
          Get.snackbar(
            'Altura fuera de rango',
            'Por favor verifica tu altura',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
          return false;
        }

        final esKg = unidadPeso.value == 'kg';
        final minPeso = esKg ? 30.0 : 66.0;
        final maxPeso = esKg ? 300.0 : 660.0;

        if (pesoKg.value < minPeso || pesoKg.value > maxPeso) {
          Get.snackbar(
            'Peso fuera de rango',
            'Por favor verifica tu peso',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
          return false;
        }

        return true;

      default:
        return true;
    }
  }

  /// Avanzar al siguiente paso
  void nextStep() {
    if (currentStep.value < 3) {
      if (validateCurrentStep()) {
        currentStep.value++;
      }
    }
  }

  /// Retroceder al paso anterior
  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  /// Ir a un paso específico
  void goToStep(int step) {
    if (step >= 0 && step <= 3) {
      currentStep.value = step;
    }
  }

  /// Toggle lesión
  void toggleLesion(String lesion) {
    if (lesiones.contains(lesion)) {
      lesiones.remove(lesion);
    } else {
      lesiones.add(lesion);
    }
  }

  /// Completar personalización y guardar en Firestore
  Future<void> completeOnboarding() async {
    try {
      isLoading.value = true;

      // Validar que tenemos un userId
      if (userId.value.isEmpty) {
        Get.snackbar(
          'Error',
          'No se pudo identificar el usuario. Por favor inicia sesión nuevamente.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        isLoading.value = false;
        return;
      }
      final userExists = await _firestoreService.userProfileExists(
        userId.value,
      );
      if (!userExists) {
        await _firestoreService.createUserProfile(
          uid: userId.value,
          email: _auth.currentUser!.email!,
        );
      } else {}

      // 1. Actualizar/Confirmar preferencias
      final preferencias = Preferencias(
        tema: tema.value,
        unidades: Unidades(medida: unidadMedida.value, peso: unidadPeso.value),
        idioma: idioma.value,
        genero: genero.value,
      );

      await _firestoreService.updatePreferencias(
        uid: userId.value,
        preferencias: preferencias,
      );

      // 2. Guardar información fitness
      final bioText = bio.value.isEmpty
          ? 'Mejorar mi condición física general'
          : bio.value;

      final informacion = Informacion(
        proposito: bioText,
        metaFitness: metaFitness.value,
        lesiones: lesiones.isNotEmpty ? lesiones : null,
        nivelExperiencia: nivelExperiencia.value,
        condicionFisicaActual: condicionFisicaActual.value,
      );
      await _firestoreService.updateInformacion(
        uid: userId.value,
        informacion: informacion,
      );

      // 3. Guardar personaje/avatar
      final personaje = Personaje(
        genero: genero.value,
        tonoPiel: tonoPiel.value.toString(), // Guardar como "1", "2", "3"
        avatarUrl: avatarUrl.value.isEmpty ? null : avatarUrl.value,
      );
      await _firestoreService.updatePersonaje(
        uid: userId.value,
        personaje: personaje,
      );

      // 4. Guardar medidas
      // Solo incluir medidas específicas si al menos una está activada
      final tieneMedidasEspecificas =
          cuello.value > 0 ||
          hombro.value > 0 ||
          brazoIzquierdo.value > 0 ||
          brazoDerecho.value > 0 ||
          antebrazoIzquierdo.value > 0 ||
          antebrazoDerecho.value > 0 ||
          pecho.value > 0 ||
          espalda.value > 0 ||
          cintura.value > 0 ||
          cuadricepIzquierdo.value > 0 ||
          cuadricepDerecho.value > 0 ||
          pantorrillaIzquierda.value > 0 ||
          pantorrillaDerecha.value > 0;

      final medidas = Medidas(
        alturaCm: alturaCm.value,
        pesoKg: pesoKg.value,
        porcentajeGrasaCorporal: porcentajeGrasa.value,
        medidasEspecificasCm: tieneMedidasEspecificas
            ? MedidasEspecificas(
                cuello: cuello.value > 0 ? cuello.value : null,
                hombro: hombro.value > 0 ? hombro.value : null,
                brazoIzquierdo: brazoIzquierdo.value > 0
                    ? brazoIzquierdo.value
                    : null,
                brazoDerecho: brazoDerecho.value > 0
                    ? brazoDerecho.value
                    : null,
                antebrazoIzquierdo: antebrazoIzquierdo.value > 0
                    ? antebrazoIzquierdo.value
                    : null,
                antebrazoDerecho: antebrazoDerecho.value > 0
                    ? antebrazoDerecho.value
                    : null,
                pecho: pecho.value > 0 ? pecho.value : null,
                espalda: espalda.value > 0 ? espalda.value : null,
                cintura: cintura.value > 0 ? cintura.value : null,
                cuadricepIzquierdo: cuadricepIzquierdo.value > 0
                    ? cuadricepIzquierdo.value
                    : null,
                cuadricepDerecho: cuadricepDerecho.value > 0
                    ? cuadricepDerecho.value
                    : null,
                pantorrillaIzquierda: pantorrillaIzquierda.value > 0
                    ? pantorrillaIzquierda.value
                    : null,
                pantorrillaDerecha: pantorrillaDerecha.value > 0
                    ? pantorrillaDerecha.value
                    : null,
              )
            : null,
      );

      await _firestoreService.updateMedidas(
        uid: userId.value,
        medidas: medidas,
      );

      // 5. Reservar el username en la colección de usernames
      if (nombreCompleto.value.isNotEmpty) {
        final usernameReserved = await _friendshipService.reserveUsername(
          nombreCompleto.value.toLowerCase().trim(),
          userId.value,
        );

        if (!usernameReserved) {
          Get.snackbar(
            'Error',
            'No se pudo reservar el nombre de usuario. Por favor intenta con otro.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
          isLoading.value = false;
          return;
        }
      }

      // 6. Actualizar datos personales con ubicación
      final datosPersonales = DatosPersonales(
        nombreCompleto: nombreCompleto.value.isEmpty
            ? null
            : nombreCompleto.value,
        nombreUsuario: nombreCompleto.value.isEmpty
            ? null
            : nombreCompleto.value.toLowerCase().trim(),
        fechaNacimiento: fechaNacimiento.value?.toIso8601String(),
        bio: bioText,
        ubicacion: (pais.value.isNotEmpty || latitud.value != null)
            ? Ubicacion(
                pais: pais.value.isEmpty ? null : pais.value,
                provincia: provincia.value.isEmpty ? null : provincia.value,
                ciudad: ciudad.value.isEmpty ? null : ciudad.value,
                latitud: latitud.value,
                longitud: longitud.value,
              )
            : null,
      );
      await _firestoreService.updateDatosPersonales(
        uid: userId.value,
        datosPersonales: datosPersonales,
      );

      // 7. Marcar personalización como completada
      await _firestoreService.markPersonalizationComplete(userId.value);

      // Mostrar mensaje de éxito
      Get.snackbar(
        '¡Perfil Completado!',
        'Tu perfil ha sido configurado exitosamente',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      // Esperar un momento y navegar al home
      await Future.delayed(const Duration(seconds: 2));
      Get.offAllNamed(RoutePaths.home);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Hubo un error al guardar tu perfil: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Saltar personalización (guardar datos mínimos)
  Future<void> skipOnboarding() async {
    try {
      isLoading.value = true;

      // Marcar como completado con datos mínimos
      await _firestoreService.markPersonalizationComplete(userId.value);

      Get.offAllNamed(RoutePaths.home);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Hubo un error: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

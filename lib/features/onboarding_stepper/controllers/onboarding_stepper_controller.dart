import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/app/routes/route_paths.dart';
import 'package:tribbe_app/core/enums/app_enums.dart';
import 'package:tribbe_app/features/auth/models/user_profile_model.dart';
import 'package:tribbe_app/shared/controllers/settings_controller.dart';
import 'package:tribbe_app/shared/services/firestore_service.dart';

/// Controlador para el stepper de personalización inicial
class OnboardingStepperController extends GetxController {
  final FirestoreService _firestoreService = Get.find();
  final SettingsController _settingsController = Get.find();
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
    'Experto',
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

      case 2: // Personaje - nombre obligatorio
        if (nombreCompleto.value.trim().isEmpty) {
          Get.snackbar(
            'Campo requerido',
            'Por favor ingresa tu nombre completo',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
          return false;
        }

        // Validar que el nombre tenga al menos 2 caracteres
        if (nombreCompleto.value.trim().length < 2) {
          Get.snackbar(
            'Nombre inválido',
            'El nombre debe tener al menos 2 caracteres',
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

      // Debug: Mostrar userId
      print('🔍 DEBUG: userId = ${userId.value}');
      print('🔍 DEBUG: FirebaseAuth UID = ${_auth.currentUser?.uid}');

      // 0. Asegurar que el documento principal del usuario existe
      print('🔍 DEBUG: Verificando existencia del documento del usuario...');
      final userExists = await _firestoreService.userProfileExists(
        userId.value,
      );
      if (!userExists) {
        print('⚠️ DEBUG: Documento no existe, creándolo...');
        await _firestoreService.createUserProfile(
          uid: userId.value,
          email: _auth.currentUser!.email!,
        );
        print('✅ DEBUG: Documento creado');
      } else {
        print('✅ DEBUG: Documento ya existe');
      }

      // 1. Actualizar/Confirmar preferencias
      final preferencias = Preferencias(
        tema: tema.value,
        unidades: Unidades(medida: unidadMedida.value, peso: unidadPeso.value),
        idioma: idioma.value,
        genero: genero.value,
      );

      print('🔍 DEBUG: Actualizando preferencias...');
      await _firestoreService.updatePreferencias(
        uid: userId.value,
        preferencias: preferencias,
      );
      print('✅ DEBUG: Preferencias actualizadas');

      // 2. Guardar información fitness
      final informacion = Informacion(
        proposito: bio.value.isEmpty
            ? 'Mejorar mi condición física general'
            : bio.value,
        metaFitness: metaFitness.value,
        lesiones: lesiones.isNotEmpty ? lesiones : null,
        nivelExperiencia: nivelExperiencia.value,
        condicionFisicaActual: condicionFisicaActual.value,
      );
      print('🔍 DEBUG: Guardando información fitness...');
      await _firestoreService.updateInformacion(
        uid: userId.value,
        informacion: informacion,
      );
      print('✅ DEBUG: Información guardada');

      // 3. Guardar personaje/avatar
      final personaje = Personaje(
        genero: genero.value,
        tonoPiel: tonoPiel.value.toString(), // Guardar como "1", "2", "3"
        avatarUrl: avatarUrl.value.isEmpty ? null : avatarUrl.value,
      );
      print('🔍 DEBUG: Guardando personaje...');
      await _firestoreService.updatePersonaje(
        uid: userId.value,
        personaje: personaje,
      );
      print('✅ DEBUG: Personaje guardado');

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

      print('🔍 DEBUG: Guardando medidas...');
      await _firestoreService.updateMedidas(
        uid: userId.value,
        medidas: medidas,
      );
      print('✅ DEBUG: Medidas guardadas');

      // 5. Actualizar datos personales con ubicación
      print('🔍 DEBUG: Guardando datos personales...');
      final datosPersonales = DatosPersonales(
        nombreCompleto: nombreCompleto.value.isEmpty
            ? null
            : nombreCompleto.value,
        nombreUsuario: nombreCompleto.value.isEmpty
            ? null
            : nombreCompleto.value.split(' ')[0].toLowerCase(),
        fechaNacimiento: fechaNacimiento.value != null
            ? '${fechaNacimiento.value!.day}/${fechaNacimiento.value!.month}/${fechaNacimiento.value!.year}'
            : null,
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
      print('✅ DEBUG: Datos personales guardados');

      // 6. Marcar personalización como completada
      print('🔍 DEBUG: Marcando personalización como completada...');
      await _firestoreService.markPersonalizationComplete(userId.value);
      print('✅ DEBUG: Personalización marcada como completada');

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

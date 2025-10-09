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
  final RxString pais = 'Ecuador'.obs;
  final RxString provincia = ''.obs;
  final RxString ciudad = ''.obs;

  // Step 3: Personaje/Avatar
  final RxString nombreCompleto = ''.obs;
  final RxString tonoPiel = '#ffcc99'.obs;
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
    // Cargar preferencias ya guardadas
    _loadExistingPreferences();
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
    final gender = nuevoGenero == 'Masculino'
        ? UserGender.male
        : UserGender.female;
    await _settingsController.setGender(gender);
  }

  /// Avanzar al siguiente paso
  void nextStep() {
    if (currentStep.value < 3) {
      currentStep.value++;
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
      final informacion = Informacion(
        proposito: bio.value.isEmpty
            ? 'Mejorar mi condición física general'
            : bio.value,
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
        tonoPiel: tonoPiel.value,
        avatarUrl: avatarUrl.value.isEmpty ? null : avatarUrl.value,
      );
      await _firestoreService.updatePersonaje(
        uid: userId.value,
        personaje: personaje,
      );

      // 4. Guardar medidas
      final medidas = Medidas(
        alturaCm: alturaCm.value,
        pesoKg: pesoKg.value,
        porcentajeGrasaCorporal: porcentajeGrasa.value,
        medidasEspecificasCm: MedidasEspecificas(
          cuello: cuello.value > 0 ? cuello.value : null,
          hombro: hombro.value > 0 ? hombro.value : null,
          brazoIzquierdo: brazoIzquierdo.value > 0
              ? brazoIzquierdo.value
              : null,
          brazoDerecho: brazoDerecho.value > 0 ? brazoDerecho.value : null,
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
        ),
      );
      await _firestoreService.updateMedidas(
        uid: userId.value,
        medidas: medidas,
      );

      // 5. Actualizar datos personales con ubicación
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
        ubicacion: Ubicacion(
          pais: pais.value,
          provincia: provincia.value.isEmpty ? null : provincia.value,
          ciudad: ciudad.value.isEmpty ? null : ciudad.value,
        ),
      );
      await _firestoreService.updateDatosPersonales(
        uid: userId.value,
        datosPersonales: datosPersonales,
      );

      // 6. Marcar personalización como completada
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

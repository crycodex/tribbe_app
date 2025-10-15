import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tribbe_app/app/routes/route_paths.dart';
import 'package:tribbe_app/features/auth/controllers/auth_controller.dart';
import 'package:tribbe_app/features/auth/models/user_profile_model.dart';
import 'package:tribbe_app/features/training/models/workout_model.dart';
import 'package:tribbe_app/shared/services/firebase_auth_service.dart';
import 'package:tribbe_app/shared/services/firestore_service.dart';
import 'package:tribbe_app/shared/services/storage_service.dart';
import 'package:tribbe_app/shared/services/workout_service.dart';

/// Controlador de Perfil
class ProfileController extends GetxController {
  // Dependencias
  final FirestoreService _firestoreService = Get.find();
  final FirebaseAuthService _firebaseAuthService = Get.find();
  final AuthController _authController = Get.find();
  final StorageService _storageService = Get.find();
  final WorkoutService _workoutService = Get.find();
  final ImagePicker _imagePicker = ImagePicker();

  // Observables
  final RxBool isLoading = false.obs;
  final RxBool isUploadingImage = false.obs;
  final RxBool isLoadingWorkouts = false.obs;
  final RxBool isLoadingMoreWorkouts = false.obs;
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxString photoUrl = ''.obs;
  final RxList<WorkoutModel> userWorkouts = <WorkoutModel>[].obs;

  // Paginación de entrenamientos
  final RxInt currentPage = 0.obs;
  final RxInt workoutsPerPage = 5.obs;
  final RxBool hasMoreWorkouts = true.obs;

  // Controladores de texto para campos del formulario
  late final TextEditingController nombreCompletoController;
  late final TextEditingController nombreUsuarioController;
  late final TextEditingController bioController;
  late final TextEditingController alturaController;
  late final TextEditingController pesoController;
  late final TextEditingController porcentajeGrasaController;

  // Form fields - Datos Personales
  final RxString nombreCompleto = ''.obs;
  final RxString nombreUsuario = ''.obs;
  final Rx<DateTime?> fechaNacimiento = Rx<DateTime?>(null);
  final RxString bio = ''.obs;

  // Form fields - Ubicación
  final RxString pais = ''.obs;
  final RxString provincia = ''.obs;
  final RxString ciudad = ''.obs;
  final Rx<double?> latitud = Rx<double?>(null);
  final Rx<double?> longitud = Rx<double?>(null);

  // Form fields - Información Fitness
  final RxString metaFitness = 'Aumentar músculo'.obs;
  final RxList<String> lesiones = <String>[].obs;
  final RxString nivelExperiencia = 'Principiante'.obs;

  // Form fields - Medidas
  final RxString altura = ''.obs;
  final RxString peso = ''.obs;
  final RxString porcentajeGrasa = ''.obs;

  // Listas de opciones
  final List<String> metasFitness = [
    'Perder peso',
    'Aumentar músculo',
    'Mantener forma',
    'Mejorar resistencia',
    'Rehabilitación',
  ];

  final List<String> lesionesList = [
    'Ninguna',
    'Rodilla',
    'Espalda baja',
    'Hombro',
    'Muñeca',
    'Tobillo',
    'Otra',
  ];

  final List<String> nivelesExperiencia = [
    'Principiante',
    'Intermedio',
    'Avanzado',
    'Experto',
  ];

  @override
  void onInit() {
    super.onInit();
    // Inicializar controladores de texto
    nombreCompletoController = TextEditingController();
    nombreUsuarioController = TextEditingController();
    bioController = TextEditingController();
    alturaController = TextEditingController();
    pesoController = TextEditingController();
    porcentajeGrasaController = TextEditingController();

    // Cargar perfil con delay para asegurar que AuthController esté listo
    Future.delayed(const Duration(milliseconds: 100), () {
      _loadUserProfile();
      loadUserWorkouts();
    });
  }

  @override
  void onClose() {
    nombreCompletoController.dispose();
    nombreUsuarioController.dispose();
    bioController.dispose();
    alturaController.dispose();
    pesoController.dispose();
    porcentajeGrasaController.dispose();
    super.onClose();
  }

  /// Cargar perfil del usuario actual
  void _loadUserProfile() {
    debugPrint('🔍 ProfileController: Iniciando _loadUserProfile');
    debugPrint(
      '🔍 AuthController.userProfile.value: ${_authController.userProfile.value}',
    );
    debugPrint(
      '🔍 AuthController.isAuthenticated.value: ${_authController.isAuthenticated.value}',
    );
    debugPrint(
      '🔍 AuthController.firebaseUser.value: ${_authController.firebaseUser.value?.uid}',
    );

    final profile = _authController.userProfile.value;
    if (profile != null) {
      debugPrint('📊 ProfileController: Perfil encontrado, cargando datos...');
      debugPrint('📊 ProfileController: Datos del perfil:');
      debugPrint('  - uid: ${profile.uid}');
      debugPrint('  - email: ${profile.email}');
      debugPrint('  - datosPersonales: ${profile.datosPersonales?.toJson()}');
      debugPrint('  - informacion: ${profile.informacion?.toJson()}');
      debugPrint('  - medidas: ${profile.medidas?.toJson()}');
      debugPrint('  - personaje: ${profile.personaje?.toJson()}');

      // Datos personales
      nombreCompleto.value = profile.datosPersonales?.nombreCompleto ?? '';
      nombreUsuario.value = profile.datosPersonales?.nombreUsuario ?? '';
      bio.value = profile.datosPersonales?.bio ?? '';

      nombreCompletoController.text = nombreCompleto.value;
      nombreUsuarioController.text = nombreUsuario.value;
      bioController.text = bio.value;

      // Fecha de nacimiento - manejar formato de fecha
      if (profile.datosPersonales?.fechaNacimiento != null &&
          profile.datosPersonales!.fechaNacimiento!.isNotEmpty) {
        // Intentar parsear como ISO8601 primero
        DateTime? parsedDate = DateTime.tryParse(
          profile.datosPersonales!.fechaNacimiento!,
        );

        // Si no funciona, intentar como DD/MM/YYYY
        if (parsedDate == null) {
          final parts = profile.datosPersonales!.fechaNacimiento!.split('/');
          if (parts.length == 3) {
            final day = int.tryParse(parts[0]);
            final month = int.tryParse(parts[1]);
            final year = int.tryParse(parts[2]);
            if (day != null && month != null && year != null) {
              parsedDate = DateTime(year, month, day);
            }
          }
        }

        fechaNacimiento.value = parsedDate;
      }

      // Ubicación
      pais.value = profile.datosPersonales?.ubicacion?.pais ?? '';
      provincia.value = profile.datosPersonales?.ubicacion?.provincia ?? '';
      ciudad.value = profile.datosPersonales?.ubicacion?.ciudad ?? '';
      latitud.value = profile.datosPersonales?.ubicacion?.latitud;
      longitud.value = profile.datosPersonales?.ubicacion?.longitud;

      // Información fitness
      metaFitness.value =
          profile.informacion?.metaFitness ?? 'Aumentar músculo';
      lesiones.value = profile.informacion?.lesiones ?? [];
      nivelExperiencia.value =
          profile.informacion?.nivelExperiencia ?? 'Principiante';

      // Medidas
      altura.value = profile.medidas?.alturaCm?.toString() ?? '';
      peso.value = profile.medidas?.pesoKg?.toString() ?? '';
      porcentajeGrasa.value =
          profile.medidas?.porcentajeGrasaCorporal?.toString() ?? '';

      alturaController.text = altura.value;
      pesoController.text = peso.value;
      porcentajeGrasaController.text = porcentajeGrasa.value;

      // Foto de perfil
      photoUrl.value = profile.personaje?.avatarUrl ?? '';

      debugPrint('📊 ProfileController: Datos cargados:');
      debugPrint('  - Nombre: ${nombreCompleto.value}');
      debugPrint('  - Usuario: ${nombreUsuario.value}');
      debugPrint('  - Bio: ${bio.value}');
      debugPrint('  - Meta Fitness: ${metaFitness.value}');
      debugPrint('  - Nivel: ${nivelExperiencia.value}');
      debugPrint('  - Lesiones: ${lesiones}');
      debugPrint('  - Altura: ${altura.value}');
      debugPrint('  - Peso: ${peso.value}');
      debugPrint('  - Foto: ${photoUrl.value}');
    } else {
      debugPrint(
        '📭 ProfileController: userProfile en AuthController es nulo.',
      );
      // Limpiar y resetear controladores si el perfil es nulo
      nombreCompletoController.clear();
      nombreUsuarioController.clear();
      bioController.clear();
      alturaController.clear();
      pesoController.clear();
      porcentajeGrasaController.clear();
    }
  }

  /// Forzar recarga del perfil desde Firestore
  Future<void> reloadUserProfile() async {
    try {
      debugPrint('🔄 ProfileController: Recargando perfil desde Firestore...');

      final userId = _firebaseAuthService.currentUser?.uid;
      if (userId == null) {
        debugPrint('❌ ProfileController: Usuario no autenticado');
        return;
      }

      // Recargar perfil desde Firestore
      final profile = await _firestoreService.getUserProfile(userId);
      _authController.userProfile.value = profile;

      debugPrint('✅ ProfileController: Perfil recargado desde Firestore');

      // Verificar si los datos personales están vacíos y migrar si es necesario
      if (profile != null &&
          (profile.datosPersonales?.nombreCompleto == null ||
              profile.datosPersonales?.nombreCompleto?.isEmpty == true)) {
        debugPrint(
          '🔄 ProfileController: Datos personales vacíos, iniciando migración...',
        );
        await migratePersonalDataToMainDocument();
      } else {
        // Cargar datos en el ProfileController
        _loadUserProfile();
      }
    } catch (e) {
      debugPrint('❌ ProfileController: Error al recargar perfil: $e');
    }
  }

  /// Migrar datos personales desde subcolecciones al documento principal
  Future<void> migratePersonalDataToMainDocument() async {
    try {
      debugPrint(
        '🔄 ProfileController: Migrando datos personales al documento principal...',
      );

      final userId = _firebaseAuthService.currentUser?.uid;
      if (userId == null) {
        debugPrint('❌ ProfileController: Usuario no autenticado');
        return;
      }

      // Obtener el perfil completo que ya incluye las subcolecciones
      final profile = await _firestoreService.getUserProfile(userId);
      if (profile == null) {
        debugPrint('❌ ProfileController: No se pudo obtener el perfil');
        return;
      }

      // Crear datos personales con información básica
      final bioText =
          profile.informacion?.proposito ??
          'Mejorar mi condición física general';

      final datosPersonales = DatosPersonales(
        nombreCompleto: 'Usuario', // Valor por defecto
        nombreUsuario: 'usuario', // Valor por defecto
        fechaNacimiento: null, // Se puede completar después
        bio: bioText, // Usar proposito como bio o valor por defecto
        ubicacion: null, // Se puede completar después
      );

      // Actualizar el documento principal
      await _firestoreService.updateDatosPersonales(
        uid: userId,
        datosPersonales: datosPersonales,
      );

      debugPrint(
        '✅ ProfileController: Datos personales migrados al documento principal',
      );

      // Recargar perfil
      await reloadUserProfile();
    } catch (e) {
      debugPrint('❌ ProfileController: Error al migrar datos personales: $e');
    }
  }

  /// Cargar historial de entrenamientos del usuario (inicial)
  Future<void> loadUserWorkouts() async {
    try {
      isLoadingWorkouts.value = true;
      currentPage.value = 0;
      userWorkouts.clear();

      // Usar FirebaseAuthService directamente para obtener el usuario actual
      final currentUser = _firebaseAuthService.currentUser;
      final userId = currentUser?.uid;

      if (userId == null) {
        debugPrint(
          '❌ ProfileController: userId es null - Usuario no autenticado',
        );
        return;
      }

      final workouts = await _workoutService.getUserWorkouts(userId);

      if (workouts.isNotEmpty) {
        debugPrint(
          '📊 ProfileController: Datos: ${workouts.map((w) => w.focus).toList()}',
        );
      } else {
        debugPrint('📭 ProfileController: No hay entrenamientos');
      }

      // Cargar solo la primera página
      final firstPage = workouts.take(workoutsPerPage.value).toList();
      userWorkouts.value = firstPage;
      hasMoreWorkouts.value = workouts.length > workoutsPerPage.value;
    } catch (e) {
      debugPrint('❌ Error al cargar entrenamientos: $e');
      Get.snackbar(
        'Error',
        'No se pudo cargar el historial de entrenamientos: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingWorkouts.value = false;
    }
  }

  /// Cargar más entrenamientos (paginación)
  Future<void> loadMoreWorkouts() async {
    if (isLoadingMoreWorkouts.value || !hasMoreWorkouts.value) {
      return;
    }

    try {
      isLoadingMoreWorkouts.value = true;

      final currentUser = _firebaseAuthService.currentUser;
      final userId = currentUser?.uid;

      if (userId == null) {
        return;
      }

      final allWorkouts = await _workoutService.getUserWorkouts(userId);
      final nextPage = currentPage.value + 1;
      final startIndex = nextPage * workoutsPerPage.value;
      final endIndex = startIndex + workoutsPerPage.value;

      if (startIndex < allWorkouts.length) {
        final moreWorkouts = allWorkouts
            .skip(startIndex)
            .take(workoutsPerPage.value)
            .toList();

        userWorkouts.addAll(moreWorkouts);
        currentPage.value = nextPage;
        hasMoreWorkouts.value = endIndex < allWorkouts.length;
      } else {
        hasMoreWorkouts.value = false;
      }
    } catch (e) {
      debugPrint('❌ Error al cargar más entrenamientos: $e');
    } finally {
      isLoadingMoreWorkouts.value = false;
    }
  }

  /// Refrescar entrenamientos
  Future<void> refreshWorkouts() async {
    await loadUserWorkouts();
  }

  /// Estadísticas rápidas de entrenamientos
  int get totalWorkouts => userWorkouts.length;

  double get totalVolume {
    return userWorkouts.fold(0.0, (sum, workout) => sum + workout.totalVolume);
  }

  int get totalDuration {
    return userWorkouts.fold(0, (sum, workout) => sum + workout.duration);
  }

  Map<String, int> get workoutsByFocus {
    final Map<String, int> focusMap = {};
    for (final workout in userWorkouts) {
      focusMap[workout.focus] = (focusMap[workout.focus] ?? 0) + 1;
    }
    return focusMap;
  }

  /// Seleccionar imagen desde la galería
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al seleccionar imagen: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Tomar foto con la cámara
  Future<void> takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al tomar foto: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Subir imagen a Firebase Storage
  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      isUploadingImage.value = true;

      final userId = _firebaseAuthService.currentUser?.uid;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Estructura: users/{uid}/profile/profile_image.jpg
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('users')
          .child(userId)
          .child('profile')
          .child('profile_image.jpg');

      final uploadTask = await storageRef.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      photoUrl.value = downloadUrl;
      return downloadUrl;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al subir imagen: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    } finally {
      isUploadingImage.value = false;
    }
  }

  /// Eliminar foto de perfil de Storage y Firestore
  Future<void> deleteProfileImage() async {
    try {
      isLoading.value = true;

      final userId = _firebaseAuthService.currentUser?.uid;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Eliminar de Firebase Storage
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('users')
            .child(userId)
            .child('profile')
            .child('profile_image.jpg');

        await storageRef.delete();
      } catch (e) {
        // Si no existe la imagen en Storage, continuar
        debugPrint('No se encontró imagen en Storage o ya fue eliminada: $e');
      }

      // Eliminar de Firestore (actualizar personaje con avatarUrl vacío)
      final personaje = Personaje(avatarUrl: null);
      await _firestoreService.updatePersonaje(
        uid: userId,
        personaje: personaje,
      );

      // Limpiar estado local
      selectedImage.value = null;
      photoUrl.value = '';

      // Recargar perfil en AuthController
      _authController.userProfile.value = await _firestoreService
          .getUserProfile(userId);

      Get.snackbar(
        '¡Foto eliminada!',
        'Tu foto de perfil ha sido eliminada correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al eliminar foto: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Mostrar opciones de imagen
  void showImagePickerOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? Colors.grey.shade900 : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Seleccionar foto de perfil',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () {
                Get.back();
                pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Cámara'),
              onTap: () {
                Get.back();
                takePhoto();
              },
            ),
            if (photoUrl.value.isNotEmpty || selectedImage.value != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Eliminar foto',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Get.back();
                  _showDeleteConfirmationDialog();
                },
              ),
          ],
        ),
      ),
    );
  }

  /// Mostrar diálogo de confirmación para eliminar foto
  void _showDeleteConfirmationDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Eliminar foto de perfil'),
        content: const Text(
          '¿Estás seguro que deseas eliminar tu foto de perfil?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              deleteProfileImage();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  /// Alternar lesión
  void toggleLesion(String lesion) {
    if (lesion == 'Ninguna') {
      lesiones.clear();
      lesiones.add('Ninguna');
    } else {
      lesiones.remove('Ninguna');
      if (lesiones.contains(lesion)) {
        lesiones.remove(lesion);
      } else {
        lesiones.add(lesion);
      }
    }
  }

  /// Guardar cambios en el perfil
  Future<void> saveProfile() async {
    try {
      isLoading.value = true;

      final userId = _firebaseAuthService.currentUser?.uid;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Subir imagen si hay una seleccionada
      String? imageUrl = photoUrl.value;
      if (selectedImage.value != null) {
        imageUrl = await uploadProfileImage(selectedImage.value!);
        if (imageUrl == null) {
          throw Exception('Error al subir la imagen');
        }
      }

      // Preparar datos para actualizar
      final datosPersonales = DatosPersonales(
        nombreCompleto: nombreCompleto.value.isNotEmpty
            ? nombreCompleto.value
            : null,
        nombreUsuario: nombreUsuario.value.isNotEmpty
            ? nombreUsuario.value
            : null,
        fechaNacimiento: fechaNacimiento.value?.toIso8601String(),
        bio: bio.value.isNotEmpty ? bio.value : null,
        ubicacion: (pais.value.isNotEmpty || ciudad.value.isNotEmpty)
            ? Ubicacion(
                pais: pais.value.isNotEmpty ? pais.value : null,
                provincia: provincia.value.isNotEmpty ? provincia.value : null,
                ciudad: ciudad.value.isNotEmpty ? ciudad.value : null,
                latitud: latitud.value,
                longitud: longitud.value,
              )
            : null,
      );

      final informacion = Informacion(
        metaFitness: metaFitness.value,
        lesiones: lesiones.isNotEmpty ? lesiones : null,
        nivelExperiencia: nivelExperiencia.value,
      );

      final medidas = (altura.value.isNotEmpty || peso.value.isNotEmpty)
          ? Medidas(
              alturaCm: altura.value.isNotEmpty
                  ? double.tryParse(altura.value)
                  : null,
              pesoKg: peso.value.isNotEmpty
                  ? double.tryParse(peso.value)
                  : null,
              porcentajeGrasaCorporal: porcentajeGrasa.value.isNotEmpty
                  ? double.tryParse(porcentajeGrasa.value)
                  : null,
            )
          : null;

      // Preservar datos existentes del personaje y solo actualizar avatarUrl si es necesario
      Personaje? personaje;
      if (imageUrl.isNotEmpty) {
        // Si hay una nueva imagen, actualizar el personaje preservando datos existentes
        final existingPersonaje = _authController.userProfile.value?.personaje;
        personaje = Personaje(
          genero: existingPersonaje?.genero,
          tonoPiel: existingPersonaje?.tonoPiel,
          avatarUrl: imageUrl,
        );
      }

      // Actualizar en Firestore - Usar los métodos individuales
      await _firestoreService.updateDatosPersonales(
        uid: userId,
        datosPersonales: datosPersonales,
      );

      await _firestoreService.updateInformacion(
        uid: userId,
        informacion: informacion,
      );

      if (medidas != null) {
        await _firestoreService.updateMedidas(uid: userId, medidas: medidas);
      }

      if (personaje != null) {
        await _firestoreService.updatePersonaje(
          uid: userId,
          personaje: personaje,
        );
      }

      // Recargar perfil en AuthController
      _authController.userProfile.value = await _firestoreService
          .getUserProfile(userId);

      Get.back(); // Cerrar página de edición

      Get.snackbar(
        '¡Perfil actualizado!',
        'Tus cambios se guardaron correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al guardar perfil: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Eliminar cuenta del usuario (Auth, Storage, Firestore)
  Future<void> deleteUserAccount() async {
    try {
      isLoading.value = true;

      final user = _firebaseAuthService.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final userId = user.uid;

      // 1. Eliminar archivos de Firebase Storage (foto de perfil)
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('users')
            .child(userId);

        // Eliminar toda la carpeta del usuario
        final listResult = await storageRef.listAll();
        for (final item in listResult.items) {
          await item.delete();
        }
      } catch (e) {
        debugPrint('Error al eliminar archivos de Storage: $e');
        // Continuar aunque falle (puede que no haya archivos)
      }

      // 2. Eliminar datos de Firestore (perfil y subcolecciones)
      await _firestoreService.deleteUserProfile(userId);

      // 3. Limpiar datos locales (SharedPreferences)
      await _storageService.clearAll();

      // 4. Eliminar cuenta de Firebase Auth
      await user.delete();

      // 5. Limpiar estado del AuthController
      _authController.firebaseUser.value = null;
      _authController.userProfile.value = null;
      _authController.isAuthenticated.value = false;

      // 6. Mostrar mensaje de confirmación
      Get.snackbar(
        'Cuenta eliminada',
        'Tu cuenta ha sido eliminada permanentemente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // 7. Navegar a la página de bienvenida
      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed(RoutePaths.welcome);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al eliminar cuenta: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Mostrar diálogo de confirmación para eliminar cuenta
  void showDeleteAccountDialog() {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Eliminar Cuenta'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Estás seguro que deseas eliminar tu cuenta?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Esta acción es irreversible y eliminará:',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 8),
            Text(
              '• Toda tu información personal',
              style: TextStyle(fontSize: 14),
            ),
            Text('• Tus fotos y archivos', style: TextStyle(fontSize: 14)),
            Text(
              '• Tus entrenamientos y estadísticas',
              style: TextStyle(fontSize: 14),
            ),
            Text(
              '• Tu cuenta de autenticación',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            Text(
              'No podrás recuperar esta información.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              deleteUserAccount();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar Cuenta'),
          ),
        ],
      ),
    );
  }
}

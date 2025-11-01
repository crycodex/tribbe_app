import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

/// Servicio para manejar Firebase Storage - subida de imágenes
class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  /// Subir foto de entrenamiento
  /// Guarda en: users/{userId}/workouts/{workoutId}.jpg
  Future<String> uploadWorkoutPhoto({
    required String userId,
    required String workoutId,
    required File imageFile,
  }) async {
    try {
      final fileName = '$workoutId.jpg';
      final ref = _storage.ref().child('users/$userId/workouts/$fileName');

      // Subir archivo
      final uploadTask = await ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'userId': userId,
            'workoutId': workoutId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Obtener URL de descarga
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Error al subir foto de entrenamiento: ${e.toString()}');
    }
  }

  /// Subir foto de perfil
  /// Guarda en: users/{userId}/profile/avatar.jpg
  Future<String> uploadProfilePhoto({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final fileName = 'avatar.jpg';
      final ref = _storage.ref().child('users/$userId/profile/$fileName');

      final uploadTask = await ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'userId': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Error al subir foto de perfil: ${e.toString()}');
    }
  }

  /// Tomar foto con la cámara
  Future<File?> takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 80, // Comprimir al 80% para reducir tamaño
        maxWidth: 1080, // Máximo 1080px de ancho
      );

      if (photo == null) return null;

      return File(photo.path);
    } catch (e) {
      throw Exception('Error al tomar foto: ${e.toString()}');
    }
  }

  /// Seleccionar foto de la galería
  Future<File?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1080,
      );

      if (image == null) return null;

      return File(image.path);
    } catch (e) {
      throw Exception('Error al seleccionar foto: ${e.toString()}');
    }
  }

  /// Eliminar foto de entrenamiento
  Future<void> deleteWorkoutPhoto({
    required String userId,
    required String workoutId,
  }) async {
    try {
      final fileName = '$workoutId.jpg';
      final ref = _storage.ref().child('users/$userId/workouts/$fileName');
      await ref.delete();
    } catch (e) {
      // No lanzar error si la foto no existe
      if (!e.toString().contains('object-not-found')) {
        throw Exception('Error al eliminar foto: ${e.toString()}');
      }
    }
  }

  /// Eliminar foto de perfil
  Future<void> deleteProfilePhoto(String userId) async {
    try {
      final fileName = 'avatar.jpg';
      final ref = _storage.ref().child('users/$userId/profile/$fileName');
      await ref.delete();
    } catch (e) {
      if (!e.toString().contains('object-not-found')) {
        throw Exception('Error al eliminar foto de perfil: ${e.toString()}');
      }
    }
  }

  /// Obtener URL de foto de entrenamiento (si existe)
  Future<String?> getWorkoutPhotoUrl({
    required String userId,
    required String workoutId,
  }) async {
    try {
      final fileName = '$workoutId.jpg';
      final ref = _storage.ref().child('users/$userId/workouts/$fileName');
      return await ref.getDownloadURL();
    } catch (e) {
      // Retornar null si no existe
      return null;
    }
  }
}


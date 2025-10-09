import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tribbe_app/features/auth/models/user_profile_model.dart';

/// Servicio para manejar Firestore
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Colecciones principales
  static const String usersCollection = 'users';

  /// Subcolecciones
  static const String preferenciasCollection = 'preferencias';
  static const String informacionCollection = 'informacion';
  static const String personajeCollection = 'personaje';
  static const String medidasCollection = 'medidas';

  /// Crear perfil inicial del usuario con preferencias por defecto
  Future<void> createUserProfile({
    required String uid,
    required String email,
    String? nombreUsuario,
  }) async {
    try {
      final now = DateTime.now();

      // 1. Crear documento principal con datos básicos y datos_personales
      final mainData = {
        'uid': uid,
        'email': email,
        'has_completed_personalization': false,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
        'datos_personales': {'nombre_usuario': nombreUsuario},
      };

      await _firestore.collection(usersCollection).doc(uid).set(mainData);

      // 2. Crear subcolección de preferencias con valores por defecto
      final preferenciasDefault = Preferencias(
        tema: 'Día', // Por defecto del welcome page
        unidades: Unidades(medida: 'cm', peso: 'kg'),
        idioma: 'Español', // Por defecto del welcome page
        genero: 'Masculino', // Por defecto del welcome page
      );

      await _firestore
          .collection(usersCollection)
          .doc(uid)
          .collection(preferenciasCollection)
          .doc('current')
          .set(preferenciasDefault.toJson());

      // 3. Las demás subcolecciones se crearán cuando el usuario las complete
      // (informacion, personaje, medidas)
    } catch (e) {
      throw Exception('Error al crear perfil de usuario: ${e.toString()}');
    }
  }

  /// Obtener perfil del usuario (documento principal + subcolecciones)
  Future<UserProfileModel?> getUserProfile(String uid) async {
    try {
      // Obtener documento principal
      final doc = await _firestore.collection(usersCollection).doc(uid).get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data()!;

      // Obtener subcolecciones
      final preferencias = await _getPreferencias(uid);
      final informacion = await _getInformacion(uid);
      final personaje = await _getPersonaje(uid);
      final medidas = await _getMedidas(uid);

      // Combinar datos del documento principal con las subcolecciones
      final completeData = {
        ...data,
        if (preferencias != null) 'preferencias': preferencias.toJson(),
        if (informacion != null) 'informacion': informacion.toJson(),
        if (personaje != null) 'personaje': personaje.toJson(),
        if (medidas != null) 'medidas': medidas.toJson(),
      };

      return UserProfileModel.fromJson(completeData);
    } catch (e) {
      throw Exception('Error al obtener perfil de usuario: ${e.toString()}');
    }
  }

  /// Obtener preferencias del usuario
  Future<Preferencias?> _getPreferencias(String uid) async {
    try {
      final doc = await _firestore
          .collection(usersCollection)
          .doc(uid)
          .collection(preferenciasCollection)
          .doc('current')
          .get();

      if (!doc.exists) return null;
      return Preferencias.fromJson(doc.data()!);
    } catch (e) {
      return null;
    }
  }

  /// Obtener información fitness del usuario
  Future<Informacion?> _getInformacion(String uid) async {
    try {
      final doc = await _firestore
          .collection(usersCollection)
          .doc(uid)
          .collection(informacionCollection)
          .doc('current')
          .get();

      if (!doc.exists) return null;
      return Informacion.fromJson(doc.data()!);
    } catch (e) {
      return null;
    }
  }

  /// Obtener personaje/avatar del usuario
  Future<Personaje?> _getPersonaje(String uid) async {
    try {
      final doc = await _firestore
          .collection(usersCollection)
          .doc(uid)
          .collection(personajeCollection)
          .doc('current')
          .get();

      if (!doc.exists) return null;
      return Personaje.fromJson(doc.data()!);
    } catch (e) {
      return null;
    }
  }

  /// Obtener medidas del usuario
  Future<Medidas?> _getMedidas(String uid) async {
    try {
      final doc = await _firestore
          .collection(usersCollection)
          .doc(uid)
          .collection(medidasCollection)
          .doc('current')
          .get();

      if (!doc.exists) return null;
      return Medidas.fromJson(doc.data()!);
    } catch (e) {
      return null;
    }
  }

  /// Actualizar perfil del usuario
  Future<void> updateUserProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      data['updated_at'] = DateTime.now().toIso8601String();

      await _firestore.collection(usersCollection).doc(uid).update(data);
    } catch (e) {
      throw Exception('Error al actualizar perfil de usuario: ${e.toString()}');
    }
  }

  /// Marcar personalización como completada
  Future<void> markPersonalizationComplete(String uid) async {
    try {
      await updateUserProfile(
        uid: uid,
        data: {'has_completed_personalization': true},
      );
    } catch (e) {
      throw Exception(
        'Error al marcar personalización completa: ${e.toString()}',
      );
    }
  }

  /// Actualizar datos personales
  Future<void> updateDatosPersonales({
    required String uid,
    required DatosPersonales datosPersonales,
  }) async {
    try {
      await updateUserProfile(
        uid: uid,
        data: {'datos_personales': datosPersonales.toJson()},
      );
    } catch (e) {
      throw Exception('Error al actualizar datos personales: ${e.toString()}');
    }
  }

  /// Actualizar preferencias (en subcolección)
  Future<void> updatePreferencias({
    required String uid,
    required Preferencias preferencias,
  }) async {
    try {
      await _firestore
          .collection(usersCollection)
          .doc(uid)
          .collection(preferenciasCollection)
          .doc('current')
          .set(preferencias.toJson(), SetOptions(merge: true));

      // Actualizar timestamp del documento principal
      await _updateMainDocumentTimestamp(uid);
    } catch (e) {
      throw Exception('Error al actualizar preferencias: ${e.toString()}');
    }
  }

  /// Actualizar información fitness (en subcolección)
  Future<void> updateInformacion({
    required String uid,
    required Informacion informacion,
  }) async {
    try {
      await _firestore
          .collection(usersCollection)
          .doc(uid)
          .collection(informacionCollection)
          .doc('current')
          .set(informacion.toJson(), SetOptions(merge: true));

      // Actualizar timestamp del documento principal
      await _updateMainDocumentTimestamp(uid);
    } catch (e) {
      throw Exception('Error al actualizar información: ${e.toString()}');
    }
  }

  /// Actualizar personaje/avatar (en subcolección)
  Future<void> updatePersonaje({
    required String uid,
    required Personaje personaje,
  }) async {
    try {
      await _firestore
          .collection(usersCollection)
          .doc(uid)
          .collection(personajeCollection)
          .doc('current')
          .set(personaje.toJson(), SetOptions(merge: true));

      // Actualizar timestamp del documento principal
      await _updateMainDocumentTimestamp(uid);
    } catch (e) {
      throw Exception('Error al actualizar personaje: ${e.toString()}');
    }
  }

  /// Actualizar medidas (en subcolección)
  Future<void> updateMedidas({
    required String uid,
    required Medidas medidas,
  }) async {
    try {
      await _firestore
          .collection(usersCollection)
          .doc(uid)
          .collection(medidasCollection)
          .doc('current')
          .set(medidas.toJson(), SetOptions(merge: true));

      // Actualizar timestamp del documento principal
      await _updateMainDocumentTimestamp(uid);
    } catch (e) {
      throw Exception('Error al actualizar medidas: ${e.toString()}');
    }
  }

  /// Actualizar timestamp del documento principal
  Future<void> _updateMainDocumentTimestamp(String uid) async {
    await _firestore.collection(usersCollection).doc(uid).update({
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  /// Eliminar perfil del usuario
  Future<void> deleteUserProfile(String uid) async {
    try {
      await _firestore.collection(usersCollection).doc(uid).delete();
    } catch (e) {
      throw Exception('Error al eliminar perfil de usuario: ${e.toString()}');
    }
  }

  /// Verificar si existe el perfil del usuario
  Future<bool> userProfileExists(String uid) async {
    try {
      final doc = await _firestore.collection(usersCollection).doc(uid).get();
      return doc.exists;
    } catch (e) {
      throw Exception(
        'Error al verificar existencia de perfil: ${e.toString()}',
      );
    }
  }

  /// Stream del perfil del usuario (documento principal + subcolecciones)
  Stream<UserProfileModel?> getUserProfileStream(String uid) {
    return _firestore.collection(usersCollection).doc(uid).snapshots().asyncMap(
      (snapshot) async {
        if (!snapshot.exists) {
          return null;
        }

        final data = snapshot.data()!;

        // Obtener subcolecciones
        final preferencias = await _getPreferencias(uid);
        final informacion = await _getInformacion(uid);
        final personaje = await _getPersonaje(uid);
        final medidas = await _getMedidas(uid);

        // Combinar datos
        final completeData = {
          ...data,
          if (preferencias != null) 'preferencias': preferencias.toJson(),
          if (informacion != null) 'informacion': informacion.toJson(),
          if (personaje != null) 'personaje': personaje.toJson(),
          if (medidas != null) 'medidas': medidas.toJson(),
        };

        return UserProfileModel.fromJson(completeData);
      },
    );
  }

  /// Sincronizar preferencias de SharedPreferences a Firebase
  Future<void> syncPreferenciasFromLocal({
    required String uid,
    required String tema,
    required String idioma,
    required String genero,
  }) async {
    try {
      final preferencias = Preferencias(
        tema: tema,
        unidades: Unidades(medida: 'cm', peso: 'kg'),
        idioma: idioma,
        genero: genero,
      );

      await updatePreferencias(uid: uid, preferencias: preferencias);
    } catch (e) {
      throw Exception('Error al sincronizar preferencias: ${e.toString()}');
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tribbe_app/features/training/models/workout_model.dart';
import 'package:tribbe_app/features/training/models/workout_post_model.dart';

/// Servicio para manejar entrenamientos y posts en Firestore
class WorkoutService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Colecciones principales
  static const String workoutPostsCollection = 'workout_posts';
  static const String usersCollection = 'users';
  static const String workoutsSubcollection = 'workouts';

  /// Crear un entrenamiento (guardado en users/{uid}/workouts)
  Future<WorkoutModel> createWorkout({
    required String userId,
    required String userName,
    required String focus,
    required int duration,
    required List<ExerciseModel> exercises,
  }) async {
    try {
      // Guardar en la subcolección del usuario: users/{userId}/workouts/{workoutId}
      final docRef = _firestore
          .collection(usersCollection)
          .doc(userId)
          .collection(workoutsSubcollection)
          .doc();

      final workout = WorkoutModel(
        id: docRef.id,
        userId: userId,
        userName: userName,
        focus: focus,
        duration: duration,
        exercises: exercises,
        createdAt: DateTime.now(),
      );

      await docRef.set(workout.toJson());
      return workout;
    } catch (e) {
      throw Exception('Error al crear entrenamiento: ${e.toString()}');
    }
  }

  /// Crear un post de entrenamiento
  Future<WorkoutPostModel> createWorkoutPost({
    required WorkoutModel workout,
    required String userName,
    String? userPhotoUrl,
    String? caption,
  }) async {
    try {
      final docRef = _firestore.collection(workoutPostsCollection).doc();
      final post = WorkoutPostModel(
        id: docRef.id,
        userId: workout.userId,
        userName: userName,
        userPhotoUrl: userPhotoUrl,
        workout: workout,
        caption: caption,
        createdAt: DateTime.now(),
      );

      await docRef.set(post.toJson());
      return post;
    } catch (e) {
      throw Exception('Error al crear post de entrenamiento: ${e.toString()}');
    }
  }

  /// Obtener entrenamientos del usuario (desde users/{uid}/workouts)
  Future<List<WorkoutModel>> getUserWorkouts(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(usersCollection)
          .doc(userId)
          .collection(workoutsSubcollection)
          .orderBy('created_at', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => WorkoutModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception(
        'Error al obtener entrenamientos del usuario: ${e.toString()}',
      );
    }
  }

  /// Stream de entrenamientos del usuario en tiempo real
  Stream<List<WorkoutModel>> getUserWorkoutsStream(String userId) {
    return _firestore
        .collection(usersCollection)
        .doc(userId)
        .collection(workoutsSubcollection)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => WorkoutModel.fromJson(doc.data()))
              .toList(),
        );
  }

  /// Obtener feed de posts de entrenamientos de amigos
  /// Por ahora obtiene todos los posts, más adelante filtraremos por amigos
  Future<List<WorkoutPostModel>> getFeedPosts({
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firestore
          .collection(workoutPostsCollection)
          .orderBy('created_at', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map(
            (doc) =>
                WorkoutPostModel.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw Exception('Error al obtener feed de posts: ${e.toString()}');
    }
  }

  /// Obtener posts del usuario
  Future<List<WorkoutPostModel>> getUserPosts(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(workoutPostsCollection)
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => WorkoutPostModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener posts del usuario: ${e.toString()}');
    }
  }

  /// Stream de feed de posts
  Stream<List<WorkoutPostModel>> getFeedPostsStream({int limit = 20}) {
    return _firestore
        .collection(workoutPostsCollection)
        .orderBy('created_at', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => WorkoutPostModel.fromJson(doc.data()))
              .toList(),
        );
  }

  /// Dar/quitar like a un post
  Future<void> toggleLike({
    required String postId,
    required String userId,
  }) async {
    try {
      final docRef = _firestore.collection(workoutPostsCollection).doc(postId);
      final doc = await docRef.get();

      if (!doc.exists) {
        throw Exception('Post no encontrado');
      }

      final post = WorkoutPostModel.fromJson(doc.data()!);
      final updatedPost = post.toggleLike(userId);

      await docRef.update({'likes': updatedPost.likes});
    } catch (e) {
      throw Exception('Error al dar like: ${e.toString()}');
    }
  }

  /// Obtener un entrenamiento por ID (requiere userId)
  Future<WorkoutModel?> getWorkoutById(String userId, String workoutId) async {
    try {
      final doc = await _firestore
          .collection(usersCollection)
          .doc(userId)
          .collection(workoutsSubcollection)
          .doc(workoutId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return WorkoutModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Error al obtener entrenamiento: ${e.toString()}');
    }
  }

  /// Obtener un post por ID
  Future<WorkoutPostModel?> getPostById(String postId) async {
    try {
      final doc = await _firestore
          .collection(workoutPostsCollection)
          .doc(postId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return WorkoutPostModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Error al obtener post: ${e.toString()}');
    }
  }

  /// Eliminar un entrenamiento
  Future<void> deleteWorkout(String userId, String workoutId) async {
    try {
      await _firestore
          .collection(usersCollection)
          .doc(userId)
          .collection(workoutsSubcollection)
          .doc(workoutId)
          .delete();
    } catch (e) {
      throw Exception('Error al eliminar entrenamiento: ${e.toString()}');
    }
  }

  /// Eliminar un post
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection(workoutPostsCollection).doc(postId).delete();
    } catch (e) {
      throw Exception('Error al eliminar post: ${e.toString()}');
    }
  }

  /// Obtener estadísticas del usuario
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      final workouts = await getUserWorkouts(userId);

      final totalWorkouts = workouts.length;
      final totalVolume = workouts.fold<double>(
        0.0,
        (sum, w) => sum + w.totalVolume,
      );
      final totalDuration = workouts.fold<int>(0, (sum, w) => sum + w.duration);
      final totalSets = workouts.fold<int>(0, (sum, w) => sum + w.totalSets);

      return {
        'total_workouts': totalWorkouts,
        'total_volume': totalVolume,
        'total_duration': totalDuration,
        'total_sets': totalSets,
      };
    } catch (e) {
      throw Exception('Error al obtener estadísticas: ${e.toString()}');
    }
  }
}

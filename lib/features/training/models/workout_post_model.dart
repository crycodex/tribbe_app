import 'package:tribbe_app/features/training/models/workout_model.dart';

/// Modelo de post de entrenamiento para el feed
class WorkoutPostModel {
  final String id;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final WorkoutModel workout;
  final String? caption;
  final String? workoutPhotoUrl; // Foto del entrenamiento (opcional)
  final DateTime createdAt;
  final List<String> likes;
  final int commentsCount;

  WorkoutPostModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.workout,
    this.caption,
    this.workoutPhotoUrl,
    required this.createdAt,
    this.likes = const [],
    this.commentsCount = 0,
  });

  /// Crear desde JSON (Firebase)
  factory WorkoutPostModel.fromJson(Map<String, dynamic> json) {
    return WorkoutPostModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      userPhotoUrl: json['user_photo_url'] as String?,
      workout: WorkoutModel.fromJson(json['workout'] as Map<String, dynamic>),
      caption: json['caption'] as String?,
      workoutPhotoUrl: json['workout_photo_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      likes:
          (json['likes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
      commentsCount: json['comments_count'] as int? ?? 0,
    );
  }

  /// Convertir a JSON (Firebase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_photo_url': userPhotoUrl,
      'workout': workout.toJson(),
      'caption': caption,
      'workout_photo_url': workoutPhotoUrl,
      'created_at': createdAt.toIso8601String(),
      'likes': likes,
      'comments_count': commentsCount,
    };
  }

  /// Crear copia con cambios
  WorkoutPostModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    WorkoutModel? workout,
    String? caption,
    String? workoutPhotoUrl,
    DateTime? createdAt,
    List<String>? likes,
    int? commentsCount,
  }) {
    return WorkoutPostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      workout: workout ?? this.workout,
      caption: caption ?? this.caption,
      workoutPhotoUrl: workoutPhotoUrl ?? this.workoutPhotoUrl,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      commentsCount: commentsCount ?? this.commentsCount,
    );
  }

  /// Verificar si el usuario actual dio like
  bool isLikedBy(String userId) {
    return likes.contains(userId);
  }

  /// Toggle like del usuario actual
  WorkoutPostModel toggleLike(String userId) {
    final newLikes = List<String>.from(likes);
    if (newLikes.contains(userId)) {
      newLikes.remove(userId);
    } else {
      newLikes.add(userId);
    }
    return copyWith(likes: newLikes);
  }

  @override
  String toString() =>
      'WorkoutPostModel($userName, ${workout.focus}, ${likes.length} likes)';
}

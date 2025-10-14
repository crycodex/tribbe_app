import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo para un comentario en un post de entrenamiento
class CommentModel {
  final String id;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String text;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.text,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      userPhotoUrl: json['user_photo_url'] as String?,
      text: json['text'] as String,
      createdAt: (json['created_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_photo_url': userPhotoUrl,
      'text': text,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  @override
  String toString() =>
      'CommentModel(id: $id, userName: $userName, text: $text)';
}

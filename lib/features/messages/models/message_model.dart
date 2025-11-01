/// Modelo para mensajes temporales (7 días) en Firebase Realtime Database
class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderUsername;
  final String? senderPhotoUrl;
  final String receiverId;
  final String text;
  final int timestamp;
  final bool isRead;
  final int expiresAt; // Timestamp de expiración (7 días)

  // Nuevas funcionalidades
  final Map<String, String>
  reactions; // {userId: emoji} - una reacción por usuario
  final bool isDeleted;
  final bool isEdited;
  final String? editedText;
  final int? editedAt;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderUsername,
    this.senderPhotoUrl,
    required this.receiverId,
    required this.text,
    required this.timestamp,
    this.isRead = false,
    required this.expiresAt,
    this.reactions = const {},
    this.isDeleted = false,
    this.isEdited = false,
    this.editedText,
    this.editedAt,
  });

  /// Crear mensaje desde JSON (Realtime Database)
  factory MessageModel.fromJson(String id, Map<dynamic, dynamic> json) {
    // Parsear reacciones (una por usuario)
    Map<String, String> reactions = {};
    if (json['reactions'] != null) {
      final reactionsData = json['reactions'] as Map<dynamic, dynamic>;
      reactionsData.forEach((userId, emoji) {
        if (emoji is String) {
          reactions[userId as String] = emoji;
        }
      });
    }

    return MessageModel(
      id: id,
      conversationId: json['conversationId'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      senderUsername: json['senderUsername'] as String? ?? '',
      senderPhotoUrl: json['senderPhotoUrl'] as String?,
      receiverId: json['receiverId'] as String? ?? '',
      text: json['text'] as String? ?? '',
      timestamp: json['timestamp'] as int? ?? 0,
      isRead: json['isRead'] as bool? ?? false,
      expiresAt: json['expiresAt'] as int? ?? 0,
      reactions: reactions,
      isDeleted: json['isDeleted'] as bool? ?? false,
      isEdited: json['isEdited'] as bool? ?? false,
      editedText: json['editedText'] as String?,
      editedAt: json['editedAt'] as int?,
    );
  }

  /// Convertir mensaje a JSON para guardar en Realtime Database
  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'senderId': senderId,
      'senderUsername': senderUsername,
      'senderPhotoUrl': senderPhotoUrl,
      'receiverId': receiverId,
      'text': text,
      'timestamp': timestamp,
      'isRead': isRead,
      'expiresAt': expiresAt,
      'reactions': reactions,
      'isDeleted': isDeleted,
      'isEdited': isEdited,
      'editedText': editedText,
      'editedAt': editedAt,
    };
  }

  /// Crear copia del mensaje con cambios
  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderUsername,
    String? senderPhotoUrl,
    String? receiverId,
    String? text,
    int? timestamp,
    bool? isRead,
    int? expiresAt,
    Map<String, String>? reactions,
    bool? isDeleted,
    bool? isEdited,
    String? editedText,
    int? editedAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderUsername: senderUsername ?? this.senderUsername,
      senderPhotoUrl: senderPhotoUrl ?? this.senderPhotoUrl,
      receiverId: receiverId ?? this.receiverId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      expiresAt: expiresAt ?? this.expiresAt,
      reactions: reactions ?? this.reactions,
      isDeleted: isDeleted ?? this.isDeleted,
      isEdited: isEdited ?? this.isEdited,
      editedText: editedText ?? this.editedText,
      editedAt: editedAt ?? this.editedAt,
    );
  }

  /// Calcular tiempo de expiración (7 días desde ahora)
  static int calculateExpiresAt() {
    return DateTime.now().millisecondsSinceEpoch +
        (7 * 24 * 60 * 60 * 1000); // 7 días en milisegundos
  }

  /// Verificar si el mensaje ha expirado
  bool get isExpired {
    return DateTime.now().millisecondsSinceEpoch > expiresAt;
  }

  /// Obtener tiempo restante en días
  int get daysRemaining {
    final remaining = expiresAt - DateTime.now().millisecondsSinceEpoch;
    return (remaining / (24 * 60 * 60 * 1000)).ceil();
  }

  /// Obtener DateTime del mensaje
  DateTime get dateTime {
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Obtener texto a mostrar (original o editado)
  String get displayText {
    return isEdited && editedText != null ? editedText! : text;
  }

  /// Verificar si el mensaje está eliminado
  bool get isVisible {
    return !isDeleted;
  }

  /// Obtener total de reacciones
  int get totalReactions {
    return reactions.length;
  }

  /// Verificar si un usuario específico reaccionó
  bool hasReaction(String userId) {
    return reactions.containsKey(userId);
  }

  /// Obtener la reacción de un usuario específico
  String? getUserReaction(String userId) {
    return reactions[userId];
  }

  /// Obtener lista de emojis únicos con reacciones
  List<String> get reactionEmojis {
    return reactions.values.toSet().toList();
  }

  /// Obtener conteo de reacciones para un emoji específico
  int getReactionCount(String emoji) {
    return reactions.values.where((e) => e == emoji).length;
  }

  /// Verificar si el mensaje puede ser editado (solo por el emisor y dentro de 5 minutos)
  bool canBeEdited(String currentUserId) {
    if (senderId != currentUserId) return false;
    if (isDeleted) return false;

    final now = DateTime.now().millisecondsSinceEpoch;
    final fiveMinutesAgo = now - (5 * 60 * 1000); // 5 minutos en milisegundos

    return timestamp > fiveMinutesAgo;
  }

  /// Verificar si el mensaje puede ser eliminado (solo por el emisor)
  bool canBeDeleted(String currentUserId) {
    return senderId == currentUserId && !isDeleted;
  }

  @override
  String toString() {
    return 'MessageModel(id: $id, from: $senderUsername, text: $text, isRead: $isRead, reactions: ${reactions.length})';
  }
}

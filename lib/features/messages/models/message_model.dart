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
  });

  /// Crear mensaje desde JSON (Realtime Database)
  factory MessageModel.fromJson(String id, Map<dynamic, dynamic> json) {
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

  @override
  String toString() {
    return 'MessageModel(id: $id, from: $senderUsername, text: $text, isRead: $isRead)';
  }
}

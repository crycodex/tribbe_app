/// Modelo para conversaciones en Firebase Realtime Database
class ConversationModel {
  final String id;
  final String userId; // El ID del usuario actual
  final String otherUserId; // El ID del otro usuario
  final String otherUserUsername;
  final String? otherUserPhotoUrl;
  final String? otherUserDisplayName;
  final String lastMessage;
  final int lastMessageTimestamp;
  final String lastMessageSenderId;
  final int unreadCount; // Mensajes no leídos
  final int expiresAt; // Cuando expira el último mensaje
  final bool isBlocked; // Si el usuario actual bloqueó esta conversación
  final int? blockedAt; // Timestamp de bloqueo

  ConversationModel({
    required this.id,
    required this.userId,
    required this.otherUserId,
    required this.otherUserUsername,
    this.otherUserPhotoUrl,
    this.otherUserDisplayName,
    required this.lastMessage,
    required this.lastMessageTimestamp,
    required this.lastMessageSenderId,
    this.unreadCount = 0,
    required this.expiresAt,
    this.isBlocked = false,
    this.blockedAt,
  });

  /// Crear conversación desde JSON (Realtime Database)
  factory ConversationModel.fromJson(String id, Map<dynamic, dynamic> json) {
    return ConversationModel(
      id: id,
      userId: json['userId'] as String? ?? '',
      otherUserId: json['otherUserId'] as String? ?? '',
      otherUserUsername: json['otherUserUsername'] as String? ?? '',
      otherUserPhotoUrl: json['otherUserPhotoUrl'] as String?,
      otherUserDisplayName: json['otherUserDisplayName'] as String?,
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageTimestamp: json['lastMessageTimestamp'] as int? ?? 0,
      lastMessageSenderId: json['lastMessageSenderId'] as String? ?? '',
      unreadCount: json['unreadCount'] as int? ?? 0,
      expiresAt: json['expiresAt'] as int? ?? 0,
      isBlocked: json['isBlocked'] as bool? ?? false,
      blockedAt: json['blockedAt'] as int?,
    );
  }

  /// Convertir conversación a JSON para guardar en Realtime Database
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'otherUserId': otherUserId,
      'otherUserUsername': otherUserUsername,
      'otherUserPhotoUrl': otherUserPhotoUrl,
      'otherUserDisplayName': otherUserDisplayName,
      'lastMessage': lastMessage,
      'lastMessageTimestamp': lastMessageTimestamp,
      'lastMessageSenderId': lastMessageSenderId,
      'unreadCount': unreadCount,
      'expiresAt': expiresAt,
      'isBlocked': isBlocked,
      'blockedAt': blockedAt,
    };
  }

  /// Crear copia de la conversación con cambios
  ConversationModel copyWith({
    String? id,
    String? userId,
    String? otherUserId,
    String? otherUserUsername,
    String? otherUserPhotoUrl,
    String? otherUserDisplayName,
    String? lastMessage,
    int? lastMessageTimestamp,
    String? lastMessageSenderId,
    int? unreadCount,
    int? expiresAt,
    bool? isBlocked,
    int? blockedAt,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      otherUserId: otherUserId ?? this.otherUserId,
      otherUserUsername: otherUserUsername ?? this.otherUserUsername,
      otherUserPhotoUrl: otherUserPhotoUrl ?? this.otherUserPhotoUrl,
      otherUserDisplayName: otherUserDisplayName ?? this.otherUserDisplayName,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTimestamp: lastMessageTimestamp ?? this.lastMessageTimestamp,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      unreadCount: unreadCount ?? this.unreadCount,
      expiresAt: expiresAt ?? this.expiresAt,
      isBlocked: isBlocked ?? this.isBlocked,
      blockedAt: blockedAt ?? this.blockedAt,
    );
  }

  /// Verificar si la conversación ha expirado
  bool get isExpired {
    return DateTime.now().millisecondsSinceEpoch > expiresAt;
  }

  /// Obtener tiempo restante en días
  int get daysRemaining {
    final remaining = expiresAt - DateTime.now().millisecondsSinceEpoch;
    return (remaining / (24 * 60 * 60 * 1000)).ceil();
  }

  /// Obtener DateTime del último mensaje
  DateTime get lastMessageDateTime {
    return DateTime.fromMillisecondsSinceEpoch(lastMessageTimestamp);
  }

  /// Verificar si el último mensaje es del usuario actual
  bool isLastMessageFromMe(String currentUserId) {
    return lastMessageSenderId == currentUserId;
  }

  /// Obtener nombre para mostrar
  String get displayName {
    return otherUserDisplayName ?? '@$otherUserUsername';
  }

  @override
  String toString() {
    return 'ConversationModel(id: $id, with: $otherUserUsername, unread: $unreadCount)';
  }
}

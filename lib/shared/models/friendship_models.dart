/// Enumeración de estados de una solicitud de amistad
enum FriendRequestStatus {
  pending, // Pendiente
  accepted, // Aceptada
  rejected, // Rechazada
  cancelled, // Cancelada
}

/// Modelo de solicitud de amistad
class FriendRequest {
  FriendRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.senderUsername,
    this.senderDisplayName,
    this.senderPhotoUrl,
    this.receiverUsername,
    this.receiverDisplayName,
    this.receiverPhotoUrl,
  });

  final String id;
  final String senderId; // Quien envía la solicitud
  final String receiverId; // Quien recibe la solicitud
  final FriendRequestStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Info adicional del sender (opcional, para UI)
  final String? senderUsername;
  final String? senderDisplayName;
  final String? senderPhotoUrl;

  // Info adicional del receiver (opcional, para UI)
  final String? receiverUsername;
  final String? receiverDisplayName;
  final String? receiverPhotoUrl;

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      receiverId: json['receiver_id'] as String,
      status: _statusFromString(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      senderUsername: json['sender_username'] as String?,
      senderDisplayName: json['sender_display_name'] as String?,
      senderPhotoUrl: json['sender_photo_url'] as String?,
      receiverUsername: json['receiver_username'] as String?,
      receiverDisplayName: json['receiver_display_name'] as String?,
      receiverPhotoUrl: json['receiver_photo_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'status': _statusToString(status),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'sender_username': senderUsername,
      'sender_display_name': senderDisplayName,
      'sender_photo_url': senderPhotoUrl,
      'receiver_username': receiverUsername,
      'receiver_display_name': receiverDisplayName,
      'receiver_photo_url': receiverPhotoUrl,
    };
  }

  static FriendRequestStatus _statusFromString(String status) {
    switch (status) {
      case 'pending':
        return FriendRequestStatus.pending;
      case 'accepted':
        return FriendRequestStatus.accepted;
      case 'rejected':
        return FriendRequestStatus.rejected;
      case 'cancelled':
        return FriendRequestStatus.cancelled;
      default:
        return FriendRequestStatus.pending;
    }
  }

  static String _statusToString(FriendRequestStatus status) {
    switch (status) {
      case FriendRequestStatus.pending:
        return 'pending';
      case FriendRequestStatus.accepted:
        return 'accepted';
      case FriendRequestStatus.rejected:
        return 'rejected';
      case FriendRequestStatus.cancelled:
        return 'cancelled';
    }
  }

  FriendRequest copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    FriendRequestStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? senderUsername,
    String? senderDisplayName,
    String? senderPhotoUrl,
    String? receiverUsername,
    String? receiverDisplayName,
    String? receiverPhotoUrl,
  }) {
    return FriendRequest(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      senderUsername: senderUsername ?? this.senderUsername,
      senderDisplayName: senderDisplayName ?? this.senderDisplayName,
      senderPhotoUrl: senderPhotoUrl ?? this.senderPhotoUrl,
      receiverUsername: receiverUsername ?? this.receiverUsername,
      receiverDisplayName: receiverDisplayName ?? this.receiverDisplayName,
      receiverPhotoUrl: receiverPhotoUrl ?? this.receiverPhotoUrl,
    );
  }
}

/// Modelo de amistad (relación ya aceptada)
class Friendship {
  Friendship({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.createdAt,
    this.friendUsername,
    this.friendDisplayName,
    this.friendPhotoUrl,
    this.friendBio,
  });

  final String id;
  final String userId; // ID del usuario actual
  final String friendId; // ID del amigo
  final DateTime createdAt;

  // Info adicional del amigo (opcional, para UI)
  final String? friendUsername;
  final String? friendDisplayName;
  final String? friendPhotoUrl;
  final String? friendBio;

  factory Friendship.fromJson(Map<String, dynamic> json) {
    return Friendship(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      friendId: json['friend_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      friendUsername: json['friend_username'] as String?,
      friendDisplayName: json['friend_display_name'] as String?,
      friendPhotoUrl: json['friend_photo_url'] as String?,
      friendBio: json['friend_bio'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'friend_id': friendId,
      'created_at': createdAt.toIso8601String(),
      'friend_username': friendUsername,
      'friend_display_name': friendDisplayName,
      'friend_photo_url': friendPhotoUrl,
      'friend_bio': friendBio,
    };
  }

  Friendship copyWith({
    String? id,
    String? userId,
    String? friendId,
    DateTime? createdAt,
    String? friendUsername,
    String? friendDisplayName,
    String? friendPhotoUrl,
    String? friendBio,
  }) {
    return Friendship(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      friendId: friendId ?? this.friendId,
      createdAt: createdAt ?? this.createdAt,
      friendUsername: friendUsername ?? this.friendUsername,
      friendDisplayName: friendDisplayName ?? this.friendDisplayName,
      friendPhotoUrl: friendPhotoUrl ?? this.friendPhotoUrl,
      friendBio: friendBio ?? this.friendBio,
    );
  }
}

/// Modelo de bloqueo de usuario
class BlockedUser {
  BlockedUser({
    required this.id,
    required this.userId,
    required this.blockedUserId,
    required this.createdAt,
    this.blockedUsername,
    this.blockedDisplayName,
    this.blockedPhotoUrl,
  });

  final String id;
  final String userId; // Quien bloquea
  final String blockedUserId; // Usuario bloqueado
  final DateTime createdAt;

  // Info adicional del usuario bloqueado (opcional, para UI)
  final String? blockedUsername;
  final String? blockedDisplayName;
  final String? blockedPhotoUrl;

  factory BlockedUser.fromJson(Map<String, dynamic> json) {
    return BlockedUser(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      blockedUserId: json['blocked_user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      blockedUsername: json['blocked_username'] as String?,
      blockedDisplayName: json['blocked_display_name'] as String?,
      blockedPhotoUrl: json['blocked_photo_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'blocked_user_id': blockedUserId,
      'created_at': createdAt.toIso8601String(),
      'blocked_username': blockedUsername,
      'blocked_display_name': blockedDisplayName,
      'blocked_photo_url': blockedPhotoUrl,
    };
  }

  BlockedUser copyWith({
    String? id,
    String? userId,
    String? blockedUserId,
    DateTime? createdAt,
    String? blockedUsername,
    String? blockedDisplayName,
    String? blockedPhotoUrl,
  }) {
    return BlockedUser(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      blockedUserId: blockedUserId ?? this.blockedUserId,
      createdAt: createdAt ?? this.createdAt,
      blockedUsername: blockedUsername ?? this.blockedUsername,
      blockedDisplayName: blockedDisplayName ?? this.blockedDisplayName,
      blockedPhotoUrl: blockedPhotoUrl ?? this.blockedPhotoUrl,
    );
  }
}

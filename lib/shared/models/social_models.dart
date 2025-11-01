/// Modelo de relación de seguimiento (follower/following)
class FollowRelation {
  FollowRelation({
    required this.id,
    required this.followerId,
    required this.followingId,
    required this.createdAt,
    this.followerUsername,
    this.followerDisplayName,
    this.followerPhotoUrl,
    this.followingUsername,
    this.followingDisplayName,
    this.followingPhotoUrl,
  });

  final String id;
  final String followerId; // Quien sigue
  final String followingId; // A quien sigue
  final DateTime createdAt;

  // Info adicional del follower (opcional, para UI)
  final String? followerUsername;
  final String? followerDisplayName;
  final String? followerPhotoUrl;

  // Info adicional del following (opcional, para UI)
  final String? followingUsername;
  final String? followingDisplayName;
  final String? followingPhotoUrl;

  factory FollowRelation.fromJson(Map<String, dynamic> json) {
    return FollowRelation(
      id: json['id'] as String,
      followerId: json['follower_id'] as String,
      followingId: json['following_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      followerUsername: json['follower_username'] as String?,
      followerDisplayName: json['follower_display_name'] as String?,
      followerPhotoUrl: json['follower_photo_url'] as String?,
      followingUsername: json['following_username'] as String?,
      followingDisplayName: json['following_display_name'] as String?,
      followingPhotoUrl: json['following_photo_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'follower_id': followerId,
      'following_id': followingId,
      'created_at': createdAt.toIso8601String(),
      'follower_username': followerUsername,
      'follower_display_name': followerDisplayName,
      'follower_photo_url': followerPhotoUrl,
      'following_username': followingUsername,
      'following_display_name': followingDisplayName,
      'following_photo_url': followingPhotoUrl,
    };
  }

  FollowRelation copyWith({
    String? id,
    String? followerId,
    String? followingId,
    DateTime? createdAt,
    String? followerUsername,
    String? followerDisplayName,
    String? followerPhotoUrl,
    String? followingUsername,
    String? followingDisplayName,
    String? followingPhotoUrl,
  }) {
    return FollowRelation(
      id: id ?? this.id,
      followerId: followerId ?? this.followerId,
      followingId: followingId ?? this.followingId,
      createdAt: createdAt ?? this.createdAt,
      followerUsername: followerUsername ?? this.followerUsername,
      followerDisplayName: followerDisplayName ?? this.followerDisplayName,
      followerPhotoUrl: followerPhotoUrl ?? this.followerPhotoUrl,
      followingUsername: followingUsername ?? this.followingUsername,
      followingDisplayName: followingDisplayName ?? this.followingDisplayName,
      followingPhotoUrl: followingPhotoUrl ?? this.followingPhotoUrl,
    );
  }
}

/// Modelo para estadísticas sociales de un usuario
class SocialStats {
  SocialStats({
    required this.userId,
    required this.followersCount,
    required this.followingCount,
    required this.friendsCount,
    this.updatedAt,
  });

  final String userId;
  final int followersCount;
  final int followingCount;
  final int friendsCount;
  final DateTime? updatedAt;

  factory SocialStats.fromJson(Map<String, dynamic> json) {
    return SocialStats(
      userId: json['user_id'] as String,
      followersCount: json['followers_count'] as int,
      followingCount: json['following_count'] as int,
      friendsCount: json['friends_count'] as int,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'followers_count': followersCount,
      'following_count': followingCount,
      'friends_count': friendsCount,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  SocialStats copyWith({
    String? userId,
    int? followersCount,
    int? followingCount,
    int? friendsCount,
    DateTime? updatedAt,
  }) {
    return SocialStats(
      userId: userId ?? this.userId,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      friendsCount: friendsCount ?? this.friendsCount,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

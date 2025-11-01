import 'package:tribbe_app/features/auth/models/user_model.dart';

/// Modelo de respuesta de autenticación
class AuthResponseModel {
  AuthResponseModel({
    required this.user,
    required this.token,
    this.refreshToken,
    this.expiresAt,
  });

  final UserModel user;
  final String token;
  final String? refreshToken;
  final DateTime? expiresAt;

  /// Crea una instancia desde JSON
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
      refreshToken: json['refresh_token'] as String?,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'token': token,
      'refresh_token': refreshToken,
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  /// Crea una copia con campos modificados
  AuthResponseModel copyWith({
    UserModel? user,
    String? token,
    String? refreshToken,
    DateTime? expiresAt,
  }) {
    return AuthResponseModel(
      user: user ?? this.user,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  String toString() {
    return 'AuthResponseModel(user: ${user.email}, token: ${token.substring(0, 10)}...)';
  }
}

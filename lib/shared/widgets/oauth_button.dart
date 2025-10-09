import 'package:flutter/material.dart';
import 'package:tribbe_app/app/theme/app_colors.dart';

/// Tipos de proveedores OAuth
enum OAuthProvider { facebook, google, apple }

/// Botón de autenticación OAuth personalizado
class OAuthButton extends StatelessWidget {
  const OAuthButton({
    required this.provider,
    required this.onPressed,
    this.isLoading = false,
    this.size = 50,
    super.key,
  });

  final OAuthProvider provider;
  final VoidCallback onPressed;
  final bool isLoading;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: _getBackgroundColor(isDark),
      borderRadius: BorderRadius.circular(size / 2),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size / 2),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: size * 0.4,
                    height: size * 0.4,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getIconColor(isDark),
                      ),
                    ),
                  )
                : Icon(
                    _getIcon(),
                    size: size * 0.5,
                    color: _getIconColor(isDark),
                  ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(bool isDark) {
    if (provider == OAuthProvider.apple && !isDark) {
      return AppColors.kAppleBlack;
    }
    return isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white;
  }

  Color _getIconColor(bool isDark) {
    switch (provider) {
      case OAuthProvider.facebook:
        return AppColors.kFacebookBlue;
      case OAuthProvider.google:
        return AppColors.kGoogleRed;
      case OAuthProvider.apple:
        return isDark ? Colors.white : Colors.white;
    }
  }

  IconData _getIcon() {
    switch (provider) {
      case OAuthProvider.facebook:
        return Icons.facebook;
      case OAuthProvider.google:
        return Icons.g_mobiledata;
      case OAuthProvider.apple:
        return Icons.apple;
    }
  }
}

/// Fila de botones OAuth
class OAuthButtonsRow extends StatelessWidget {
  const OAuthButtonsRow({
    required this.onFacebookPressed,
    required this.onGooglePressed,
    required this.onApplePressed,
    this.isLoading = false,
    this.buttonSize = 50,
    this.spacing = 16,
    super.key,
  });

  final VoidCallback onFacebookPressed;
  final VoidCallback onGooglePressed;
  final VoidCallback onApplePressed;
  final bool isLoading;
  final double buttonSize;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OAuthButton(
          provider: OAuthProvider.facebook,
          onPressed: onFacebookPressed,
          isLoading: isLoading,
          size: buttonSize,
        ),
        SizedBox(width: spacing),
        OAuthButton(
          provider: OAuthProvider.google,
          onPressed: onGooglePressed,
          isLoading: isLoading,
          size: buttonSize,
        ),
        SizedBox(width: spacing),
        OAuthButton(
          provider: OAuthProvider.apple,
          onPressed: onApplePressed,
          isLoading: isLoading,
          size: buttonSize,
        ),
      ],
    );
  }
}

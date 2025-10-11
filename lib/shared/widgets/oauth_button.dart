import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tribbe_app/app/theme/app_colors.dart';

/// Tipos de proveedores OAuth
enum OAuthProvider { google, apple }

/// Botón de autenticación OAuth personalizado
class OAuthButton extends StatelessWidget {
  const OAuthButton({
    required this.provider,
    required this.onPressed,
    this.isLoading = false,
    this.size = 50,
    this.showLabel = false,
    super.key,
  });

  final OAuthProvider provider;
  final VoidCallback onPressed;
  final bool isLoading;
  final double size;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (showLabel) {
      return _buildButtonWithLabel(context, isDark);
    }

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

  Widget _buildButtonWithLabel(BuildContext context, bool isDark) {
    return Material(
      color: _getBackgroundColor(isDark),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: size,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  width: size * 0.4,
                  height: size * 0.4,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getIconColor(isDark),
                    ),
                  ),
                )
              else
                Icon(
                  _getIcon(),
                  size: size * 0.5,
                  color: _getIconColor(isDark),
                ),
              const SizedBox(width: 12),
              Text(
                _getLabel(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _getTextColor(isDark),
                ),
              ),
            ],
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
      case OAuthProvider.google:
        return AppColors.kGoogleRed;
      case OAuthProvider.apple:
        return isDark ? Colors.white : Colors.white;
    }
  }

  IconData _getIcon() {
    switch (provider) {
      case OAuthProvider.google:
        return Icons.g_mobiledata;
      case OAuthProvider.apple:
        return Icons.apple;
    }
  }

  String _getLabel() {
    switch (provider) {
      case OAuthProvider.google:
        return 'Google';
      case OAuthProvider.apple:
        return 'Apple';
    }
  }

  Color _getTextColor(bool isDark) {
    switch (provider) {
      case OAuthProvider.google:
        return isDark ? Colors.white : AppColors.kGoogleRed;
      case OAuthProvider.apple:
        return Colors.white;
    }
  }
}

/// Fila de botones OAuth
class OAuthButtonsRow extends StatelessWidget {
  const OAuthButtonsRow({
    required this.onGooglePressed,
    required this.onApplePressed,
    this.isLoading = false,
    this.buttonSize = 50,
    this.spacing = 16,
    this.showLabels = true,
    super.key,
  });

  final VoidCallback onGooglePressed;
  final VoidCallback onApplePressed;
  final bool isLoading;
  final double buttonSize;
  final double spacing;
  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    final isIOS = Platform.isIOS;

    if (showLabels) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: OAuthButton(
              provider: OAuthProvider.google,
              onPressed: onGooglePressed,
              isLoading: isLoading,
              size: buttonSize,
              showLabel: true,
            ),
          ),
          if (isIOS) ...[
            SizedBox(height: spacing),
            SizedBox(
              width: double.infinity,
              child: OAuthButton(
                provider: OAuthProvider.apple,
                onPressed: onApplePressed,
                isLoading: isLoading,
                size: buttonSize,
                showLabel: true,
              ),
            ),
          ],
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OAuthButton(
          provider: OAuthProvider.google,
          onPressed: onGooglePressed,
          isLoading: isLoading,
          size: buttonSize,
        ),
        if (isIOS) ...[
          SizedBox(width: spacing),
          OAuthButton(
            provider: OAuthProvider.apple,
            onPressed: onApplePressed,
            isLoading: isLoading,
            size: buttonSize,
          ),
        ],
      ],
    );
  }
}

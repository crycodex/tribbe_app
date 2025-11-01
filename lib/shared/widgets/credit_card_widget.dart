import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tribbe_app/features/auth/models/user_model.dart';

/// Widget de tarjeta de crédito reutilizable con funcionalidad de compartir
class CreditCardWidget extends StatefulWidget {
  final UserModel user;
  final int followersCount;
  final int followingCount;
  final VoidCallback? onTap;
  final bool showShareButton;

  const CreditCardWidget({
    super.key,
    required this.user,
    required this.followersCount,
    required this.followingCount,
    this.onTap,
    this.showShareButton = true,
  });

  @override
  State<CreditCardWidget> createState() => _CreditCardWidgetState();
}

class _CreditCardWidgetState extends State<CreditCardWidget> {
  final GlobalKey _cardKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.onTap,
      child: RepaintBoundary(
        key: _cardKey,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF1A1A1A),
                      const Color(0xFF2D2D2D),
                      const Color(0xFF1A1A1A),
                    ]
                  : [
                      const Color(0xFFFFFFFF),
                      const Color(0xFFF8F9FA),
                      const Color(0xFFFFFFFF),
                    ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.4)
                    : Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Patrón de fondo sutil
              _buildBackgroundPattern(isDark),

              // Contenido de la tarjeta
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header con icono y botón de compartir
                    _buildHeader(isDark),

                    const Spacer(),

                    // Información del usuario
                    _buildUserInfo(isDark),

                    const SizedBox(height: 8),

                    // UID como número de tarjeta
                    _buildCardNumber(isDark),

                    const SizedBox(height: 16),

                    // Footer con estadísticas
                    _buildStats(isDark),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundPattern(bool isDark) {
    return Stack(
      children: [
        Positioned(
          top: -20,
          right: -20,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.02)
                  : Colors.black.withValues(alpha: 0.02),
            ),
          ),
        ),
        Positioned(
          bottom: -30,
          left: -30,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.01)
                  : Colors.black.withValues(alpha: 0.01),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'TRIBBE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : Colors.black54,
            letterSpacing: 2,
          ),
        ),
        const Spacer(),
        if (widget.showShareButton)
          GestureDetector(
            onTap: _shareCard,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.share,
                size: 16,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          )
        else
          Icon(
            Icons.credit_card,
            size: 20,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
      ],
    );
  }

  Widget _buildUserInfo(bool isDark) {
    return Text(
      '@${widget.user.username ?? "usuario"}',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: isDark ? Colors.white : Colors.black87,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildCardNumber(bool isDark) {
    return Row(
      children: [
        Text(
          widget.user.id.substring(0, 8).toUpperCase(),
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'monospace',
            fontWeight: FontWeight.w400,
            color: isDark ? Colors.white60 : Colors.black45,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '••••',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white60 : Colors.black45,
            letterSpacing: 1,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: widget.user.id));
            Get.snackbar(
              'Copiado',
              'UID copiado al portapapeles',
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 1),
              backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              colorText: isDark ? Colors.white : Colors.black,
              margin: const EdgeInsets.all(20),
              borderRadius: 12,
            );
          },
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.copy,
              size: 14,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStats(bool isDark) {
    return Row(
      children: [
        _buildStatChip('Seguidores', widget.followersCount.toString(), isDark),
        const SizedBox(width: 12),
        _buildStatChip('Siguiendo', widget.followingCount.toString(), isDark),
      ],
    );
  }

  Widget _buildStatChip(String label, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  /// Compartir la tarjeta como imagen
  Future<void> _shareCard() async {
    try {
      // Obtener dimensiones de pantalla ANTES de cualquier operación async
      final screenSize = MediaQuery.of(context).size;

      // Mostrar loading
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Capturar la tarjeta como imagen
      final imageBytes = await _captureWidget();

      if (imageBytes != null) {
        // Guardar imagen temporal
        final tempDir = await getTemporaryDirectory();
        final file = File(
          '${tempDir.path}/tribbe_card_${DateTime.now().millisecondsSinceEpoch}.png',
        );
        await file.writeAsBytes(imageBytes);

        // Compartir la imagen usando la nueva API
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path)],
            text: 'Mi tarjeta Tribbe - @${widget.user.username ?? "usuario"}',
            sharePositionOrigin: Rect.fromLTWH(
              0,
              0,
              screenSize.width,
              screenSize.height,
            ),
          ),
        );

        // Limpiar archivo temporal después de un delay
        Future.delayed(const Duration(seconds: 5), () {
          if (file.existsSync()) {
            file.deleteSync();
          }
        });
      }

      // Cerrar loading
      Get.back();
    } catch (e) {
      // Cerrar loading si está abierto
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.snackbar(
        'Error',
        'No se pudo compartir la tarjeta: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Capturar el widget como imagen
  Future<Uint8List?> _captureWidget() async {
    try {
      final RenderRepaintBoundary boundary =
          _cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturando widget: $e');
      return null;
    }
  }
}

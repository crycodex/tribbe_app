import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tribbe_app/features/auth/models/user_model.dart';
import 'package:tribbe_app/features/auth/models/user_profile_model.dart';
import 'package:tribbe_app/shared/services/firestore_service.dart';
import 'package:tribbe_app/shared/services/firebase_auth_service.dart';

/// Widget de tarjeta de crédito reutilizable con funcionalidad de compartir
class CreditCardWidget extends StatefulWidget {
  final UserModel user;
  final int followersCount;
  final int followingCount;
  final VoidCallback? onTap;
  final bool showShareButton;
  final bool showEditButton;
  final VoidCallback? onShare;
  final VoidCallback? onEdit;
  final List<Color>? customGradientColors;
  final String? customCardStyle;
  final bool? showPattern;
  final double? patternOpacity;
  final bool showButtonsBelow;

  const CreditCardWidget({
    super.key,
    required this.user,
    required this.followersCount,
    required this.followingCount,
    this.onTap,
    this.showShareButton = true,
    this.showEditButton = false,
    this.onShare,
    this.onEdit,
    this.customGradientColors,
    this.customCardStyle,
    this.showPattern,
    this.patternOpacity,
    this.showButtonsBelow = false,
  });

  @override
  State<CreditCardWidget> createState() => _CreditCardWidgetState();
}

class _CreditCardWidgetState extends State<CreditCardWidget> {
  final GlobalKey _cardKey = GlobalKey();
  CardPreferences? _cardPreferences;
  bool _isLoadingPreferences = true;

  @override
  void initState() {
    super.initState();
    _loadCardPreferences();
  }

  /// Cargar preferencias de la tarjeta desde Firebase
  Future<void> _loadCardPreferences() async {
    try {
      // Si se pasan colores personalizados directamente, usarlos
      if (widget.customGradientColors != null) {
        setState(() {
          _isLoadingPreferences = false;
        });
        return;
      }

      final authService = Get.find<FirebaseAuthService>();
      final firestoreService = Get.find<FirestoreService>();
      final user = authService.currentUser;

      if (user != null && user.uid == widget.user.id) {
        final profile = await firestoreService.getUserProfile(user.uid);
        if (profile?.preferencias?.cardPreferences != null) {
          setState(() {
            _cardPreferences = profile!.preferencias!.cardPreferences;
            _isLoadingPreferences = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint('Error cargando preferencias de tarjeta: $e');
    }

    setState(() {
      _isLoadingPreferences = false;
    });
  }

  /// Obtener colores del gradiente
  List<Color> _getGradientColors(bool isDark) {
    // Si se pasan colores personalizados directamente, usarlos
    if (widget.customGradientColors != null) {
      return widget.customGradientColors!;
    }

    // Si hay preferencias guardadas, usarlas
    if (_cardPreferences != null) {
      return _cardPreferences!.getDefaultColors(isDark);
    }

    // Valores por defecto según el tema
    return isDark
        ? [
            const Color(0xFF1A1A1A),
            const Color(0xFF2D2D2D),
            const Color(0xFF1A1A1A),
          ]
        : [
            const Color(0xFFFFFFFF),
            const Color(0xFFF8F9FA),
            const Color(0xFFFFFFFF),
          ];
  }

  /// Determinar si el fondo de la tarjeta es oscuro basándose en los colores del gradiente
  bool _isCardBackgroundDark(List<Color> gradientColors) {
    // Calcular el brillo promedio de los colores del gradiente
    double totalBrightness = 0;
    for (final color in gradientColors) {
      totalBrightness += color.computeLuminance();
    }
    final averageBrightness = totalBrightness / gradientColors.length;
    // Si el brillo promedio es menor a 0.5, el fondo es oscuro
    return averageBrightness < 0.5;
  }

  /// Obtener si mostrar patrón
  bool _getShowPattern() {
    if (widget.showPattern != null) {
      return widget.showPattern!;
    }
    return _cardPreferences?.showPattern ?? true;
  }

  /// Obtener opacidad del patrón
  double _getPatternOpacity() {
    if (widget.patternOpacity != null) {
      return widget.patternOpacity!;
    }
    return _cardPreferences?.patternOpacity ?? 0.02;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoadingPreferences) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final gradientColors = _getGradientColors(isDark);
    final showPattern = _getShowPattern();
    final patternOpacity = _getPatternOpacity();
    final isCardDark = _isCardBackgroundDark(gradientColors);

    return Column(
      children: [
        GestureDetector(
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
                  colors: gradientColors,
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
                  if (showPattern)
                    _buildBackgroundPattern(isCardDark, patternOpacity),

                  // Contenido de la tarjeta
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header con icono (sin botones si showButtonsBelow es true)
                        _buildHeader(isCardDark),

                        const Spacer(),

                        // Información del usuario
                        _buildUserInfo(isCardDark),

                        const SizedBox(height: 8),

                        // UID como número de tarjeta
                        _buildCardNumber(isCardDark),

                        const SizedBox(height: 16),

                        // Footer con estadísticas
                        _buildStats(isCardDark),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Botones debajo de la tarjeta
        if (widget.showButtonsBelow) _buildButtonsBelow(isDark),
      ],
    );
  }

  Widget _buildBackgroundPattern(bool isDark, double opacity) {
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
                  ? Colors.white.withValues(alpha: opacity)
                  : Colors.black.withValues(alpha: opacity),
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
                  ? Colors.white.withValues(alpha: opacity * 0.5)
                  : Colors.black.withValues(alpha: opacity * 0.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(bool isCardDark) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCardDark ? Colors.white : Colors.grey.shade800,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'TRIBBE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isCardDark ? Colors.white70 : Colors.grey.shade700,
            letterSpacing: 2,
          ),
        ),
        const Spacer(),
        // Solo mostrar icono en el header si los botones NO están debajo
        if (!widget.showButtonsBelow)
          Icon(
            Icons.credit_card,
            size: 20,
            color: isCardDark ? Colors.white70 : Colors.grey.shade700,
          ),
      ],
    );
  }

  Widget _buildButtonsBelow(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.showEditButton)
            _buildActionButton(
              icon: Icons.edit,
              label: 'Editar',
              onTap: widget.onEdit ?? () {},
              isDark: isDark,
            ),
          if (widget.showEditButton && widget.showShareButton)
            const SizedBox(width: 16),
          if (widget.showShareButton)
            _buildActionButton(
              icon: Icons.share,
              label: 'Compartir',
              onTap: widget.onShare ?? _shareCard,
              isDark: isDark,
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.15)
                : Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isDark ? Colors.white : Colors.grey.shade900,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.grey.shade900,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(bool isCardDark) {
    return Text(
      '@${widget.user.username ?? "usuario"}',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: isCardDark ? Colors.white : Colors.grey.shade900,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildCardNumber(bool isCardDark) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Text(
          widget.user.id.substring(0, 8).toUpperCase(),
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'monospace',
            fontWeight: FontWeight.w400,
            color: isCardDark ? Colors.white60 : Colors.grey.shade700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '••••',
          style: TextStyle(
            fontSize: 14,
            color: isCardDark ? Colors.white60 : Colors.grey.shade700,
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
              color: isCardDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.copy,
              size: 14,
              color: isCardDark ? Colors.white70 : Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStats(bool isCardDark) {
    return Row(
      children: [
        _buildStatChip(
          'Seguidores',
          widget.followersCount.toString(),
          isCardDark,
        ),
        const SizedBox(width: 12),
        _buildStatChip(
          'Siguiendo',
          widget.followingCount.toString(),
          isCardDark,
        ),
      ],
    );
  }

  Widget _buildStatChip(String label, String value, bool isCardDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isCardDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCardDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.shade300,
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
              color: isCardDark ? Colors.white : Colors.grey.shade900,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isCardDark ? Colors.white60 : Colors.grey.shade700,
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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/features/social/controllers/social_controller.dart';
import 'package:tribbe_app/features/social/views/widgets/search_tab.dart';
import 'package:tribbe_app/features/social/views/widgets/followers_tab.dart';
import 'package:tribbe_app/features/social/views/widgets/following_tab.dart';
/// Página principal de funcionalidad social con diseño minimalista tipo tarjeta de crédito
class SocialPage extends StatelessWidget {
  const SocialPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SocialController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF000000)
          : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Social',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w300,
            color: isDark ? Colors.white : Colors.black87,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Tarjeta de usuario tipo crédito
          _buildCreditCard(context, controller, isDark),

          const SizedBox(height: 24),

          // Tabs minimalistas
          _buildMinimalTabs(context, controller, isDark),

          const SizedBox(height: 16),

          // Contenido del tab actual
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0A0A0A) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Obx(() {
                  switch (controller.currentTabIndex.value) {
                    case 0:
                      return const FollowersTab();
                    case 1:
                      return const FollowingTab();
                    case 2:
                      return const SearchTab();
                    default:
                      return const SizedBox.shrink();
                  }
                }),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCreditCard(
    BuildContext context,
    SocialController controller,
    bool isDark,
  ) {
    return Container(
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
      child: Builder(
        builder: (context) {
          final user = controller.currentUser;
          if (user == null) return const SizedBox.shrink();

          return Stack(
            children: [
              // Patrón de fondo sutil
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

              // Contenido de la tarjeta
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header con icono
                    Row(
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
                        Icon(
                          Icons.credit_card,
                          size: 20,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Información del usuario
                    Text(
                      '@${user.username ?? "usuario"}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black87,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // UID como número de tarjeta
                    Row(
                      children: [
                        Text(
                          user.id.substring(0, 8).toUpperCase(),
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
                            Clipboard.setData(ClipboardData(text: user.id));
                            Get.snackbar(
                              'Copiado',
                              'UID copiado al portapapeles',
                              snackPosition: SnackPosition.BOTTOM,
                              duration: const Duration(seconds: 1),
                              backgroundColor: isDark
                                  ? const Color(0xFF1A1A1A)
                                  : Colors.white,
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
                    ),

                    const SizedBox(height: 16),

                    // Footer con estadísticas
                    Row(
                      children: [
                        _buildStatChip(
                          'Seguidores',
                          controller.followers.length.toString(),
                          isDark,
                        ),
                        const SizedBox(width: 12),
                        _buildStatChip(
                          'Siguiendo',
                          controller.following.length.toString(),
                          isDark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
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

  Widget _buildMinimalTabs(
    BuildContext context,
    SocialController controller,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 50,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0A0A) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: _buildMinimalTab(
                'Seguidores',
                0,
                controller.followers.length,
                controller.currentTabIndex.value == 0,
                () => controller.changeTab(0),
                isDark,
              ),
            ),
            Expanded(
              child: _buildMinimalTab(
                'Siguiendo',
                1,
                controller.following.length,
                controller.currentTabIndex.value == 1,
                () => controller.changeTab(1),
                isDark,
              ),
            ),
            Expanded(
              child: _buildMinimalTab(
                'Buscar',
                2,
                null,
                controller.currentTabIndex.value == 2,
                () => controller.changeTab(2),
                isDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMinimalTab(
    String label,
    int index,
    int? count,
    bool isSelected,
    VoidCallback onTap,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? (isDark ? Colors.white : Colors.black87)
                      : (isDark ? Colors.white60 : Colors.black54),
                ),
              ),
              if (count != null && count > 0) ...[
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark
                              ? Colors.white.withValues(alpha: 0.2)
                              : Colors.black.withValues(alpha: 0.1))
                        : (isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.05)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? (isDark ? Colors.white : Colors.black87)
                          : (isDark ? Colors.white60 : Colors.black54),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

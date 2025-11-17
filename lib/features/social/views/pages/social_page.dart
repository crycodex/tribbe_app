import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/features/social/controllers/social_controller.dart';
import 'package:tribbe_app/features/social/views/widgets/search_tab.dart';
import 'package:tribbe_app/features/social/views/widgets/followers_tab.dart';
import 'package:tribbe_app/features/social/views/widgets/following_tab.dart';
import 'package:tribbe_app/shared/widgets/credit_card_widget.dart';

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
          Obx(() {
            final user = controller.currentUser;
            if (user == null) return const SizedBox.shrink();

            return CreditCardWidget(
              user: user,
              followersCount: controller.followers.length,
              followingCount: controller.following.length,
              showShareButton: true,
              showButtonsBelow: true,
            );
          }),

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
